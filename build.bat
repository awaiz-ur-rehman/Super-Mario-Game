@echo off
rem Builds the complete game: src\mario.asm -> MARIO.COM
nasm -f bin -i src\ src\mario.asm -o MARIO.COM -l mario.lst
if errorlevel 1 (echo BUILD FAILED) else (echo OK - MARIO.COM bana. DOSBox mein: mount c . ; c: ; MARIO)
pause
