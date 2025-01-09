# Renew CA certificate

# Paths to files
$caDir = "CA"
$configFile = "root_CA.conf"  # Path to your OpenSSL configuration file

# CA Certificate and Key Paths
$caCert = "root_CA_cert.crt"
$caKey = "root_key.pem"
$caCSR = "root_CA_request.csr"

# Generate file paths
$keyFile = Join-Path $caDir $caKey
$certFile = Join-Path $caDir $caCert
$csrFile = Join-Path $caDir $caCSR

# Generate root CA request
& openssl req -new -key $keyFile -out $csrFile -config $configFile

# Show generated CSR file
& openssl req -in $csrFile -text

# Self sign the CA certificate
& openssl x509 -req -in $csrFile -signkey $keyFile -out $certFile -days 3650 

# Show generated certificate
& openssl x509 -in $certFile -text

# Output the generated files
Write-Host "Generated CA Certificate: $certFile"
