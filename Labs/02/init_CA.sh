#!/bin/bash
# =====================================================
# PKI Lab - Step 1 & 2: Initialize CA Environment
# Author: Antonie Soga
# =====================================================

# === Configuration (you can change these if needed) ===
KEYS_DIR=${1:-keys}  # default directory is "keys", can override via argument
EMAIL_DEFAULT="antonie.soga@stud.acs.pub.ro"

# === Step 1: Create CA directory structure ===
echo "[*] Initializing CA directory at: $KEYS_DIR"

mkdir -p "$KEYS_DIR"
touch "$KEYS_DIR/index.txt"
echo "01" > "$KEYS_DIR/serial"

# === Step 2: Create openssl.cnf configuration file ===
echo "[*] Generating openssl.cnf configuration file..."

cat > openssl.cnf <<EOF
###############################################################################
RANDFILE        = .rnd

###############################################################################
[ ca ]
default_ca      = CA_default            # The default ca section

###############################################################################
[ CA_default ]
dir             = $KEYS_DIR             # Where everything is kept
certs           = \$dir                 # Where the issued certs are kept
crl_dir         = \$dir                 # Where the issued crl are kept
database        = \$dir/index.txt       # database index file.
new_certs_dir   = \$dir                 # default place for new certs.
certificate     = \$dir/ca.crt          # The CA certificate
serial          = \$dir/serial          # The current serial number
crl             = \$dir/crl.pem         # The current CRL
private_key     = \$dir/ca.key          # The private key
RANDFILE        = \$dir/.rand           # private random number file
x509_extensions = basic_exts            # The extentions to add to the cert
crl_extensions  = crl_ext               # This allows a V2 CRL

default_days    = 3650                  # how long to certify for
default_crl_days= 30                    # how long before next CRL
default_md      = sha256                # use public key default MD
preserve        = no                    # keep passed DN ordering

policy          = policy_anything

###############################################################################
# For the 'anything' policy, which defines allowed DN fields
[ policy_anything ]
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
name                   = optional
emailAddress           = optional

###############################################################################
# Request handling
[ req ]
default_bits        = 2048
default_keyfile     = privkey.pem
default_md          = sha256
distinguished_name  = org   # org | cn_only
x509_extensions     = myca  # The extentions to add to the self signed cert

###############################################################################
# DN for cn_only support:
[ cn_only ]
commonName          = Common Name (eg: your user, host, or server name)
commonName_max      = 64
commonName_default  = certificate

###############################################################################
# DN for org support:
[ org ]
countryName                    = Country Name (2 letter code)
countryName_default            = RO
countryName_min                = 2
countryName_max                = 2

stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = IF

localityName                   = Locality Name (eg, city)
localityName_default           = Bucharest

0.organizationName             = Organization Name (eg, company)
0.organizationName_default     = UPB

organizationalUnitName         = Organizational Unit Name (eg, section)
organizationalUnitName_default = ACS

commonName                     = Common Name (eg: your user, host, or server name)
commonName_max                 = 64
commonName_default             = certificate

emailAddress                   = Email Address
emailAddress_default           = $EMAIL_DEFAULT
emailAddress_max               = 64

###############################################################################
# Cert extension handling
[ basic_exts ]
basicConstraints        = CA:FALSE
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer:always

# The CA extensions
[ myca ]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer:always
basicConstraints        = CA:true
keyUsage                = cRLSign, keyCertSign # Limit key usage to CA tasks.

# The server extensions
[ server ]
basicConstraints         = CA:FALSE
nsCertType               = server
subjectKeyIdentifier     = hash
authorityKeyIdentifier   = keyid,issuer:always
extendedKeyUsage         = serverAuth
keyUsage                 = digitalSignature, keyEncipherment

###############################################################################
# CRL extensions.
[ crl_ext ]
authorityKeyIdentifier  = keyid:always,issuer:always
EOF

# === Step 3: Confirmation ===
echo "[✓] CA environment initialized successfully!"
echo "    - Directory: $KEYS_DIR"
echo "    - Config: $(pwd)/openssl.cnf"

