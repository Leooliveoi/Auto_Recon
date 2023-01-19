# Auto_Recon
A tool to automate some first reconnaissance on web servers

This tool is developed for linux debian based, such as Kali Linux.

## Introduction

The main pourpose of this tool is to automatize some proccess on the first recon on web servers.
Can be useful in bugbounty programs, or web pentest and similar.

## Instalation 
### Download
``` git clone https://github.com/Leooliveoi/Auto_Recon.git ```

### Change directory
``` cd Auto_Recon ```

### X Privileges
``` chmod +x recon_automaton.sh ```

### Usage

``` ./recon_automaton.sh <domain>```

if is interesting for you, move the script to the bin path

``` sudo mv recon_automaton.sh /usr/bin/ ```


By default this tool uses some other tools:
- subfinder
- aquatone
- httprobe
- ffuf
- nuclei

PS. Take a note that this is the first version of this tool and some bug can appear, and a bunch of improvements is necessary, feel free to send ideias and fix.
