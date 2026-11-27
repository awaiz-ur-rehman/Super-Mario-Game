
StartWin:
    pusha
    mov  ax, [ypix]
    add  ax, [mheight]
    dec  ax
    sar  ax, 4                      
    mov  bx, 5000
    cmp  ax, 3
    jle  .pts
    mov  bx, 2000
    cmp  ax, 4
    je   .pts
    mov  bx, 800
    cmp  ax, 5
    je   .pts
    mov  bx, 400
    cmp  ax, 7
    jle  .pts
    mov  bx, 100
.pts:
    push bx
    call AddScore
    mov  byte [state], ST_WIN
    mov  byte [win_phase], 0
    mov  byte [flag_hit], 0
    mov  word [xpix], POLE_COL*16   
    mov  word [vx], 0
    mov  word [vy], 0
    mov  byte [on_ground], 0
    mov  byte [facing], 0
    popa
    ret
FinishDeath:
    dec  word [lives]
    mov  byte [redraw], 1
    cmp  word [lives], 0
    jne  .life
    mov  byte [state], ST_GAMEOVER
    ret
.life:
    mov  byte [state], ST_LIFELOST
    mov  word [ltimer], 70
    ret


FinishWin:
    push ax
    push bx
    push dx
    mov  ax, [score_lo]
    mov  [pre_lo], ax
    mov  ax, [score_hi]
    mov  [pre_hi], ax
    mov  ax, [time_left]
    mov  bx, 50
    mul  bx
    mov  [bonus_val], ax
    push ax
    call AddScore
    mov  byte [state], ST_COMPLETE
    mov  byte [redraw], 1
    pop  dx
    pop  bx
    pop  ax
    ret


StateDying:
    call DyingStep
    cmp  byte [state], ST_DYING
    jne  .out
    call DrawWorld
    call PresentPlay
.out:
    ret

DyingStep:
    inc  byte [dtimer]
    mov  ax, [yfrac]
    add  ax, [vy]
    mov  bx, ax
    sar  bx, 8
    and  ax, 0FFh
    mov  [yfrac], ax
    add  [ypix], bx
    add  word [vy], GRAVITY
    cmp  byte [dtimer], 52          
    jb   .out
    call FinishDeath
.out:
    ret


StateWin:
    call WinStep
    cmp  byte [state], ST_WIN
    jne  .out
    call DrawWorld
    call PresentPlay
.out:
    ret

WinStep:
    cmp  byte [win_phase], 0
    jne  .p1
    add  word [ypix], 2             
    mov  ax, [ypix]
    add  ax, [mheight]
    cmp  ax, 144                    
    jl   .done
    mov  ax, GROUND_Y
    sub  ax, [mheight]
    mov  [ypix], ax
    mov  byte [win_phase], 1
    mov  byte [on_ground], 1
    mov  word [vx], 0100h           
    ret
.p1:
    cmp  byte [win_phase], 1
    jne  .p2
    inc  word [xpix]                
    cmp  word [xpix], 944
    jb   .done
    mov  byte [win_phase], 2
    mov  byte [mario_hidden], 1
    mov  byte [dtimer], 0
    ret
.p2:
    inc  byte [dtimer]
    cmp  byte [dtimer], 25
    jb   .done
    call FinishWin
.done:
    ret
