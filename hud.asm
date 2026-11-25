
RenderHud:
    pusha
    push es
    push cs
    pop  es
    mov  si, hud_vars
    mov  di, hud_saved
    mov  cx, 6
    cld
    repe cmpsw                      
    je   .out
    mov  si, hud_vars
    mov  di, hud_saved
    mov  cx, 6
    rep  movsw                      
    call DrawHudInto
.out:
    pop  es
    popa
    ret

DrawHudInto:
    pusha
    mov  ax, [hudseg]
    mov  [drawseg], ax              
    mov  word [tscale], 1
    RECT 0,0,320,16,C_BLACK
    TEXT 4,0,C_YELLOW,s_score
    TEXT 68,0,C_YELLOW,s_coins
    TEXT 116,0,C_YELLOW,s_world
    TEXT 172,0,C_YELLOW,s_time
    TEXT 220,0,C_YELLOW,s_lives
    TEXT 268,0,C_YELLOW,s_health
    NUM  4,8,C_WHITE,[score_hi],[score_lo],6
    TEXT 68,8,C_WHITE,s_x
    NUM  76,8,C_WHITE,0,[coins],2
    TEXT 116,8,C_WHITE,s_w11
    NUM  172,8,C_WHITE,0,[time_left],3
    TEXT 220,8,C_WHITE,s_x
    NUM  228,8,C_WHITE,0,[lives],2
    push word 268
    push word 8
    push word C_RED
    call DrawHeart
    mov  ax, C_GREY
    cmp  word [hp], 2
    jne  .h2
    mov  ax, C_RED
.h2:
    push word 284
    push word 8
    push ax
    call DrawHeart
    mov  ax, [backseg]
    mov  [drawseg], ax              
    popa
    ret
