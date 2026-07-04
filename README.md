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
  (Example: "You need 120 hosts → use /25")
- **Subnet splitting**
  (Example: split a /24 into multiple /26 or /28 subnets)
- **Export output to a text file**
  (Save results to disk in addition to the console)

✔ Works on:
- Windows PowerShell
- PowerShell Core (Linux & macOS)

---

## 📦 Installation

Clone the repository:
```bash
git clone https://github.com/YOUR-USERNAME/AzureSubnetCalculator.git
cd AzureSubnetCalculator
```

---

## 🚀 Usage

### Basic calculation
```powershell
./Azure-Subnet-Calculator.ps1 -CIDR 10.0.0.0/24
```

### With recommended CIDR for a given number of hosts
```powershell
./Azure-Subnet-Calculator.ps1 -HostsNeeded 120
```

### Split a larger subnet into smaller ones
```powershell
./Azure-Subnet-Calculator.ps1 -CIDR 10.0.0.0/24 -SplitSubnets 4
```

### Save the output to a text file
```powershell
./Azure-Subnet-Calculator.ps1 -CIDR 10.0.0.0/24 -OutputFile report.txt
```

You can combine `-OutputFile` with any of the other options — the console output is unchanged (colors and all), while a clean, plain-text copy is written to the specified file.

---

## 📌 Example Output

```
================ Azure Subnet Calculator ================

Network Address:   10.0.0.0
Broadcast Address: 10.0.0.255
Subnet Mask:       255.255.255.0
Prefix:            /24

Azure Reserved IPs:
  Gateway (.1):        10.0.0.1
  Reserved (.2):       10.0.0.2
  Reserved (.3):       10.0.0.3

Usable Host Range: 10.0.0.4 - 10.0.0.254
Azure Usable Hosts: 251

Total Hosts (raw): 256

===========================================================
```

---

## 🧰 Parameters

| Parameter       | Required | Description                                                        |
|-----------------|----------|----------------------------------------------------------------------|
| `-CIDR`         | No       | Subnet in CIDR notation (e.g., `10.0.0.0/24`)                        |
| `-HostsNeeded`  | No       | Number of hosts → script recommends the best-fitting CIDR            |
| `-SplitSubnets` | No       | Splits the given subnet into this many smaller subnets               |
| `-OutputFile`   | No       | Path to a text file where the output should also be saved            |

You must specify either `-CIDR` or `-HostsNeeded`.

---

## 📝 Versioning

This project uses semantic versioning: `MAJOR.MINOR.PATCH`

### v1.3.0 (2026-07-04)
- Added the option to save output optionally to an external text file (`-OutputFile` parameter)
- Console output now written through a shared helper that also logs a plain-text (color-free) copy when `-OutputFile` is used
- Output file is saved even when the script exits early due to CIDR validation errors

### v1.2.0 (2025-01-11)
- Added validation for invalid CIDR prefixes outside /0–/32
- Added Azure-specific validation for supported subnet masks (/8–/29)
- Improved error handling
- Updated documentation

---

## 👤 Author

Salvatore Cristaudo (az104tor)

---

## 📄 License

This project is licensed under the MIT License — feel free to use, modify, and distribute it.



