## Setting up DNSValidator and getting list of 50 resolvers aka 50resolvers.txt

```sh
git clone https://github.com/vortexau/dnsvalidator.git
cd dnsvalidator
python3 setup.py install
dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 200 -o resolvers.txt
sort -R resolvers.txt | tail -n 50 > 50resolvers.txt
```

### Download Amass : 
`wget "https://github.com/OWASP/Amass/releases/download/v3.7.3/amass_linux_amd64.zip"`

### Passive Recon :
`amass enum -passive -d hackerone.com -src -dir h1_amass -o output_h1.txt -rf 50resolvers.txt`

### Active Recon :
`amass enum -active -d hackerone.com -src -dir h1_amass -o output_h1_active.txt -rf 50resolvers.txt`

### Track : 
`amass track -config /root/amass/config.ini -dir h1_amass -d hackerone.com`

### Viz : 
`amass viz -d3 -dir h1_amass`


### Run python server :
`cd h1_amass && python3 -m http.server`

Now go to your VPS_IP:8000

#### Finding your VPS's IP :
`ip addr`

`curl ifconfig.co`

https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-programming-environment-on-an-ubuntu-20-04-server

```
sudo apt update -y

sudo apt upgrade -y
```
