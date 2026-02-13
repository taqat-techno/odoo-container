@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Odoo 19 Docker Quick Start
echo ============================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Desktop is not running.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo [OK] Docker Desktop is running.

REM Copy .env.example to .env if .env doesn't exist
if not exist .env (
    copy .env.example .env >nul
    echo [OK] Created .env from .env.example
) else (
    echo [OK] .env already exists.
)

REM Build Docker image
echo.
echo Building Docker image (this may take a few minutes)...
docker-compose build
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed.
    pause
    exit /b 1
)
echo [OK] Docker image built successfully.

REM Start services
echo.
echo Starting services...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start services.
    pause
    exit /b 1
)

REM Wait for services to be healthy
echo.
echo Waiting for services to be ready...
set /a retries=0
:healthcheck
docker-compose ps | findstr "healthy" >nul 2>&1
if %errorlevel% neq 0 (
    set /a retries+=1
    if !retries! gtr 30 (
        echo WARNING: Services did not become healthy within timeout.
        echo Check logs with: docker-compose logs
        pause
        exit /b 1
    )
    timeout /t 5 /nobreak >nul
    goto healthcheck
)

echo [OK] All services are running and healthy.
echo.
echo ============================================
echo   Odoo 19 is ready!
echo   Access URL: http://localhost:8069
echo   Master Password: 123
echo ============================================
echo.
pause
