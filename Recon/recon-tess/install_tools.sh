#!/bin/bash

function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function check_all(){
  for tool in "${tools[@]}"; do
      # Check if the tool exists
      if command_exists "$tool"; then
        echo "✅ $tool installed successfully."
      else
        echo -e "\033[31;1;4mPlease install $tool manually.\033[0m"
      fi
  done
}

function install_go() {
    local go_version=$1
    # Check if Go is already installed
    if ! command_exists "go"; then
      # Download Go
      echo "Downloading Go version $go_version..."
      wget "https://golang.org/dl/go${go_version}.linux-amd64.tar.gz" -O go.tar.gz
      
      # Install Go
      echo "Installing Go..."
      sudo tar -C /usr/local -xzf go.tar.gz
      
      # Configure Go environment
      echo "Configuring Go environment..."
      echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
      echo 'export GOPATH=$HOME/go' >> ~/.profile
      echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.profile
      echo 'source ~/.profile' >> ~/.bashrc
      echo 'source ~/.profile' >> ~/.zshrc
      source ~/.profile
      
      # Verify the installation
      echo "Verifying Go installation..."
      go version
      echo "Go $go_version has been installed successfully!"
    fi  
}

function install_oneforall() {
    # Check if OneForAll is already installed
    if [[ -d "OneForAll" ]]; then
        echo "OneForAll is already installed. Skipping installation."
        return
    fi
    
    # Install required packages
    echo "Installing required packages..."
    sudo apt update
    sudo apt install -y git python3 python3-pip
    
    # Clone OneForAll repository
    echo "Cloning OneForAll repository..."
    git clone https://gitee.com/shmilylty/OneForAll.git
    cd OneForAll/
    
    # Install dependencies
    echo "Installing OneForAll dependencies..."
    python3 -m pip install -U pip setuptools wheel
    pip3 install -r requirements.txt
    
    echo "OneForAll has been installed successfully!"
    
    # Display help message
    echo "Running OneForAll..."elp
}

function install_amass() {
    if ! command_exists "amass"; then
      # Download Amass
      echo "Downloading Amass..."
      wget https://github.com/OWASP/Amass/releases/download/v3.23.2/amass_linux_amd64.zip -O amass.zip
      
      # Extract Amass
      echo "Extracting Amass..."
      unzip amass.zip
      
      # Move Amass binary to /usr/local/bin
      echo "Installing Amass..."
      sudo mv amass_Linux_amd64/amass /usr/local/bin/
    fi
}

function create_wordlists_dir() {
  if [ ! -d "$1" ]; then
    echo "Creating wordlists directory..."
    mkdir -p "$1"
  fi
}

function download_wordlists() {
    WORDLIST_DIRECTORY=$1
    create_wordlists_dir $WORDLIST_DIRECTORY
    # Check if the wordlists are already downloaded
    if [[ -f $WORDLIST_DIRECTORY/onelistforallshort.txt && -f $WORDLIST_DIRECTORY/english_words.txt && -f $WORDLIST_DIRECTORY/2m-subdomains.txt ]]; then
        echo "Wordlists are already downloaded. Skipping download."
        return
    fi
    
    # Download OneListForAll wordlist
    echo "Downloading OneListForAll wordlist..."
    wget https://raw.githubusercontent.com/six2dez/OneListForAll/main/onelistforallshort.txt -O $WORDLIST_DIRECTORY/onelistforallshort.txt

    # Download English Words wordlist
    echo "Downloading English Words wordlist..."
    wget https://raw.githubusercontent.com/dwyl/english-words/master/words.txt -O $WORDLIST_DIRECTORY/english_words.txt

    # Download 2M Subdomains wordlist
    echo "Downloading 2M Subdomains wordlist..."
    wget https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt -O $WORDLIST_DIRECTORY/2m-subdomains.txt
    
    echo "Wordlists have been downloaded successfully!"
}

function install_ffuf() {
  if ! command_exists "ffuf"; then
   go install github.com/ffuf/ffuf/v2@latest
  fi
}

function install_nuclei() {
  if ! command_exists "nuclei"; then
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest    
  fi
}

function install_naabu() {
  if ! command_exists "naabu"; then
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
  fi
}

function install_notify() {
  if ! command_exists "notify"; then
    go install -v github.com/projectdiscovery/notify/cmd/notify@latest
  fi
}

function install_anew() {
  if ! command_exists "anew"; then
    go install -v github.com/tomnomnom/anew@latest
  fi
}

function install_httpx() {
  if ! command_exists "httpx"; then
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  fi
}


sudo apt update -y && apt install -y libpcap-dev unzip
install_go "1.20.5"
install_oneforall
install_amass
download_wordlists "wordlists"
install_ffuf
install_nuclei
install_naabu
install_notify
install_anew
install_httpx
# List of tool names
tools=("amass" "naabu" "ffuf" "httpx" "anew" "notify" "nuclei")
check_all $tools