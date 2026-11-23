
BuildMap:
    pusha
    mov  si, map_text
    mov  di, map_orig
    mov  cx, MAP_SIZE
.next:
    lodsb
    mov  bx, tile_chars
    xor  dx, dx
.find:
    cmp  [bx], al
    je   .found
    inc  bx
    inc  dx
    cmp  dx, 15
    jb   .find
    xor  dx, dx                    
.found:
    mov  [di], dl
    inc  di
    loop .next
    popa
    ret


DrawTiles:
    pusha
    mov  ax, [cam_x]
    shr  ax, 4
    mov  [firstcol], ax
    mov  dx, 1                      
.rowloop:
    xor  si, si                     
.colloop:
    mov  bx, [firstcol]
    add  bx, si                     
    cmp  bx, LEVEL_W
    jae  .nextrow
    mov  ax, dx
    mov  di, ax
    shl  ax, 6
    shl  di, 2
    sub  ax, di                     
    add  ax, bx
    mov  di, ax
    mov  al, [map_work+di]          
    test al, al
    jz   .nextcol
    xor  ah, ah
    push ax                        
    mov  ax, si
    shl  ax, 4
    mov  bx, [cam_x]
    and  bx, 15
    sub  ax, bx
    push ax                         
    mov  ax, dx
    shl  ax, 4
    push ax                         
    call DrawTile
.nextcol:
    inc  si
    cmp  si, 21
    jb   .colloop
.nextrow:
    inc  dx
    cmp  dx, 12
    jb   .rowloop
    popa
    ret


GetTile:
    push bp
    mov  bp, sp
    push bx
    push dx
    mov  ax, [bp+6]                 
    mov  bx, [bp+4]                 
    cmp  bx, 192
    jae  .sky                      
    cmp  ax, LEVEL_W*16
    jae  .wall
    shr  ax, 4
    shr  bx, 4
    mov  dx, bx
    shl  bx, 6
    shl  dx, 2
    sub  bx, dx                     
    add  bx, ax
    mov  al, [map_work+bx]
    jmp  .out
.sky:
    xor  al, al
    jmp  .out
.wall:
    mov  al, T_GROUND
.out:
    xor  ah, ah
    pop  dx
    pop  bx
    pop  bp
    ret  4
