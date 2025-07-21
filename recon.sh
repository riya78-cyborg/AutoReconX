#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

while getopts ":u:" opt; do
  case $opt in
    u)
      DOMAIN=$OPTARG
      ;;
    \?)
      echo -e "${GREEN}Usage: $0 -u <domain>${NC}"
      exit 1
      ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  echo -e "${GREEN}Usage: $0 -u <domain>${NC}"
  exit 1
fi

echo -e "${GREEN}[+] Target: $DOMAIN${NC}"

echo -e "${GREEN}[+] Running Subfinder...${NC}"
subfinder -d "$DOMAIN" -o subdomains.txt

echo -e "${GREEN}[+] Running HTTPX...${NC}"
cat subdomains.txt | httpx -silent | tee httpx.txt

echo -e "${GREEN}[+] Running Nuclei (main scan)...${NC}"
nuclei -l httpx.txt -o nuclei-output.txt

echo -e "${GREEN}[+] Fetching Wayback URLs...${NC}"
waybackurls "$DOMAIN" | tee wayback.txt

echo -e "${GREEN}[+] Running Nuclei DAST on Wayback URLs...${NC}"
nuclei -l wayback.txt -dast -t /Users/cyborg/BugBounty/Tools/fuzzing-templates/  -o dast-result.txt

echo -e "${GREEN}[+] Searching Shodan for domain IPs...${NC}"
shodan search "ssl:'$DOMAIN'" --fields ip_str --limit 1000 > shodan.txt

echo -e "${GREEN}[+] Running Nuclei on Shodan IPs...${NC}"
nuclei -l shodan.txt -o ip-nuclei.txt

echo -e "${GREEN}[+] Recon complete! Outputs saved.${NC}"
