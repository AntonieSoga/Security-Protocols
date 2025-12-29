# 🛡️Security Protocols
A comprehensive repository containing implementation, configuration, and analysis for modern security standards. This project covers the full spectrum of security—from cryptographic foundations and PKI to network intrusion detection and web exploitation.

<p align="center">
  <img width="400" height="200" alt="image" src="https://github.com/user-attachments/assets/19a25330-430b-4bc4-bb65-43bfeba2f5e3" />
</p>

## 📑 Table of Contents
  - 🛠️ Technology Stack
  - 🔐 Module 1: Cryptography & PKI
  - 🌐 Module 2: Secure Communication (VPN & SSL)
  - 📡 Module 3: Wireless Security
  - 🔍 Module 4: Traffic Analysis & NIDS
  - ⚔️ Module 5: Web Attacks & Identity
  - 🚀 Getting Started
---

### 🛠️ Technology Stack
#### Category	Tools & Protocols
| Category        | Tools & Protocols                                   |
|-----------------|------------------------------------------------------|
| Cryptography    | OpenSSL, X.509, PKCS12, JWT                           |
| Networking      | OpenVPN, IPsec, Wireshark, Iptables                  |
| Wireless        | Aircrack-ng, Reaver, 802.11 standards                |
| Defense         | Snort (NIDS/NIPS), ACLs, DPI                         |
| Exploitation    | Kali Linux, SSLStrip, DVWA, SQLMap                   |

### 🔐 Module 1: Cryptography & PKI

Labs 1 & 2 focus on the identity layer of the internet.
Digital Certificates (X.509)

#### Exploration of public-key ownership via digital documents.

  - Key Fields: Serial Number, Issuer, Subject, Validity, and Extensions.
  - OpenSSL Usage: Generating RSA keys and Certificate Signing Requests (CSR).

```bash
openssl req -new -newkey rsa:2048 -nodes -keyout mykey.pem -out myreq.pem
```
#### Public Key Infrastructure (PKI)

Building a private Certificate Authority (CA) to manage the lifecycle of trust.
  - Tasks: Creating a Root CA, signing server/client certificates, and managing Revocation Lists (CRL).
  - Automated PKI: Bash scripts for rapid certificate issuance.

---

### 🌐 Module 2: Secure Communication (VPN & SSL)

Labs 3 & 4 cover the protocols that keep data in transit private.
#### Virtual Private Networks (VPN)
  - OpenVPN: Implementing SSL/TLS-based tunneling with virtual tun0 interfaces.
  - IPsec: End-to-end encryption at the Network Layer.
  - Lab Goal: Configuring a site-to-site tunnel and troubleshooting NAT traversal.

#### SSL/TLS Protocol
Deep dive into the handshake process.
  - MITM Attacks: Using Kali Linux and sslstrip to downgrade HTTPS traffic.
  - Programming: A C-based HTTPS client using libssl-dev to perform secure GET requests.

---

### 📡 Module 3: Wireless Security
Lab 5 explores the vulnerabilities of the 802.11 standard.
  - WEP/WPA Cracking: Capturing IVs and using dictionary attacks via aircrack-ng.
  - WPS Flaws: Brute-forcing PINs using reaver.
  - Defense: Why MAC filtering and SSID hiding are insufficient security measures.

---
    
### 🔍 Module 4: Traffic Analysis & NIDS
Labs 7 & 8 focus on monitoring and defense.
Snort: Real-time & Offline Analysis

#### Implementation of a Network Intrusion Detection System.
  - DPI (Deep Packet Inspection): Beyond port-based filtering to payload analysis.
  - Ruleset Creation:
  - Example: Detecting malware keywords in HTTP traffic
  ```snort
    alert tcp any any -> any 80 (msg:"Malware keyword detected"; content:"malware"; sid:1000002;)
  ```
  - PCAP Analysis: Forensic analysis of Heartbleed attacks and Hydra FTP brute-forcing.

---

### ⚔️ Module 5: Web Attacks & Identity
Labs 6 & 9 cover application-level security.
#### OAuth 2.0 & OpenID Connect
  - Implementation: Integrating "Login with Google" into a web application.
  - Security: Understanding JWT (JSON Web Tokens) and token revocation.

#### Web Exploitation (DVWA)
Hands-on exploitation of "Damn Vulnerable Web App" in a Docker environment.
  - SQL Injection: Bypassing authentication and dumping database schemas.
  - XSS (Cross-Site Scripting): Stealing session cookies via injected scripts.
  - Buffer Overflow: Overwriting the stack to redirect execution flow.
