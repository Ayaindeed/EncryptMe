# EncryptMe: End-to-End Encrypted Db

A PostgreSQL Docker setup demonstrating **encryption at rest** and **in transit** for secure database operations.

## Features

- **Encryption in Transit**: SSL/TLS with auto-generated certificates
- **Encryption at Rest**: Field-level encryption using pgcrypto
- **Web Interface**: pgAdmin for database management
- **Monitoring Dashboard**: Grafana for real-time database monitoring
- **Docker-based**: Easy setup and deployment
- **Windows Compatible**: Optimized for Docker Desktop on Windows

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ayaindeed/EncryptMe
   cd EncryptMe
   ```

2. **Start the services**
   ```bash
   docker-compose down -v  
   docker-compose up -d   
   ```

3. **Generate SSL certificates**
   ```bash
   docker exec encryptme-db bash /docker-entrypoint-initdb.d/01-ssl-setup.sh
   ```

4. **Restart with SSL enabled**
   ```bash
   docker-compose restart db
   ```

5. **Enable encryption extension**
   ```bash
   docker exec -e PGPASSWORD=password encryptme-db psql -U admin -d encryptme -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
   ```

6. **Start monitoring dashboard (optional)**
   ```bash
   docker-compose up -d monitoring
   ```

## Access Points

- **PostgreSQL Database**: `localhost:5432`
- **pgAdmin Web UI**: http://localhost:8080
- **Grafana Monitoring**: http://localhost:3000


## Technical Details

### SSL Certificates
- **Auto-generated** during first run
- **Self-signed** (suitable for development)
- **Valid for 365 days**
- **Subject Alternative Names**: localhost, db, encryptme-db, postgres

### Encryption Methods
- **pgcrypto extension**: Symmetric encryption for field-level data
- **SSL/TLS**: Transport layer encryption
- **SCRAM-SHA-256**: Password authentication

### Docker Services
- **PostgreSQL 15**: Database server with SSL enabled
- **pgAdmin 4**: Web-based database administration
- **Test Client**: Optional container for connection testing

## Management Commands

```bash
# Access database shell
docker exec -it encryptme-db psql -U admin -d encryptme
```

## Security Notes

### For Development
- Uses default passwords (change for production)
- Self-signed certificates (use proper CA for production)
- Logging enabled for debugging

## Compliance & Standards

This setup demonstrates security practices relevant to:
- **GDPR**: Personal data encryption
- **HIPAA**: Healthcare data protection
- **PCI DSS**: Payment card data security
- **SOX**: Financial data integrity

## License

This project is for educational purposes.

---
