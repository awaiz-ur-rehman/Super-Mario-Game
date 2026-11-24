
ClearBack:
    push es
    push di
    push cx
    push ax
    mov  ah, al
    mov  di, [backseg]
    mov  es, di
    xor  di, di
    mov  cx, 32000
    cld
    rep  stosw
    pop  ax
    pop  cx
    pop  di
    pop  es
    ret


PresentAll:
    push ax
    push cx
    push si
    push di
    push ds
    push es
    mov  ax, [backseg]
    mov  ds, ax
    mov  ax, 0A000h
    mov  es, ax
    xor  si, si
    xor  di, di
    mov  cx, 32000
    cld
    rep  movsw
    pop  es
    pop  ds
    pop  di
    pop  si
    pop  cx
    pop  ax
    ret

PresentPlay:
    push ax
    push cx
    push si
    push di
    push ds
    push es
    mov  ax, 0A000h
    mov  es, ax
    xor  si, si
    xor  di, di
    mov  ax, [hudseg]
    mov  ds, ax
    mov  cx, 2560                   
    cld
    rep  movsw
    mov  ax, [cs:backseg]
    mov  ds, ax
    mov  si, 5120                   
    mov  cx, 28160                  
    rep  movsw
    pop  es
    pop  ds
    pop  di
    pop  si
    pop  cx
    pop  ax
    ret


DrawWorld:
    push ax
    push cx
    push di
    push es
    mov  ax, [backseg]
    mov  es, ax
    mov  di, 5120                   
    xor  ax, ax                     
    mov  cx, 28160
    cld
    rep  stosw                      
 
    pop  es
    pop  di
    pop  cx
    pop  ax
    call DrawScenery
    call DrawTiles
    call DrawFlag
    call DrawPopCoin
    call DrawEntities
    call DrawMario
    call RenderHud
    ret
