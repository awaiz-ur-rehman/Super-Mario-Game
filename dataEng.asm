
msg_nomem   db "Not enough free memory for MARIO.",13,10,"$"

state_table dw StateTitle, StatePlaying, StatePaused, StateDying
            dw StateLifeLost, StateWin, StateComplete, StateGameOver

tile_procs  dw TileNone, TileGround, TileBrick, TileQuest
            dw TileQuest, TileEmpty, TilePipeTop, TilePipeTop
            dw TilePipeBody, TilePipeBody, TileStair, TileCoin
            dw TilePole, TileCastle, TileDoor
palette:
    db 23,37,63         ; 0  sky
    db 0,0,0            ; 1  black
    db 63,63,63         ; 2  white
    db 55,12,8          ; 3  red
    db 63,48,30         ; 4  skin
    db 30,16,4          ; 5  brown
    db 12,20,60         ; 6  blue
    db 63,56,8          ; 7  yellow
    db 46,22,8          ; 8  brick
    db 16,6,2           ; 9  dark brick / mortar
    db 4,44,4           ; 10 green
    db 2,24,2           ; 11 dark green
    db 28,60,20         ; 12 light green
    db 52,40,20         ; 13 tan
    db 40,40,44         ; 14 grey
    db 34,4,2           ; 15 dark red
    db 40,24,8          ; 16 dirt
    db 50,36,2          ; 17 gold
    db 63,44,12         ; 18 question block orange
    db 34,22,10         ; 19 empty block


cloud_data  dw 40,28, 150,44, 300,24, 450,40, 600,28, 750,44, 900,24
bush_data   dw 100, 230, 440, 610


s_score     db "SCORE",0
s_coins     db "COINS",0
s_world     db "WORLD",0
s_time      db "TIME",0
s_lives     db "LIVES",0
s_health    db "HEALTH",0
s_x         db "x",0
s_w11       db "1-1",0
s_title     db "SUPER MARIO",0
s_engine    db "E N G I N E",0
s_hint      db "UP/DOWN = MOVE   ENTER = SELECT",0
s_start     db "START GAME",0
s_exit      db "EXIT",0
s_arrow     db ">",0
s_footer    db "COAL SEMESTER PROJECT",0
s_paused    db "PAUSED",0
s_resume    db "PRESS P TO RESUME",0
s_world11   db "WORLD 1-1",0
s_liveleft  db "LIVES LEFT",0
s_gameover  db "GAME OVER",0
s_final     db "FINAL SCORE:",0
s_coinsc    db "COINS:",0
s_timec     db "TIME:",0
s_enter_title db "PRESS ENTER FOR THE TITLE",0
s_complete  db "LEVEL COMPLETE!",0
s_timeleft  db "TIME LEFT",0
s_x50       db "x 50",0
s_bonus     db "TIME BONUS",0
s_finalsc   db "FINAL SCORE",0
s_enter_cont db "PRESS ENTER TO CONTINUE",0

state       db 0
redraw      db 1
menusel     db 0
quit        db 0

frames      dw 0
tcode       dw 0


backseg     dw 0
hudseg      dw 0
drawseg     dw 0
fontseg     dw 0
fontoff     dw 0
ox          dw 0
oy          dw 0
hcol        dw 0
spx         dw 0
spy         dw 0
spflags     dw 0
cy          dw 0
firstcol    dw 0
chcol       db 0
tscale      dw 1
glyph       times 8 db 0

e0flag      db 0
oldkbd      dd 0
keys        times 128 db 0
kedge       times 128 db 0
map_orig    times MAP_SIZE db 0
map_work    times MAP_SIZE db 0
