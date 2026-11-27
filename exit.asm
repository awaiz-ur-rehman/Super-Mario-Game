; ----------------------------------------------------------------------------
; CLEAN EXIT: undo everything we changed, otherwise DOS keyboard stops working
; ----------------------------------------------------------------------------
ExitGame:
    push ds
    lds  dx, [oldkbd]
    mov  ax, 2509h                  ; put the old INT 09h back
    int  21h
    pop  ds
    push es                         ; clear BIOS shift flags and key buffer
    mov  ax, 40h
    mov  es, ax
    mov  byte [es:17h], 0
    mov  ax, [es:1Ah]
    mov  [es:1Ch], ax
    pop  es
    mov  ax, 0003h                  ; back to 80x25 text mode
    int  10h
    mov  ax, 4C00h                  ; DOS terminate program
    int  21h

; ============================================================================
; RESET / NEW GAME / END OF LIFE
; ============================================================================
; ResetLevel - map, enemies, Mario, clock and camera back to the start.
; Score, coins and lives are NOT touched.
ResetLevel:
    pusha
    push es
    push cs
    pop  es
    cld
    mov  si, map_orig               ; working map = copy of the original
    mov  di, map_work
    mov  cx, MAP_SIZE/2
    rep  movsw
    mov  si, enemy_init
    mov  di, enemies
    mov  cx, (ENEMY_MAX*E_SIZE)/2
    rep  movsw
    mov  word [xpix], 32
    mov  word [ypix], GROUND_Y-16
    mov  word [xfrac], 0
    mov  word [yfrac], 0
    mov  word [vx], 0
    mov  word [vy], 0
    mov  byte [facing], 0
    mov  byte [on_ground], 1
    mov  byte [jump_ready], 1
    mov  byte [form], 0
    mov  word [hp], 1
    mov  word [mheight], 16
    mov  word [invuln], 0
    mov  byte [stomp_chain], 0
    mov  byte [mario_hidden], 0
    mov  byte [flag_hit], 0
    mov  byte [pop_timer], 0
    mov  word [cam_x], 0
    mov  word [time_left], 300
    mov  word [clk_acc], 0
    mov  byte [state], ST_PLAYING
    mov  word [hud_saved+10], 0FFFFh ; force the HUD to be redrawn
    call ClearEdges
    pop  es
    popa
    ret

; NewGame - everything from scratch
NewGame:
    mov  word [score_lo], 0
    mov  word [score_hi], 0
    mov  word [coins], 0
    mov  word [lives], 3
    call ResetLevel
    ret
