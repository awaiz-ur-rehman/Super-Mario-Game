; UpdateCamera - step 8 (rules of section 5.3)
UpdateCamera:
    push ax
    mov  ax, [xpix]
    sub  ax, [cam_x]
    cmp  ax, 160
    jle  .left
    mov  ax, [xpix]
    sub  ax, 160                    ; follow Mario once he passes the middle
    cmp  ax, CAM_MAX
    jle  .cmax
    mov  ax, CAM_MAX                ; stop at the end of the level
.cmax:
    cmp  ax, [cam_x]
    jle  .left                      ; the camera never moves back
    mov  [cam_x], ax
.left:
    mov  ax, [cam_x]
    cmp  [xpix], ax
    jge  .right
    mov  [xpix], ax                 ; invisible wall at the left screen edge
    mov  word [vx], 0
    mov  word [xfrac], 0
.right:
    cmp  word [xpix], LEVEL_W*16-16
    jle  .out
    mov  word [xpix], LEVEL_W*16-16 ; end of the level
    mov  word [vx], 0
.out:
    pop  ax
    ret
