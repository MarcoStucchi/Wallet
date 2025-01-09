# Generates client key pair and assoociate certificate

# Paths to files
$serialFile = "serial.txt"
$keyDir = "keys"
$certDir = "certs"
$configFile = "client_CSR.conf"  # Path to your OpenSSL configuration file

# CA Certificate and Key Paths
$caCert = "CA/root_CA_cert.crt"
$caKey = "CA/root_key.pem"

# Ensure directories exist
if (-Not (Test-Path $keyDir)) { New-Item -ItemType Directory -Path $keyDir }
if (-Not (Test-Path $certDir)) { New-Item -ItemType Directory -Path $certDir }

# Read or initialize the current serial number
if (-Not (Test-Path $serialFile)) {
    Set-Content -Path $serialFile -Value "1000"  # Initialize serial file if it doesn't exist
}
$serial = Get-Content -Path $serialFile

# Prompt for the Common Name
$commonName = Read-Host "Enter the Common Name (CN) for the certificate"

# Generate file paths
$keyFile = Join-Path $keyDir "private_$serial.pem"
$certFile = Join-Path $certDir "certificate_$serial.crt"
$certfileBinary = Join-Path $certDir "certificate_$serial.der"

# Generate a private key
& openssl genpkey -algorithm RSA -out $keyFile -pkeyopt rsa_keygen_bits:2048

# Generate a temporary configuration file to include the dynamic Common Name
$tempConfigFile = "temp_openssl.conf"
Get-Content $configFile | ForEach-Object {
    if ($_ -match "CN\s*=") {
        "CN = $commonName"  # Replace the Common Name line dynamically
    } else {
        $_
    }
} | Set-Content $tempConfigFile

# Generate a certificate request (CSR) using the temporary configuration file
& openssl req -new -key $keyFile -out "request.csr" -config $tempConfigFile

# Issue a certificate signed by the CA
& openssl x509 -req -in "request.csr" -CA $caCert -CAkey $caKey -out $certFile -days 365 -set_serial 0x$serial -extfile v3.ext

# Generate certificate in binary DER format
& openssl x509 -in $certFile -outform der -out $certfileBinary

# Increment the serial number
$newSerial = "{0:X}" -f ([convert]::ToInt32($serial, 16) + 1)
Set-Content -Path $serialFile -Value $newSerial

# Cleanup CSR and temporary files
Remove-Item "request.csr"
Remove-Item $tempConfigFile

# Output the generated files
Write-Host "Generated Private Key: $keyFile"
Write-Host "Generated CertificateS: $certFile and $certfileBinary"
