# Azure Subnet Calculator (PowerShell)
A simple and powerful PowerShell script that calculates Azure-compliant subnet information.  
This tool is designed to help cloud engineers, architects, students, and anyone working with Azure networking.

---

## ✨ Features

✔ Calculates standard subnet information:
- Network address  
- Broadcast address  
- Subnet mask  
- CIDR prefix  
- Total hosts  

✔ Azure-specific logic:
- Azure reserved IPs (.1 gateway, .2 + .3 reserved, broadcast, network)  
- Usable Azure host range  
- Azure usable hosts count  

✔ Advanced capabilities:
- **CIDR recommendation based on required host count**  
  (Example: “You need 120 hosts → use /25”)  
- **Subnet splitting**  
  (Example: split a /24 into multiple /26 or /28 subnets)  

✔ Works on:
- Windows PowerShell  
- PowerShell Core (Linux & macOS)  

---

## 📦 Installation

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/AzureSubnetCalculator.git
cd AzureSubnetCalculator


🚀 Usage
Basic calculation
./AzureSubnetCalculator.ps1 -CIDR 10.0.0.0/24

With recommended CIDR for a given number of hosts
./AzureSubnetCalculator.ps1 -Hosts 120

Split a larger subnet into smaller ones
./AzureSubnetCalculator.ps1 -CIDR 10.0.0.0/24 -Split 4

📌 Example Output
================ Azure Subnet Calculator ================

Network Address:   10.0.0.0
Broadcast Address: 10.0.0.255
Subnet Mask:       255.255.255.0
Prefix:            /24

Azure Reserved IPs:
  Gateway (.1):        10.0.0.1
  Reserved (.2):       10.0.0.2
  Reserved (.3):       10.0.0.3

Usable Host Range:     10.0.0.4 - 10.0.0.254
Azure Usable Hosts:    251

===========================================================

🧰 Parameters
Parameter	Required	Description
-CIDR	No	Subnet in CIDR notation (e.g., 10.0.0.0/24)
-Hosts	No	Number of hosts → script recommends best-fitting CIDR
-Split	No	Splits the given subnet into smaller subnets

You must specify either -CIDR or -Hosts.

📝 Versioning

This project uses semantic versioning:

MAJOR.MINOR.PATCH

👤 Author

Salvatore cristsudo (az104tor)

📄 License

This project is licensed under the MIT License — feel free to use, modify, and distribute it.
