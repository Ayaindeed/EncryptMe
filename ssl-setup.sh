#!/bin/bash
# ssl-setup.sh - Generate SSL certificates for PostgreSQL

# Exit on any error
set -e

echo "Setting up SSL certificates for PostgreSQL..."

# Wait for PostgreSQL data directory to be available
while [ ! -d "/var/lib/postgresql/data" ]; do
    echo "Waiting for PostgreSQL data directory..."
    sleep 1
done

# Create SSL directory in a writable location
SSL_DIR="/tmp/ssl-certs"
mkdir -p $SSL_DIR
cd $SSL_DIR

# Generate CA key and certificate
echo "Generating CA certificate..."
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
    -subj "/C=US/ST=State/L=City/O=EncryptMe/CN=EncryptMe-CA"

# Generate server key and certificate
echo "Generating server certificate..."
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr \
    -subj "/C=US/ST=State/L=City/O=EncryptMe/CN=localhost"

# Create extensions file for server certificate
cat > server_ext.conf << EOF
[req]
distinguished_name = req_distinguished_name

[v3_req]
subjectAltName = @alt_names
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = localhost
DNS.2 = db
DNS.3 = encryptme-db
DNS.4 = postgres
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Sign server certificate with CA
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -extensions v3_req -extfile server_ext.conf

# Generate client certificate for mutual TLS
echo "Generating client certificate..."
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr \
    -subj "/C=US/ST=State/L=City/O=EncryptMe/CN=client"
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out client.crt

# Copy certificates to PostgreSQL data directory
echo "Installing certificates..."
cp ca.crt ca.key server.crt server.key client.crt client.key /var/lib/postgresql/data/

# Set proper permissions (PostgreSQL is picky about these)
chmod 600 /var/lib/postgresql/data/server.key
chmod 600 /var/lib/postgresql/data/ca.key
chmod 600 /var/lib/postgresql/data/client.key
chmod 644 /var/lib/postgresql/data/server.crt
chmod 644 /var/lib/postgresql/data/ca.crt
chmod 644 /var/lib/postgresql/data/client.crt

# Create certificate info file
cat > /var/lib/postgresql/data/ssl-info.txt << EOF
SSL Certificates Generated: $(date)
CA Certificate: ca.crt
Server Certificate: server.crt
Server Key: server.key
Client Certificate: client.crt
Client Key: client.key

Certificate Details:
- Valid for 365 days
- Subject Alternative Names: localhost, db, encryptme-db, postgres, 127.0.0.1, ::1
- Suitable for development and testing

Connection Examples:
SSL: psql "sslmode=require host=localhost port=5432 user=admin dbname=encryptme"
Non-SSL: psql "sslmode=disable host=localhost port=5432 user=admin dbname=encryptme"
EOF

echo "SSL certificates setup completed successfully!"
