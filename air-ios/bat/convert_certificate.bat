
openssl x509 -in ios_distribution.cer -inform DER -out ios_distribution.pem -outform PEM

openssl pkcs12 -export -inkey mykey.key -in ios_distribution.pem -out ios_distribution.p12




