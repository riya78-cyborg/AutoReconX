# AutoReconX
AutoReconX is a powerful Bash-based automation framework designed to streamline and scale your bug bounty recon and exploitation workflow. Rather than replacing manual testing, AutoReconX supercharges your initial reconnaissance, collecting valuable intel and reducing noise so you can focus on what's critical  exploitation and reporting.

AutoReconX 🕵️‍♀️
A fully automated, flow-based recon and exploitation tool for bug bounty hunters.

🔁 Flow-Based Workflow

Subfinder
   ↓
Live Host Discovery (httpx)
   ↓
Vulnerability Scanning on Live Targets (Nuclei)

Extract IPs for Port Scan (shodan) [I have premium one so i get mnore ip]
   ↓
Vulnerability Scanning on Live Targets (Nuclei)
   ↓
Archived URL Collection (waybackurls + gau)
   ↓
DAST Vulnerability Scan on Archived URLs (Nuclei - DAST templates)
   ↓
Google Dorking for Info Leak
   ↓
GitHub Dorking for Secrets / Tokens

# 🛠️ Requirements
Make sure these tools are in $GOPATH/bin:

subfinder, httpx, shodan, nuclei, waybackurls, google dork, github dork

# Usage 

bash recon.sh -u target.com
