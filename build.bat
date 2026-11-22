@echo off
rem Build script for the Super Mario Engine (COAL project).
rem Assembles src\mario.asm with NASM and produces MARIO.COM.

nasm -f bin -i src\ src\mario.asm -o MARIO.COM -l mario.lst
if errorlevel 1 (
    echo Build failed. Check the error messages above.
) else (
    echo Build succeeded: MARIO.COM created.
    echo To run: mount the folder in DOSBox and type MARIO.
)
pause
