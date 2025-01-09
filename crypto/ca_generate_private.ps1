# Generates a new CA private key

# Paths to files
$caDir = "CA"

# CA Certificate and Key Paths
$caKey = "root_key.pem"

# Ensure directories exist
if (-Not (Test-Path $caDir)) { New-Item -ItemType Directory -Path $caDir }

# Make sure the user understands the implications of generating a new CA
$continue = Read-Host "Generating a new CA will invalidate all certificates signed by the current CA. Do you want to continue? (Y/N)"

# Exit if the user does not want to continue
if ($continue -ne "Y") {
    Write-Host "Exiting..."
    exit
}

# Generate file paths
$keyFile = Join-Path $caDir $caKey

# Generate a private key
& openssl genpkey -algorithm RSA -out $keyFile -pkeyopt rsa_keygen_bits:2048

# Output the generated files
Write-Host "Generated CA Private Key: $keyFile"
