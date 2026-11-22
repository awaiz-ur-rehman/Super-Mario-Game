
SetPalette:
    pusha
    mov  dx, 3C8h
    xor  al, al
    out  dx, al
    inc  dx
    mov  si, palette
    mov  cx, PAL_COUNT*3
.l:
    lodsb
    out  dx, al
    loop .l
    popa
    ret

ClearVram:
    push es
    push di
    push cx
    push ax
    mov  ax, 0A000h
    mov  es, ax
    xor  di, di
    mov  cx, 32000
    mov  ax, 0101h
    cld
    rep  stosw
    pop  ax
    pop  cx
    pop  di
    pop  es
    ret

FillRect:
    push bp
    mov  bp, sp
    pusha
    push es
    mov  ax, [drawseg]
    mov  es, ax
    mov  si, [bp+12]                ; x
    mov  cx, si
    add  cx, [bp+8]                 ; x + width
    cmp  si, 0
    jge  .x0ok
    xor  si, si
.x0ok:
    cmp  cx, SCREEN_W
    jle  .x1ok
    mov  cx, SCREEN_W
.x1ok:
    sub  cx, si                     ; clipped width
    jle  .done
    mov  dx, [bp+10]                ; y
    mov  bx, dx
    add  bx, [bp+6]                 ; y + height
    cmp  dx, 0
    jge  .y0ok
    xor  dx, dx
.y0ok:
    cmp  bx, SCREEN_H
    jle  .y1ok
    mov  bx, SCREEN_H
.y1ok:
    sub  bx, dx                         jle  .done
    mov  di, dx
    shl  di, 8                         shl  dx, 6                      
    add  di, dx
    add  di, si                     
    mov  al, [bp+4]                 ; colour
    cld
.row:
    push di
    push cx
    rep  stosb
    pop  cx
    pop  di
    add  di, SCREEN_W
    dec  bx
    jnz  .row
.done:
    pop  es
    popa
    pop  bp
    ret  10
