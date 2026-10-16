@echo off
chcp 65001 > nul
cls
echo ====================================================================
echo         LA GARZA AGUACHILERA - PUBLICACION EN GITHUB PAGES
echo ====================================================================
echo.
echo Repositorio detectado: https://github.com/Fritomaster420/la-garza-aguachilera
echo.
echo Paso 1 de 3: Conectando con tu cuenta de GitHub en Edge...
echo Se abrira tu navegador para autorizar la conexion en 1 solo clic.
echo.
"C:\Program Files\GitHub CLI\gh.exe" auth login --web -h github.com -p https
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] No se pudo completar la autorizacion.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Paso 2 de 3: Subiendo archivos de la pagina web y panel de control...
"C:\Program Files\GitHub CLI\gh.exe" auth setup-git
git push -u origin main --force
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Fallo al subir los archivos a GitHub.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Paso 3 de 3: Activando hosting gratuito en GitHub Pages...
"C:\Program Files\GitHub CLI\gh.exe" api repos/Fritomaster420/la-garza-aguachilera/pages -f source="{\"branch\":\"main\",\"path\":\"/\"}" > nul 2>&1

echo.
echo ====================================================================
echo   EXITO TOTAL: TU PAGINA YA ESTA EN VIVO EN INTERNET
echo.
echo   Enlace oficial: https://fritomaster420.github.io/la-garza-aguachilera/
echo ====================================================================
echo.
echo Presiona cualquier tecla para salir...
pause > nul
