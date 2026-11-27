
DrawPauseBox:
    pusha
    RECT 80,76,160,52,C_WHITE
    RECT 82,78,156,48,C_BLACK
    mov  word [tscale], 2
    TEXT 112,84,C_YELLOW,s_paused
    mov  word [tscale], 1
    TEXT 92,112,C_WHITE,s_resume
    popa
    ret


DrawTitleScreen:
    pusha
    xor  al, al
    call ClearBack
    xor  si, si
.edge1:                             
    mov  ax, si
    shl  ax, 4
    push word T_BRICK
    push ax
    push word 0
    call DrawTile
    push word T_BRICK
    push ax
    push word 176
    call DrawTile
    inc  si
    cmp  si, 20
    jb   .edge1
    mov  si, 1
.edge2:                             
    mov  ax, si
    shl  ax, 4
    push word T_BRICK
    push word 0
    push ax
    call DrawTile
    push word T_BRICK
    push word 304
    push ax
    call DrawTile
    inc  si
    cmp  si, 11
    jb   .edge2
    mov  si, 1
.edge3:                             
    mov  ax, si
    shl  ax, 4
    push word T_GROUND
    push ax
    push word 160
    call DrawTile
    inc  si
    cmp  si, 19
    jb   .edge3
    mov  word [tscale], 3
    TEXT 30,34,C_BLACK,s_title      
    TEXT 28,32,C_RED,s_title
    mov  word [tscale], 2
    TEXT 72,66,C_WHITE,s_engine
    mov  word [tscale], 1
    TEXT 40,86,C_WHITE,s_hint
    RECT 64,100,192,56,C_WHITE      
    RECT 66,102,188,52,C_BLACK
    mov  word [tscale], 2
    mov  ax, C_WHITE
    cmp  byte [menusel], 0
    jne  .c1
    mov  ax, C_YELLOW
.c1:
    push word 92
    push word 108
    push ax
    push word s_start
    call DrawText
    mov  ax, C_WHITE
    cmp  byte [menusel], 1
    jne  .c2
    mov  ax, C_YELLOW
.c2:
    push word 92
    push word 132
    push ax
    push word s_exit
    call DrawText
    mov  ax, 108
    cmp  byte [menusel], 0
    je   .arrow
    mov  ax, 132
.arrow:
    push word 72
    push ax
    push word C_YELLOW
    push word s_arrow
    call DrawText
    mov  word [tscale], 1
    TEXT 76,164,C_WHITE,s_footer
    push word 40                    
    push word 144
    push word spr_small_stand
    push word 0
    call DrawSprite
    push word 248
    push word 144
    push word spr_goomba
    push word 0
    call DrawSprite
    RECT 0,192,320,8,C_BLACK
    popa
    ret


DrawLifeLostScreen:
    pusha
    mov  al, C_BLACK
    call ClearBack
    mov  word [tscale], 3
    TEXT 52,40,C_WHITE,s_world11
    mov  word [tscale], 2
    TEXT 140,104,C_WHITE,s_x
    NUM  156,104,C_WHITE,0,[lives],1
    TEXT 80,150,C_YELLOW,s_liveleft
    mov  word [tscale], 1
    push word 106
    push word 100
    push word spr_small_stand
    push word 0
    call DrawSprite
    popa
    ret


DrawGameOverScreen:
    pusha
    mov  al, C_BLACK
    call ClearBack
    RECT 30,20,260,160,C_RED
    RECT 33,23,254,154,C_BLACK
    mov  word [tscale], 3
    TEXT 52,50,C_RED,s_gameover
    mov  word [tscale], 1
    TEXT 76,100,C_WHITE,s_final
    NUM  180,100,C_WHITE,[score_hi],[score_lo],6
    TEXT 76,118,C_YELLOW,s_coinsc
    NUM  140,118,C_YELLOW,0,[coins],2
    TEXT 180,118,C_YELLOW,s_timec
    NUM  228,118,C_YELLOW,0,[time_left],3
    TEXT 60,150,C_LTGREEN,s_enter_title
    popa
    ret


DrawCompleteScreen:
    pusha
    mov  al, C_BLACK
    call ClearBack
    RECT 20,10,280,180,C_YELLOW
    RECT 23,13,274,174,C_BLACK
    mov  word [tscale], 2
    TEXT 40,26,C_YELLOW,s_complete
    mov  word [tscale], 1
    TEXT 56,68,C_WHITE,s_score
    NUM  180,68,C_WHITE,[pre_hi],[pre_lo],6
    TEXT 56,86,C_WHITE,s_coins
    NUM  180,86,C_WHITE,0,[coins],2
    TEXT 56,104,C_WHITE,s_timeleft
    NUM  180,104,C_WHITE,0,[time_left],3
    TEXT 212,104,C_WHITE,s_x50
    TEXT 56,122,C_WHITE,s_bonus
    NUM  180,122,C_WHITE,0,[bonus_val],5
    TEXT 56,140,C_YELLOW,s_finalsc
    NUM  180,140,C_YELLOW,[score_hi],[score_lo],6
    TEXT 68,168,C_LTGREEN,s_enter_cont
    popa
    ret
