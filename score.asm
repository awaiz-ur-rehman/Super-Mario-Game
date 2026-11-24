
; SCORE, COINS, LIVES

; AddScore - add points (32-bit with ADD/ADC), clamp to 999999.
; In (stack): points   (ret 2).  Registers unchanged.

AddScore:
    push bp
    mov  bp, sp
    push ax
    mov  ax, [bp+4]
    add  [score_lo], ax
    adc  word [score_hi], 0
    cmp  word [score_hi], 0Fh       ; 999999 = 000F423Fh
    jb   .ok
    ja   .clamp
    cmp  word [score_lo], 423Fh
    jbe  .ok
.clamp:
    mov  word [score_hi], 0Fh
    mov  word [score_lo], 423Fh
.ok:
    pop  ax
    pop  bp
    ret  2

; AddLife - one more life (never more than 99)
AddLife:
    cmp  word [lives], 99
    jae  .out
    inc  word [lives]
.out:
    ret

; AddCoin - coins + 1; every 100 coins give an extra life and restart at 0
AddCoin:
    inc  word [coins]
    cmp  word [coins], 100
    jb   .out
    mov  word [coins], 0
    call AddLife
.out:
    ret

; KillMario - start the death sequence (jump up, then fall)
KillMario:
    cmp  byte [state], ST_PLAYING
    jne  .out
    mov  byte [state], ST_DYING
    mov  byte [dtimer], 0
    mov  word [vx], 0
    mov  word [vy], 0FB00h          ; small hop up first
    mov  word [yfrac], 0
    mov  byte [on_ground], 0
    mov  word [invuln], 0
.out:
    ret

; KillMarioPit - death by falling: no hop, he just keeps falling
KillMarioPit:
    call KillMario
    mov  word [vy], 0
    ret

; HurtMario - touched by an enemy
HurtMario:
    cmp  word [invuln], 0
    jg   .out                       ; blinking: no damage
    cmp  byte [form], 0
    je   .die
    mov  byte [form], 0             ; Super -> Small, feet stay where they are
    mov  word [hp], 1
    mov  word [mheight], 16
    add  word [ypix], 16
    mov  word [invuln], INVULN_FRAMES
    jmp  .out
.die:
    call KillMario
.out:
    ret
