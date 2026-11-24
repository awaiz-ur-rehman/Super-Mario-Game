
DrawTile:
    push bp
    mov  bp, sp
    pusha
    mov  ax, [bp+6]
    mov  [ox], ax
    mov  ax, [bp+4]
    mov  [oy], ax
    mov  bx, [bp+8]
    mov  [tcode], bx
    shl  bx, 1
    call word [tile_procs+bx]
    popa
    pop  bp
    ret  6

TileNone:
    ret
TileGround:
    RECTO 0,0,16,16,C_DIRT
    RECTO 0,0,16,4,C_GREEN
    RECTO 0,3,16,1,C_DKGREEN
    RECTO 3,9,2,2,C_BROWN
    RECTO 10,12,2,2,C_BROWN
    ret
TileBrick:
    RECTO 0,0,16,16,C_BRICK
    RECTO 0,0,16,1,C_DKBRICK
    RECTO 0,7,16,1,C_DKBRICK
    RECTO 0,15,16,1,C_DKBRICK
    RECTO 7,0,1,7,C_DKBRICK
    RECTO 3,8,1,7,C_DKBRICK
    RECTO 11,8,1,7,C_DKBRICK
    ret
TileQuest:
    RECTO 0,0,16,16,C_QORANGE
    RECTO 0,0,16,1,C_DKBRICK
    RECTO 0,15,16,1,C_DKBRICK
    RECTO 0,0,1,16,C_DKBRICK
    RECTO 15,0,1,16,C_DKBRICK
    RECTO 5,3,6,2,C_WHITE           
    RECTO 9,5,2,2,C_WHITE
    RECTO 7,7,3,2,C_WHITE
    RECTO 7,9,2,2,C_WHITE
    RECTO 7,12,2,2,C_WHITE
    ret
TileEmpty:
    RECTO 0,0,16,16,C_EMPTYBODY
    RECTO 0,0,16,1,C_BROWN
    RECTO 0,15,16,1,C_BROWN
    RECTO 0,0,1,16,C_BROWN
    RECTO 15,0,1,16,C_BROWN
    ret
TilePipeTop:
    RECTO 0,0,16,16,C_GREEN
    RECTO 0,0,16,2,C_DKGREEN
    RECTO 0,14,16,2,C_DKGREEN
    cmp  word [tcode], T_PIPETR
    je   .right
    RECTO 0,0,2,16,C_DKGREEN
    RECTO 4,2,3,12,C_LTGREEN
    ret
.right:
    RECTO 14,0,2,16,C_DKGREEN
    RECTO 8,2,2,12,C_LTGREEN
    ret
TilePipeBody:
    cmp  word [tcode], T_PIPEBR
    je   .right
    RECTO 1,0,15,16,C_GREEN
    RECTO 1,0,2,16,C_DKGREEN
    RECTO 5,0,3,16,C_LTGREEN
    ret
.right:
    RECTO 0,0,15,16,C_GREEN
    RECTO 13,0,2,16,C_DKGREEN
    RECTO 3,0,2,16,C_LTGREEN
    ret
TileStair:
    RECTO 0,0,16,16,C_TAN
    RECTO 0,0,16,1,C_DKBRICK
    RECTO 0,15,16,1,C_DKBRICK
    RECTO 0,0,1,16,C_DKBRICK
    RECTO 15,0,1,16,C_DKBRICK
    ret
TileCoin:
    RECTO 5,2,6,12,C_YELLOW
    RECTO 4,4,8,8,C_YELLOW
    RECTO 7,4,2,8,C_GOLD
    ret
TilePole:
    RECTO 7,0,2,16,C_DKGREEN
    RECTO 7,0,1,16,C_LTGREEN
    ret
TileCastle:
    RECTO 0,0,16,16,C_BRICK
    RECTO 0,7,16,1,C_DKBRICK
    RECTO 7,0,1,7,C_DKBRICK
    RECTO 3,8,1,7,C_DKBRICK
    RECTO 11,8,1,7,C_DKBRICK
    ret
TileDoor:
    RECTO 0,0,16,16,C_BRICK
    RECTO 2,4,12,12,C_BLACK
    RECTO 4,2,8,2,C_BLACK
    ret

DrawScenery:
    pusha
    mov  si, cloud_data
    mov  cx, CLOUD_COUNT
.cl:
    lodsw                           
    mov  bx, [cam_x]
    shr  bx, 1
    sub  ax, bx
    mov  dx, ax                     
    lodsw                           
    cmp  dx, -48
    jle  .ncl
    cmp  dx, SCREEN_W
    jge  .ncl
    mov  [ox], dx
    mov  [oy], ax
    call CloudShape
.ncl:
    dec  cx
    jnz  .cl
    mov  si, bush_data
    mov  cx, BUSH_COUNT
.bl:
    lodsw
    sub  ax, [cam_x]
    cmp  ax, -48
    jle  .nbl
    cmp  ax, SCREEN_W
    jge  .nbl
    mov  [ox], ax
    mov  word [oy], 144
    call BushShape
.nbl:
    dec  cx
    jnz  .bl
    popa
    ret

CloudShape:
    RECTO 12,0,24,4,C_WHITE
    RECTO 6,4,36,4,C_WHITE
    RECTO 0,8,48,6,C_WHITE
    RECTO 4,14,40,2,C_GREY
    ret

BushShape:
    RECTO 10,0,28,4,C_GREEN
    RECTO 4,4,40,4,C_GREEN
    RECTO 0,8,48,8,C_GREEN
    RECTO 12,2,6,2,C_LTGREEN
    RECTO 28,5,6,2,C_LTGREEN
    RECTO 6,10,6,2,C_LTGREEN
    ret


DrawFlag:
    push ax
    mov  ax, POLE_COL*16
    sub  ax, [cam_x]
    cmp  ax, -32
    jle  .out
    cmp  ax, SCREEN_W
    jge  .out
    add  ax, 7
    mov  [ox], ax
    mov  word [oy], 32
    call FlagShape
.out:
    pop  ax
    ret

FlagShape:
    RECTO -1,-6,4,6,C_LTGREEN
    RECTO -8,2,8,2,C_WHITE
    RECTO -7,4,7,2,C_WHITE
    RECTO -6,6,6,2,C_WHITE
    RECTO -5,8,5,2,C_WHITE
    RECTO -4,10,4,2,C_WHITE
    RECTO -3,12,3,2,C_WHITE
    RECTO -2,14,2,2,C_WHITE
    ret


DrawPopCoin:
    push ax
    push bx
    cmp  byte [pop_timer], 0
    je   .out
    mov  ax, [pop_x]
    sub  ax, [cam_x]
    mov  [ox], ax
    mov  al, 14
    sub  al, [pop_timer]
    xor  ah, ah
    shl  ax, 2                      
    mov  bx, [pop_y]
    sub  bx, ax
    mov  [oy], bx
    call CoinShape
.out:
    pop  bx
    pop  ax
    ret

CoinShape:
    RECTO 5,2,6,12,C_YELLOW
    RECTO 4,4,8,8,C_YELLOW
    RECTO 7,4,2,8,C_GOLD
    ret
