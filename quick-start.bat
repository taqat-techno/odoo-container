@echo off
setlocal

echo ============================================
echo   Odoo 16 Docker Quick Start
echo ============================================
echo.

REM Check Docker Desktop is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Desktop is not running. Please start it first.
    pause
    exit /b 1
)

echo [OK] Docker Desktop is running.

REM Copy .env.example to .env if missing
if not exist .env (
    copy .env.example .env >nul
    echo [OK] Created .env from .env.example
) else (
    echo [OK] .env already exists
)

echo.
echo Building Docker images...
docker-compose build
if errorlevel 1 (
    echo [ERROR] Docker build failed.
    pause
    exit /b 1
)

echo.
echo Starting containers...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start containers.
    pause
    exit /b 1
)

echo.
echo Waiting for services to be ready...
:waitloop
timeout /t 5 /nobreak >nul
docker-compose ps | findstr "healthy" >nul 2>&1
if errorlevel 1 (
    echo   Still waiting...
    goto waitloop
)

echo.
echo ============================================
echo   Odoo 16 is ready!
echo   Open: http://localhost:8069
echo   Master Password: 123
echo ============================================
echo.
pause
