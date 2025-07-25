@echo off
REM EncryptMe Setup Script for Windows
REM This script sets up the EncryptMe encrypted database project

echo =====================================
echo EncryptMe: End-to-End Encrypted Database
echo =====================================
echo.

REM Check if Docker is running
echo Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running or not installed.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo Docker is running!
echo.

REM Create necessary directories
echo Creating project directories...
if not exist "init-scripts" mkdir init-scripts
if not exist "test-scripts" mkdir test-scripts
echo Directories created!
echo.

REM Stop and remove existing containers
echo Cleaning up existing containers...
docker-compose down -v 2>nul
docker-compose --profile setup down 2>nul
echo Cleanup completed!
echo.

REM Generate SSL certificates first
echo Step 1: Generating SSL certificates...
docker-compose --profile setup up ssl-generator
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate SSL certificates.
    pause
    exit /b 1
)
echo SSL certificates generated successfully!
echo.

REM Small delay to ensure certificates are written
echo Waiting for certificates to be ready...
timeout /t 2 /nobreak >nul
echo.

REM Start the main services
echo Step 2: Starting database and pgAdmin services...
docker-compose up -d db pgadmin
if %errorlevel% neq 0 (
    echo ERROR: Failed to start services.
    pause
    exit /b 1
)
echo.

REM Wait for database to be ready
echo Step 3: Waiting for database to be ready...
:wait_loop
docker exec encryptme-db pg_isready -U admin -d encryptme >nul 2>&1
if %errorlevel% neq 0 (
    echo Waiting for PostgreSQL to start...
    timeout /t 3 /nobreak >nul
    goto wait_loop
)
echo Database is ready!
echo.

REM Run connection tests
echo Step 4: Running SSL connection tests...
docker-compose --profile testing up test-client
echo.

echo =====================================
echo Setup completed successfully!
echo =====================================
echo.
echo Services running:
echo - PostgreSQL (SSL enabled): localhost:5432
echo - pgAdmin: http://localhost:8080
echo.
echo Default credentials:
echo - Database: admin / password
echo - pgAdmin: admin@encryptme.local / admin123
echo.
echo To test connections manually:
echo docker exec -it encryptme-client bash
echo /test-scripts/test-ssl-connection.sh
echo.
echo To stop all services:
echo docker-compose down
echo.
pause