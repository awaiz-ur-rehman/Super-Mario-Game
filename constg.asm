HIT_L       equ 2                   ; Mario's hit box is 12 px wide:
HIT_R       equ 14                  ; from x+2 up to (not including) x+14

;Physics, 8.8 fixed point (high byte = pixels, low byte = fraction
ACCEL       equ 0020h               ; 0.125 px/frame^2
FRICTION    equ 0010h               ; 0.0625
WALK_MAX    equ 0180h               ; 1.5 px/frame
RUN_MAX     equ 0280h               ; 2.5 px/frame
GRAVITY     equ 0040h               ; 0.25
JUMP_V      equ 0FA80h              ; -5.5 (up)
JUMP_CUT    equ 0FE00h              ; -2.0 (space released early)
MAX_FALL    equ 0400h               ; 4.0
STOMP_V     equ 0FD00h              ; -3.0 bounce after a stomp
STOMP_HI    equ 0FB00h              ; -5.0 bounce while Space is held
INVULN_FRAMES equ 60                ; 2 seconds at 30 frames/second
;Enemy / item record (10 bytes)
E_TYPE      equ 0                   ; 0 none, 1 goomba, 2 koopa, 3 mushroom
E_STATE     equ 1                   ; 0 waiting, 1 walking, 2 flat, 3 shell, 4 sliding shell
E_X         equ 2                   ; word, world x
E_Y         equ 4                   ; word, y (top)
E_DIR       equ 6                   ; 0 = right, 1 = left
E_TIMER     equ 7                   ; flat timer / kick grace timer
E_FRAC      equ 8                   ; fraction of the x position
E_GND       equ 9                   ; 1 when standing on something
E_SIZE      equ 10
ENEMY_MAX   equ 10
