#!/bin/bash
# RSA-256 key pair olusturma (JWT icin)
# Bu script'i bir kere calistirmaniz yeterlidir.

cd src/main/resources

# Private key olustur
openssl genrsa -out privateKey.pem 2048

# Public key olustur
openssl rsa -in privateKey.pem -pubout -out publicKey.pem

echo ""
echo "=== RSA Key Pair Olusturuldu ==="
echo "Private Key: src/main/resources/privateKey.pem"
echo "Public Key:  src/main/resources/publicKey.pem"
echo ""
echo "UYARI: privateKey.pem dosyasini ASLA Git'e commitlemeyiniz!"
