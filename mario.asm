bits 16
org 100h

%include "const_engine.asm"
%include "const_game.asm"

start:
    cld
    mov ax, cs
    add ax, 3000h
    cmp ax, [2]
    jbe .memok
    mov dx, msg_nomem
    mov ah, 9
    int 21h
    mov ax, 4C01h
    int 21h

.memok:
    mov ax, cs
    add ax, 1000h
    mov [backseg], ax
    mov [drawseg], ax
    add ax, 1000h
    mov [hudseg], ax

    push bp
    mov ax, 1130h
    mov bh, 3
    int 10h
    mov [fontoff], bp
    mov [fontseg], es
    pop bp

    push cs
    pop es

    call BuildMap

    mov ax, 0013h
    int 10h
    call SetPalette
    call ClearVram

    mov ax, 3509h
    int 21h
    mov [oldkbd], bx
    mov [oldkbd+2], es
    mov dx, KbdISR
    mov ax, 2509h
    int 21h

    push cs
    pop es

    mov byte [state], ST_TITLE
    mov byte [redraw], 1

mainloop:
    call WaitRetrace
    call WaitRetrace
    inc word [frames]
    mov bl, [state]
    xor bh, bh
    shl bx, 1
    call word [state_table+bx]
    cmp byte [quit], 0
    je mainloop

%include "exit.asm"

%include "keyboard.asm"
%include "timer.asm"
%include "video.asm"
%include "map.asm"
%include "tile_data.asm"
%include "sprites.asm"
%include "font.asm"
%include "hud.asm"
%include "framebuf.asm"
%include "screens.asm"
%include "collision.asm"
%include "score.asm"
%include "blocks.asm"
%include "hero.asm"
%include "enemies.asm"
%include "camera.asm"
%include "sequences.asm"
%include "states.asm"

%include "data_engine.asm"
%include "data_game.asm"
%include "sprite_data.asm"
%include "level_data.asm"