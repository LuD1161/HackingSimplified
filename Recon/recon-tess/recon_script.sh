#!/bin/bash

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function check_all(){
  for tool in "${tools[@]}"; do
      # Check if the tool exists
      if command_exists "$tool"; then
        echo "✅ $tool installed successfully."
      else
        echo "Trying to install $tool"
        if ! command_exists $tool; then
          if [[ -f "install_tools.sh" ]]; then
              echo "Running install_tools.sh..."
              source install_tools.sh
          else
              echo "install_tools.sh script not found."
              exit 1 # exit in failure
          fi
        fi
      fi
  done
}

NOTIFY_PROVIDER_CONFIG_FILEPATH="/root/tools/notify-provider-config.yml"
ONE_FOR_ALL_DIRECTORY="/root/tools/OneForAll"

# Install necessary tools
tools=("amass" "naabu" "ffuf" "httpx" "anew" "notify" "nuclei")
check_all $tools

# Function to perform reconnaissance for a single domain
perform_recon() {
  local domain=$1
  local output_folder=$2

  echo "Performing reconnaissance for domain: $domain"

  # Create output folder for the domain
  mkdir -p "$output_folder"

  # Perform subdomain enumeration with amass
  echo "Performing subdomain enumeration with amass..."
  amass enum -d "$domain" > "$output_folder/amass.txt"

  
  # Perform subdomain enumeration with oneforall
  echo "Performing subdomain enumeration with oneforall..."
  python3 $ONE_FOR_ALL_DIRECTORY/oneforall.py --target "$domain" run > "$output_folder/oneforall.txt"

  # Combine the output of amass and oneforall
  cat "$output_folder/amass.txt" "$output_folder/oneforall.txt" | sort -u > "$output_folder/subdomains.txt"

  # Use anew to filter out existing subdomains
  echo "Filtering out existing subdomains with 'anew'..."
  anew -q "$output_folder/subdomains.txt" "$output_folder/subdomains.txt" > "$output_folder/new_subdomains.txt"

  # Send Discord notification with new subdomains or no new domains found
  if [ -s "$output_folder/new_subdomains.txt" ]; then
    echo "Sending Discord notification with new subdomains..."
    echo  "🎯 New subdomains found for $domain: `cat $output_folder/new_subdomains.txt`" | notify -provider-config $NOTIFY_PROVIDER_CONFIG_FILEPATH -bulk -id scan_status
  else
    echo "Sending Discord notification: No new domains found for $domain."
    echo  "❌ No new domains found for $domain." | notify -provider-config $NOTIFY_PROVIDER_CONFIG_FILEPATH -bulk -id scan_status
  fi

  # Use httpx to get titles and filter out 403 responses
  echo "Performing HTTP request with httpx..."
  httpx -l "$output_folder/subdomains.txt" -title -silent -follow-redirects -status-code -o "$output_folder/httpx_output.txt"
  # Get domains that returned 403
  awk -F' ' '{ if ($2 == "403") print $1 }' "$output_folder/httpx_output.txt" > "$output_folder/ffuf_403_targets.txt"
  awk -F' ' '{ if ($2 >= 200 && $2 < 400) print $1 }' "$output_folder/httpx_output.txt" > "$output_folder/ffuf_good_response_targets.txt"

  if [ -s "$output_folder/ffuf_403_targets.txt" ]; then
    echo "✅ Performing fuzzing with ffuf on subdomains in parallel..."
    cat "$output_folder/ffuf_403_targets.txt" | xargs -I {} -P 10 sh -c 'DOMAIN={} ffuf -w words/words.txt -u "$DOMAIN/FUZZ.html" -mc 200,302 -o "$output_folder/ffuf_output_{}.txt"'
    # Sort and store unique results in a file
    sort -u "$output_folder/ffuf_output_"*.txt > "$output_folder/unique_domains.txt"
  elif [ -s "$output_folder/ffuf_good_response_targets.txt" ]; then
    sort -u "$output_folder/ffuf_good_response_targets.txt" > "$output_folder/unique_domains.txt"
  else
    echo "❌ File 'ffuf_403_targets.txt' is empty. Aborting fuzzing."
    echo "Just creating an empty unique_domains.txt file to not break recon"
    touch "$output_folder/unique_domains.txt"
  fi
  

  # Perform port scanning on subdomains
  echo "Performing port scanning with naabu..."
  naabu -l "$output_folder/subdomains.txt" -o "$output_folder/ports.txt"

  # # Fuzz the valid domains with ffuf
  # echo "Performing fuzzing with ffuf on valid domains..."
  # while IFS= read -r valid_domain; do
  #   ffuf -w words/words.txt -u "$valid_domain/FUZZ.html" -mc 200,302 -o "$output_folder/ffuf_valid_output.txt"
  #   ffuf -w words/eng_words.txt -u "$valid_domain/FUZZ.php" -mc 200,302 -o "$output_folder/ffuf_valid_output.txt"
  #   ffuf -w words/eng_words.txt -u "$valid_domain/FUZZ.zip" -mc 200,302 -o "$output_folder/ffuf_valid_output.txt"
  # done < "$output_folder/unique_domains.txt"

  # Run nuclei on valid domains
  echo "Running nuclei on valid domains..."
  while IFS= read -r valid_domain; do
    nuclei -target "$valid_domain" -t nuclei-templates/http/ -o "$output_folder/nuclei_output.txt"
  done < "$output_folder/unique_domains.txt"

  echo "✅ Reconnaissance completed for domain: $domain" | notify -provider-config $NOTIFY_PROVIDER_CONFIG_FILEPATH -bulk -id scan_status
}

# Read domains from a file
read_domains() {
  local domains_file=$1

  # Check if the domains file exists
  if [ ! -f "$domains_file" ]; then
    echo "Domains file not found: $domains_file"
    exit 1
  fi

  # Read domains line by line and perform reconnaissance
  while IFS= read -r domain; do
    output_folder="${domain//./_}"  # Replace dots with underscores to create the output folder name
    perform_recon "$domain" "$output_folder"
  done < "$domains_file"
}

# Main script
if [ $# -eq 0 ]; then
  echo "Please provide a file containing a list of domains."
  echo "Usage: ./recon_script.sh domains.txt"
  exit 1
fi

domains_file=$1
read_domains "$domains_file"
