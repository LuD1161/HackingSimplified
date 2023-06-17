## Installing masscan
```bash
sudo apt-get install -y git gcc make libpcap-dev
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make -j
# Move this to /usr/local/bin/ so that it's in the $PATH
mv bin/masscan /usr/local/bin/

masscan -iL $ipFile -p1-65535 --rate=10000 -oL $outputFile | tee -a $resultDir/log.txt
sed -i -e "/#/d" -e "/^$/d" $outputFile
cut -d" " -f3,4 $outputFile | awk '{print($2","$1)}' | sort -V > $resultDir/$domain.masscan-sorted.txt
```

## Installing Docker ( Prerequisite for RustScan )
Taken from : [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

## Installing RustScan
```bash
docker run -it --rm --name rustscan rustscan/rustscan:alpine -h
# Add this alias to your ~/.bashrc or ~/.zshrc
alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:alpine'
```

## Installing naabu
Taken from [here](https://github.com/projectdiscovery/naabu#from-source)
```bash
GO111MODULE=on go get -v github.com/projectdiscovery/naabu/cmd/naabu
```
If the above gives error use the [binary approach](https://github.com/projectdiscovery/naabu#from-binary)
