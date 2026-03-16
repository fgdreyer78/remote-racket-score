@echo off
title Iniciar Projeto Arbitragem - Flutter
cls

echo ======================================================
echo    INICIANDO AMBIENTE DE DESENVOLVIMENTO (FLUTTER)
echo ======================================================

:: 1. Verifica se o Flutter está no PATH
echo [1/3] Verificando SDK do Flutter...
call flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Flutter nao encontrado no PATH. Verifique sua instalacao.
    pause
    exit
)
echo [OK] Flutter pronto!

:: 2. Limpeza e Dependências (Opcional, mas garante estabilidade)
echo [2/3] Atualizando dependencias (pub get)...
call flutter pub get

:: 3. Iniciar o App
echo [3/3] Tentando rodar o app no emulador...
echo ------------------------------------------------------
echo DICA: Certifique-se de que o Emulador do Android Studio ja esteja aberto!
echo ------------------------------------------------------
echo.
call flutter run

pause