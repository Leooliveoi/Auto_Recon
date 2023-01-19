#!/bin/bash

echo "                                                                                      "
echo " █████╗ ██╗   ██╗████████╗ ██████╗         ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗"
echo "██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗        ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║"
echo "███████║██║   ██║   ██║   ██║   ██║        ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║"
echo "██╔══██║██║   ██║   ██║   ██║   ██║        ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║"
echo "██║  ██║╚██████╔╝   ██║   ╚██████╔╝███████╗██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║"
echo "╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝"
echo "                                                                                      "






echo -e "\n-------------------------------------------------------------\n"
echo "Please use the following command"
echo "$ $0 <domain>"
echo -e  "\n"
echo "EXAMPLE"
echo "$0 linktr.ee"
echo -e "\n-------------------------------------------------------------\n"
echo "Some folder and files will be created"
echo -e "\n-------------------------------------------------------------\n"
echo "Some binaries are necessary to run this script:"
echo "---> Subfinder: https://github.com/projectdiscovery/subfinder/releases"
echo "---> Ffuf : Kali BuildIn"
echo "---> Httprobe: https://github.com/tomnomnom/httprobe"
echo "---> Aquatone: https://github.com/michenriksen/aquatone"
echo "---> Nuclei: https://github.com/projectdiscovery/nuclei"
echo -e "\n-------------------------------------------------------------\n"



##################################################### FOLDERS AND VARIABLES #####################################################

### Variables ### 
DOMAIN=$1
nuclei_takeover_template="/home/$USER/nuclei-templates/takeovers"
browser_path="/usr/bin/brave-browser"
api_endpoint_path="/usr/share/wordlists/SecLists/Discovery/Web-Content/api/api-endpoints.txt"
dirsearch_path="/usr/share/wordlists/SecLists/Discovery/Web-Content/dirsearch.txt"

### Folder Path ###
FPATH="auto_recon"
# Creating direcories to save files
echo "CREATING FOLDERS ..."
mkdir $FPATH; echo "$FPATH created!"
mkdir $FPATH/ffuf ; echo "$FPATH/ffuf created!"
mkdir $FPATH/ffuf/paths; echo "$FPATH/ffuf/paths created!"
mkdir $FPATH/aquatone; echo "$FPATH/aquatone created!"


echo -e "\n\n"
echo "##################################################### -----------> $1 <----------- #####################################################"
echo -e "\n\n"
##################################################### SUBFINDER #####################################################
# Subdomain finder and http probe to verify if a subdomain is reachable

echo "-------------------------------------------------------------"
echo "SUBFINDER..."

subfinder -d $1 -o $FPATH/$1_subdomains.subfinder | httprobe | grep "http" >> $FPATH/$1_probe.httprobe



##################################################### NUCLEI #####################################################
# Nuclei Template for Domain TakeOver
# Make sure that the nuclei binarie is in the system PATH such as /usr/bin/

echo "NUCLEI TAKEOVERS..."

nuclei -t $nuclei_takeover_template -l $FPATH/$1_probe.httprobe -o $FPATH/$1_takeovers.nuclei -c 200



##################################################### AQUATONE #####################################################
# Aquatone for take screenshots from active webpages

echo "-------------------------------------------------------------"
echo "AQUATONE..."
echo "if the aquatone return a browser error, try to add the required argument directly on this script source-code ${browser_path}!"
echo "for example: $ where brave-browser"

cat $FPATH/$1_probe.httprobe | aquatone -chrome-path=$browser_path -out ./$FPATH/aquatone/


##################################################### FFUF API ENDPOINT AND DIRSEARCH #####################################################
# Fuzzing for common web paths/files CAN BE VERY SLOOOOOW

echo "-------------------------------------------------------------"
echo "FFUF..."

# loop to read all url on the file
for i in $(cat $FPATH/$1_probe.httprobe);
do
# Will cat the file with the URLs and fuzzing the first path (http[s]://www.example.com/FUZZ)

host=$(sed 's/\:\/\//_/g' <<< $i)


ffuf -r -u $i/FUZZ -w $api_endpoint_path >> $FPATH/ffuf/${host}_fuzzing_API.ffuf;


# Creating a folder for each host and saving the found paths filtered by status code.
mkdir $FPATH/ffuf/paths/${host}_API
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 1[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_API/paths_code_1xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 2[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_API/paths_code_2xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 3[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_API/paths_code_3xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 4[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_API/paths_code_4xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 5[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_API/paths_code_5xx.txt



ffuf -r -u $i/FUZZ -w $dirsearch_path >> $FPATH/ffuf/${host}_fuzzing_dirsearch.ffuf;


# Creating a folder for each host and saving the found paths filtered by status code.
mkdir $FPATH/ffuf/paths/${host}_dirsearch
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 1[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_dirsearch/paths_code_1xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 2[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_dirsearch/paths_code_2xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 3[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_dirsearch/paths_code_3xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 4[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_dirsearch/paths_code_4xx.txt
cat $FPATH/ffuf/${host}_fuzzing_API.ffuf | grep -e 'Status: 5[0-9][0-9]' | cut -d " " -f1 >> $FPATH/ffuf/paths/${host}_dirsearch/paths_code_5xx.txt


done


