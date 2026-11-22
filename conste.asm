; CONSTANTS (EQU = a name for a number, uses no memory)

SCREEN_W    equ 320
SCREEN_H    equ 200
LEVEL_W     equ 60                  ; level width in tiles
MAP_SIZE    equ 720                 ; 60 x 12 tiles
CAM_MAX     equ 640                 ; level width in pixels - 320
GROUND_Y    equ 160                 ; y of the top of the ground (row 10)
POLE_COL    equ 57                  ; tile column of the flag pole


;Keyboard scan codes
SC_ESC      equ 01h
SC_ENTER    equ 1Ch
SC_P        equ 19h
SC_LSHIFT   equ 2Ah
SC_SPACE    equ 39h
SC_UP       equ 48h
SC_DOWN     equ 50h
SC_LEFT     equ 4Bh
SC_RIGHT    equ 4Dh

;Game states
ST_TITLE    equ 0
ST_PLAYING  equ 1
ST_PAUSED   equ 2
ST_DYING    equ 3
ST_LIFELOST equ 4
ST_WIN      equ 5
ST_COMPLETE equ 6
ST_GAMEOVER equ 7

;Tile codes
T_SKY       equ 0
T_GROUND    equ 1
T_BRICK     equ 2
T_QCOIN     equ 3
T_QMUSH     equ 4
T_EMPTY     equ 5
T_PIPETL    equ 6
T_PIPETR    equ 7
T_PIPEBL    equ 8
T_PIPEBR    equ 9
T_STAIR     equ 10
T_COIN      equ 11
T_POLE      equ 12
T_CASTLE    equ 13
T_DOOR      equ 14


;Palette colour numbers
C_SKY       equ 0
C_BLACK     equ 1
C_WHITE     equ 2
C_RED       equ 3
C_SKIN      equ 4
C_BROWN     equ 5
C_BLUE      equ 6
C_YELLOW    equ 7
C_BRICK     equ 8
C_DKBRICK   equ 9
C_GREEN     equ 10
C_DKGREEN   equ 11
C_LTGREEN   equ 12
C_TAN       equ 13
C_GREY      equ 14
C_DKRED     equ 15
C_DIRT      equ 16
C_GOLD      equ 17
C_QORANGE   equ 18
C_EMPTYBODY equ 19
PAL_COUNT   equ 20

CLOUD_COUNT equ 7
BUSH_COUNT  equ 4


; MACROS

; RECTO dx,dy,w,h,colour : filled rectangle at (ox+dx, oy+dy). Changes AX only.
%macro RECTO 5
    mov  ax, [ox]
    add  ax, %1
    push ax
    mov  ax, [oy]
    add  ax, %2
    push ax
    push word %3
    push word %4
    push word %5
    call FillRect
%endmacro

; RECT x,y,w,h,colour : filled rectangle at fixed numbers
%macro RECT 5
    push word %1
    push word %2
    push word %3
    push word %4
    push word %5
    call FillRect
%endmacro

; TEXT x,y,colour,label : draw a zero-terminated string
%macro TEXT 4
    push word %1
    push word %2
    push word %3
    push word %4
    call DrawText
%endmacro

; NUM x,y,colour,hi,lo,digits : draw a 32-bit number with leading zeros
%macro NUM 6
    push word %1
    push word %2
    push word %3
    push word %4
    push word %5
    push word %6
    call DrawNumber
%endmacro

; SOLID px,py : pushes two values and calls IsSolid (AL = 1 if solid)
%macro SOLID 2
    push %1
    push %2
    call IsSolid
%endmacro

; LOOPFAR label : like LOOP but works for any distance
%macro LOOPFAR 1
    dec  cx
    jz   %%done
    jmp  %1
%%done:
%endmacro
