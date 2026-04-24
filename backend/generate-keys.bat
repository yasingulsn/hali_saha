@echo off
REM RSA-256 key pair olusturma (JWT icin)
REM Bu script'i bir kere calistirmaniz yeterlidir.
REM OpenSSL kurulu olmalidir. (Git for Windows ile gelir)

cd src\main\resources

REM Private key olustur
openssl genrsa -out privateKey.pem 2048

REM Public key olustur
openssl rsa -in privateKey.pem -pubout -out publicKey.pem

echo.
echo === RSA Key Pair Olusturuldu ===
echo Private Key: src\main\resources\privateKey.pem
echo Public Key:  src\main\resources\publicKey.pem
echo.
echo UYARI: privateKey.pem dosyasini ASLA Git'e commitlemeyiniz!
pause
