#include <stdio.h>
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/evp.h>

int gen_X509Req(void)
{
    int ret = 0;
    X509_REQ *x509_req = NULL;
    X509_NAME *x509_name = NULL;
    EVP_PKEY *pKey = NULL;
    BIO *out = NULL;

    const char *szCountry = "RO";
    const char *szProvince = "BUC";
    const char *szCity = "Bucharest";
    const char *szOrganization = "SAS";
    const char *szCommon = "AntonieSoga";
    const char *szEmail = "antonie.soga@stud.acs.pub.ro";
    const char *csrPath = "myx509Req.pem";
    const char *keyPath = "myGeneratedKey.pem";

    // 1. Generate RSA key
    EVP_PKEY_CTX *ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, NULL);
    if (!ctx) goto free_all;

    if (EVP_PKEY_keygen_init(ctx) <= 0) goto free_all;
    if (EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, 2048) <= 0) goto free_all;
    if (EVP_PKEY_keygen(ctx, &pKey) <= 0) goto free_all;
    EVP_PKEY_CTX_free(ctx);

    // 2. Create CSR
    x509_req = X509_REQ_new();
    if (!x509_req) goto free_all;

    X509_REQ_set_version(x509_req, 1);

    // 3. Set subject
    x509_name = X509_REQ_get_subject_name(x509_req);

    X509_NAME_add_entry_by_txt(x509_name, "C", MBSTRING_ASC,
        (const unsigned char*)szCountry, -1, -1, 0);
    X509_NAME_add_entry_by_txt(x509_name, "ST", MBSTRING_ASC,
        (const unsigned char*)szProvince, -1, -1, 0);
    X509_NAME_add_entry_by_txt(x509_name, "L", MBSTRING_ASC,
        (const unsigned char*)szCity, -1, -1, 0);
    X509_NAME_add_entry_by_txt(x509_name, "O", MBSTRING_ASC,
        (const unsigned char*)szOrganization, -1, -1, 0);
    X509_NAME_add_entry_by_txt(x509_name, "CN", MBSTRING_ASC,
        (const unsigned char*)szCommon, -1, -1, 0);
    X509_NAME_add_entry_by_txt(x509_name, "emailAddress", MBSTRING_ASC,
        (const unsigned char*)szEmail, -1, -1, 0);

    // 4. Set public key
    X509_REQ_set_pubkey(x509_req, pKey);

    // 5. Sign CSR
    ret = X509_REQ_sign(x509_req, pKey, EVP_sha256());
    if (ret <= 0) goto free_all;

    // 6. Save CSR to file
    out = BIO_new_file(csrPath, "w");
    if (!out) goto free_all;
    PEM_write_bio_X509_REQ(out, x509_req);
    BIO_free(out);
    out = NULL;

    // 7. Save private key to file
    out = BIO_new_file(keyPath, "w");
    if (!out) goto free_all;
    PEM_write_bio_PrivateKey(out, pKey, NULL, NULL, 0, NULL, NULL);
    BIO_free(out);
    out = NULL;

    ret = 1;

free_all:
    X509_REQ_free(x509_req);
    EVP_PKEY_free(pKey);
    if(out) BIO_free(out);

    return (ret == 1);
}

int main(void)
{
    if (gen_X509Req())
        printf("Certificate request and key generated successfully.\n");
    else
        printf("Failed to generate certificate request.\n");
    return 0;
}

