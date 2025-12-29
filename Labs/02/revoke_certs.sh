#!/bin/bash
# =====================================================
#  Certificate Revocation Script (Antonie Soga PKI)
# =====================================================

KEYS_DIR="keys"
CONFIG_FILE="openssl.cnf"
CA_KEY="$KEYS_DIR/ca.key"
CA_CERT="$KEYS_DIR/ca.crt"
CRL_FILE="$KEYS_DIR/crl.pem"

echo "====================================================="
echo "   Certificate Revocation Script"
echo "====================================================="

# --- Check environment ---
if [ ! -d "$KEYS_DIR" ]; then
  echo "[!] Error: Keys directory '$KEYS_DIR' not found."
  exit 1
fi

if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CERT" ]; then
  echo "[!] Error: CA key or certificate missing in '$KEYS_DIR'."
  exit 1
fi

# --- Find certs to revoke ---
CERT_FILES=($(find "$KEYS_DIR" -maxdepth 1 -type f -name "*.crt" ! -name "ca.crt" -exec basename {} \;))

if [ ${#CERT_FILES[@]} -eq 0 ]; then
  echo "[!] No certificates found to revoke."
  exit 0
fi

echo "Available certificates:"
i=1
for cert in "${CERT_FILES[@]}"; do
  echo "  $i. $cert"
  ((i++))
done

read -p $'\nEnter the numbers of certificates to revoke (e.g. 1 3 5): ' selections

if [ -z "$selections" ]; then
  echo "[!] No selection made. Exiting."
  exit 0
fi

read -p "Are you sure you want to revoke the selected certificates? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "[-] Operation canceled."
  exit 0
fi

# --- Revoke selected certs ---
for num in $selections; do
  cert="${CERT_FILES[$((num-1))]}"
  if [ -z "$cert" ]; then
    echo "[!] Invalid selection: $num"
    continue
  fi

  echo "[*] Revoking $cert..."
  openssl ca -config "$CONFIG_FILE" -revoke "$KEYS_DIR/$cert" -keyfile "$CA_KEY" -cert "$CA_CERT" || {
    echo "[!] Failed to revoke $cert."
    continue
  }
done

echo "[*] Generating new CRL..."
openssl ca -config "$CONFIG_FILE" -gencrl -keyfile "$CA_KEY" -cert "$CA_CERT" -out "$CRL_FILE"

echo ""
echo "====================================================="
echo "[✓] Revocation complete!"
echo "Updated CRL saved as: $CRL_FILE"
echo "====================================================="

# --- Verify revocation ---
echo ""
echo "[*] Verifying revoked certificates against CRL..."
for num in $selections; do
  cert="${CERT_FILES[$((num-1))]}"
  [[ -z "$cert" ]] && continue

  openssl verify -CAfile "$CA_CERT" -crl_check "$KEYS_DIR/$cert" 2>/dev/null 1>/dev/null
  if [ $? -ne 0 ]; then
    echo "  [✗] $cert is REVOKED (confirmed by CRL)"
  else
    echo "  [✓] $cert is still VALID"
  fi
done

echo ""
echo "====================================================="
echo "To inspect CRL manually, run:"
echo "  openssl crl -in $CRL_FILE -noout -text"
echo "====================================================="

