#!/bin/bash
# =====================================================
# PKI Lab - Interactive CA, Server, and Client Creation
# Author: Antonie Soga
# =====================================================

KEYS_DIR=${1:-keys}
CONFIG_FILE=${2:-openssl.cnf}
EMAIL_DEFAULT="antonie.soga@stud.acs.pub.ro"

# === Verify environment ===
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[!] Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

if [ ! -d "$KEYS_DIR" ]; then
  echo "[!] Error: Keys directory '$KEYS_DIR' not found."
  exit 1
fi

echo "====================================================="
echo "     Interactive PKI Certificate Generator"
echo "====================================================="

# === Prompt user ===
read -p "Enter server identifier (default: 1): " SERVER_SUFFIX
SERVER_SUFFIX=${SERVER_SUFFIX:-1}
SERVER_CN="Antonie_Soga_server_${SERVER_SUFFIX}"

read -p "Enter server file name (default: server_${SERVER_SUFFIX}): " SERVER_FILE
SERVER_FILE=${SERVER_FILE:-server_${SERVER_SUFFIX}}

read -p "Enter client identifier (default: 1): " CLIENT_SUFFIX
CLIENT_SUFFIX=${CLIENT_SUFFIX:-1}
CLIENT_CN="Antonie_Soga_client_${CLIENT_SUFFIX}"

read -p "Enter client file name (default: client_${CLIENT_SUFFIX}): " CLIENT_FILE
CLIENT_FILE=${CLIENT_FILE:-client_${CLIENT_SUFFIX}}

echo
echo "[*] Using configuration:"
echo "Server CN: $SERVER_CN → $SERVER_FILE"
echo "Client CN: $CLIENT_CN → $CLIENT_FILE"
echo "====================================================="

# === Create CA if not exists ===
if [ ! -f "$KEYS_DIR/ca.key" ]; then
  echo "[*] Creating root CA..."
  openssl req -days 3650 -nodes -new -x509 \
    -keyout "$KEYS_DIR/ca.key" \
    -out "$KEYS_DIR/ca.crt" \
    -subj "/C=RO/ST=IF/L=Bucharest/O=UPB/OU=ACS/CN=Antonie_Soga_CA/emailAddress=$EMAIL_DEFAULT" \
    -config "$CONFIG_FILE"
else
  echo "[*] CA already exists, skipping..."
fi

# === Function to confirm overwriting files ===
confirm_overwrite() {
  local file="$1"
  if [ -f "$file" ]; then
    read -p "[!] File '$file' exists. Overwrite? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
      echo "    → Skipping existing file: $file"
      return 1
    fi
  fi
  return 0
}

# === Create Server Certificate ===
if confirm_overwrite "$KEYS_DIR/${SERVER_FILE}.crt"; then
  echo "[*] Generating server certificate..."
  openssl req -nodes -new \
    -keyout "$KEYS_DIR/${SERVER_FILE}.key" \
    -out "$KEYS_DIR/${SERVER_FILE}.csr" \
    -subj "/C=RO/ST=IF/L=Bucharest/O=UPB/OU=ACS/CN=$SERVER_CN/emailAddress=$EMAIL_DEFAULT" \
    -config "$CONFIG_FILE"

  openssl ca -batch -days 3650 \
    -out "$KEYS_DIR/${SERVER_FILE}.crt" \
    -in "$KEYS_DIR/${SERVER_FILE}.csr" \
    -extensions server \
    -config "$CONFIG_FILE"

  rm -f "$KEYS_DIR"/*.old "$KEYS_DIR/${SERVER_FILE}.csr"
else
  echo "[!] Server certificate skipped."
fi

# === Create Client Certificate ===
if confirm_overwrite "$KEYS_DIR/${CLIENT_FILE}.crt"; then
  echo "[*] Generating client certificate..."
  openssl req -nodes -new \
    -keyout "$KEYS_DIR/${CLIENT_FILE}.key" \
    -out "$KEYS_DIR/${CLIENT_FILE}.csr" \
    -subj "/C=RO/ST=IF/L=Bucharest/O=UPB/OU=ACS/CN=$CLIENT_CN/emailAddress=$EMAIL_DEFAULT" \
    -config "$CONFIG_FILE"

  openssl ca -batch -days 3650 \
    -out "$KEYS_DIR/${CLIENT_FILE}.crt" \
    -in "$KEYS_DIR/${CLIENT_FILE}.csr" \
    -extensions server \
    -config "$CONFIG_FILE"

  rm -f "$KEYS_DIR"/*.old "$KEYS_DIR/${CLIENT_FILE}.csr"
else
  echo "[!] Client certificate skipped."
fi

# === Verify Certificates ===
if [ -f "$KEYS_DIR/${SERVER_FILE}.crt" ]; then
  openssl verify -CAfile "$KEYS_DIR/ca.crt" "$KEYS_DIR/${SERVER_FILE}.crt"
fi
if [ -f "$KEYS_DIR/${CLIENT_FILE}.crt" ]; then
  openssl verify -CAfile "$KEYS_DIR/ca.crt" "$KEYS_DIR/${CLIENT_FILE}.crt"
fi

echo
echo "====================================================="
echo "[✓] PKI setup complete."
echo "CA: $KEYS_DIR/ca.crt"
echo "Server: $KEYS_DIR/${SERVER_FILE}.crt"
echo "Client: $KEYS_DIR/${CLIENT_FILE}.crt"
echo "====================================================="

