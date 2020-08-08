#!/bin/bash

if [ -z "$2" ]
  then
    echo "2nd argument not supplied"
    echo "2nd argument is the resolver file list path"
    echo "Usage : ./master_script.sh domain resolvers_list"
    exit 1
fi

domain=$1
resolversFile=$2
dt=$(date +%F.%H.%M.%S)
toolsDir=~/tools
resultDir=$toolsDir/results/$domain-$dt
mkdir -p $resultDir

#### COLORS #### ( Taken from : https://misc.flogisoft.com/bash/tip_colors_and_formatting )
NORMAL='\e[0m'
RED='\e[31m'
LIGHT_GREEN='\e[92m'
LIGHT_YELLOW='\e[93m'
BLINK='\e[5m'
BOLD='\e[1m'
UNDERLINE='\e[4m'
###############

#### Starting amass scanning ####
start_amass(){
    amassScreen=$domain-amass
    amassOutput=$resultDir/amass_$domain.txt
    screen -dmS $amassScreen bash
    sleep 1
    screen -S $amassScreen -X stuff "amass enum -passive -d $domain -src -dir $resultDir/$domain\_amass -o $amassOutput -rf $resolversFile
    "
}
#### End amass scanning ####

#### Starting subfinder scanning ####
start_subfinder(){
    subfinderScreen=$domain-subfinder
    subfinderOutput=$resultDir/subfinder_$domain.txt
    screen -dmS $subfinderScreen bash
    sleep 1
    screen -S $subfinderScreen -X stuff "subfinder -nW -d $domain -rL $resolversFile -o $subfinderOutput
    "
}
#### End subfinder scanning ####

#### Starting assetfinder scanning ####
start_assetfinder(){
    assetfinderScreen=$domain-assetfinder
    assetfinderOutput=$resultDir/assetfinder_$domain.txt
    screen -dmS $assetfinderScreen bash
    sleep 1
    screen -S $assetfinderScreen -X stuff "assetfinder $domain > $assetfinderOutput
    "
}
#### End assetfinder scanning ####

#### Starting findomain scanning ####
start_findomain(){
    findomainScreen=$domain-findomain
    findomainOutput=$resultDir/findomain_$domain.txt
    screen -dmS $findomainScreen bash
    sleep 1
    screen -S $findomainScreen -X stuff "findomain -o -t $domain --resolvers $resolversFile --threads 40
    "
}
#### End findomain scanning ####

find_subdomains(){
    start_amass
    start_subfinder
    start_assetfinder
    start_findomain
}

find_subdomains

###### Check for completion ######

STARTTIME=$(date +%s)
echo -e "${LIGHT_YELLOW}Checking whether subdomain collection finished working${NORMAL}"
while : ;
do
    sleep 5s # sleep for 5 seconds before again checking
    if [ ! `pidof subfinder` ] && [ ! `pidof amass` ] && [ ! `pidof assetfinder` ] && [ ! `pidof findomain` ]; then
        # kill both screens
        screen -X -S $subfinderScreen quit
        screen -X -S $amassScreen quit
        screen -X -S $assetfinderScreen quit
        screen -X -S $findomainScreen quit
        # Move findomain output
        mv $domain.txt $findomainOutput

        # Put sorted results of both in one file
        sort -u $subfinderOutput $amassOutput $assetfinderOutput $findomainOutput > $resultDir/$domain.subdomains.txt
        echo -en "\rTime elapsed : $totalTime seconds"
        break;
    fi
    ENDTIME=$(date +%s)
    totalTime=$(( $ENDTIME-$STARTTIME ))
    echo -en "\rTime elapsed : ${BLINK}${LIGHT_GREEN}$totalTime${NORMAL} seconds"
done
########################################################################

echo ""

echo -e "${BOLD}${LIGHT_GREEN}Done finding subdomains${NORMAL}"
echo -e "${BOLD}${LIGHT_GREEN}Total unique subdomains found : `wc -l $resultDir/$domain.subdomains.txt`${NORMAL}"
echo -e "Results in : ${LIGHT_GREEN}$resultDir${NORMAL}"
echo -e "${LIGHT_GREEN}" && tree $resultDir && echo -en "${NORMAL}"

