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

OUTPUT_DIR="${DOMAIN}-recon"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[+] Target: $DOMAIN${NC}"

echo -e "${GREEN}[+] Running Subfinder...${NC}"
subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subdomains.txt"

echo -e "${GREEN}[+] Running HTTPX...${NC}"
cat "$OUTPUT_DIR/subdomains.txt" | httpx -silent | tee "$OUTPUT_DIR/httpx.txt"

echo -e "${GREEN}[+] Running Nuclei (main scan)...${NC}"
nuclei -l "$OUTPUT_DIR/httpx.txt" -o "$OUTPUT_DIR/nuclei-output.txt"

echo -e "${GREEN}[+] Fetching Wayback URLs...${NC}"
waybackurls "$DOMAIN" | tee "$OUTPUT_DIR/wayback.txt"

echo -e "${GREEN}[+] Running Nuclei DAST on Wayback URLs...${NC}"
nuclei -l "$OUTPUT_DIR/wayback.txt" -dast -t /Users/cyborg/BugBounty/Tools/fuzzing-templates/ -o "$OUTPUT_DIR/dast-result.txt"

echo -e "${GREEN}[+] Searching Shodan for domain IPs...${NC}"
shodan search "ssl:'$DOMAIN'" --fields ip_str --limit 1000 > "$OUTPUT_DIR/shodan.txt"

echo -e "${GREEN}[+] Running Nuclei on Shodan IPs...${NC}"
nuclei -l "$OUTPUT_DIR/shodan.txt" -o "$OUTPUT_DIR/ip-nuclei.txt"

echo -e "${GREEN}[+] Google Dorking Links:${NC}"
echo "https://www.google.com/search?q=site:$DOMAIN+ext:env+OR+ext:log+OR+ext:bak+OR+ext:sql" > "$OUTPUT_DIR/google-dorks.txt"
echo "https://www.google.com/search?q=site:$DOMAIN+inurl:admin+OR+inurl:login" >> "$OUTPUT_DIR/google-dorks.txt"
echo "https://www.google.com/search?q=site:$DOMAIN+intitle:index.of" >> "$OUTPUT_DIR/google-dorks.txt"
cat "$OUTPUT_DIR/google-dorks.txt"

echo -e "${GREEN}[+] GitHub Dorking Links:${NC}"
echo "https://github.com/search?q=$DOMAIN" > "$OUTPUT_DIR/github-dorks.txt"
echo "https://github.com/search?q=$DOMAIN+password" >> "$OUTPUT_DIR/github-dorks.txt"
echo "https://github.com/search?q=$DOMAIN+secret" >> "$OUTPUT_DIR/github-dorks.txt"
echo "https://github.com/search?q=$DOMAIN+api_key" >> "$OUTPUT_DIR/github-dorks.txt"
cat "$OUTPUT_DIR/github-dorks.txt"

echo -e "${GREEN}[+] Recon complete! All results in: $OUTPUT_DIR${NC}"

