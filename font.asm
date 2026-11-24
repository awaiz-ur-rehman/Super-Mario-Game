; DrawChar  draw one character with the BIOS 8x8 font, scaled by [tscale]
; In (stack): x, y, colour, character      (ret 8)
; Registers changed: none
;
DrawChar:
    push bp
    mov  bp, sp
    pusha
    push es
    mov  al, [bp+4]
    xor  ah, ah
    shl  ax, 3                      ; 8 bytes per character
    add  ax, [fontoff]
    mov  si, ax
    push ds
    mov  ax, [fontseg]
    mov  ds, ax
    push cs
    pop  es
    mov  di, glyph
    mov  cx, 8
    cld
    rep  movsb                      ; copy the 8 font rows into 'glyph'
    pop  ds
    mov  ax, [drawseg]
    mov  es, ax
    mov  al, [bp+6]
    mov  [chcol], al
    mov  ax, [bp+8]
    mov  [cy], ax
    xor  si, si                     ; SI = glyph row 0..7
.grow:
    mov  cx, [tscale]               ; repeat each row 'scale' times
.srow:
    push cx
    mov  bx, [cy]
    cmp  bx, SCREEN_H
    jae  .skiprow
    mov  di, bx
    shl  di, 8
    shl  bx, 6
    add  di, bx                     ; DI = y * 320
    mov  dl, [glyph+si]             ; bits of this glyph row
    mov  bx, [bp+10]                ; BX = x of the current column
    mov  dh, 8
.gcol:
    test dl, 80h
    jz   .nopix
    mov  cx, [tscale]
    push bx
.kloop:
    cmp  bx, SCREEN_W
    jae  .kskip
    push di
    add  di, bx
    mov  al, [chcol]
    mov  [es:di], al
    pop  di
.kskip:
    inc  bx
    loop .kloop
    pop  bx
.nopix:
    add  bx, [tscale]
    shl  dl, 1
    dec  dh
    jnz  .gcol
.skiprow:
    inc  word [cy]
    pop  cx
    LOOPFAR .srow
    inc  si
    cmp  si, 8
    jb   .grow
    pop  es
    popa
    pop  bp
    ret  8

; DrawText - draw a zero-terminated string
; In (stack): x, y, colour, address of string      (ret 8)


DrawText:
    push bp
    mov  bp, sp
    pusha
    mov  si, [bp+4]
    mov  bx, [bp+10]
.l:
    lodsb
    test al, al
    jz   .done
    xor  ah, ah
    push bx
    push word [bp+8]
    push word [bp+6]
    push ax
    call DrawChar
    mov  ax, [tscale]
    shl  ax, 3
    add  bx, ax
    jmp  .l
.done:
    popa
    pop  bp
    ret  8


; DrawNumber - draw a 32-bit number as decimal digits (zero padded)
; In (stack): x, y, colour, high word, low word, number of digits  (ret 12)
; Method: divide by 10 again and again, push each remainder on the stack,
;         then pop them (most important digit comes out first).

DrawNumber:
    push bp
    mov  bp, sp
    pusha
    mov  si, [bp+8]                 ; high word
    mov  di, [bp+6]                 ; low word
    mov  cx, [bp+4]                 ; digits
    mov  bx, 10
.div:
    mov  ax, si
    xor  dx, dx
    div  bx                         ; high / 10
    mov  si, ax
    mov  ax, di
    div  bx                         ; (remainder:low) / 10
    mov  di, ax
    push dx                         ; one digit
    loop .div
    mov  cx, [bp+4]
    mov  si, [bp+14]                ; current x
.draw:
    pop  ax
    add  al, '0'
    xor  ah, ah
    push si
    push word [bp+12]
    push word [bp+10]
    push ax
    call DrawChar
    mov  ax, [tscale]
    shl  ax, 3
    add  si, ax
    loop .draw
    popa
    pop  bp
    ret  12

; DrawHeart - small heart icon.  In (stack): x, y, colour   (ret 6)

DrawHeart:
    push bp
    mov  bp, sp
    pusha
    mov  ax, [bp+8]
    mov  [ox], ax
    mov  ax, [bp+6]
    mov  [oy], ax
    mov  ax, [bp+4]
    mov  [hcol], ax
    RECTO 1,0,2,1,[hcol]
    RECTO 4,0,2,1,[hcol]
    RECTO 0,1,7,2,[hcol]
    RECTO 1,3,5,1,[hcol]
    RECTO 2,4,3,1,[hcol]
    RECTO 3,5,1,1,[hcol]
    popa
    pop  bp
    ret  6
