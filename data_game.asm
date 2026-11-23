
chain_table dw 100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000


hx_list     db 8, 2, 13


    db %1, 0
    dw %2, %3
    db 1, 0, 0, 0
%endmacro
enemy_init:
    ENEMY 1, 17*16, 144             
    ENEMY 1, 28*16, 144             
    ENEMY 2, 31*16, 144             
    ENEMY 1, 34*16, 144             
    ENEMY 2, 45*16, 144             
    ENEMY 1, 47*16, 144             
    times 40 db 0            

hud_vars:
score_lo    dw 0
score_hi    dw 0
coins       dw 0
lives       dw 3
time_left   dw 300
hp          dw 1
hud_saved   dw 0,0,0,0,0,0FFFFh

; --- Mario ---
xpix        dw 32               
ypix        dw 144              
xfrac       dw 0                
yfrac       dw 0
vx          dw 0                
vy          dw 0
prev_ypix   dw 0
mheight     dw 16               
invuln      dw 0
facing      db 0                
on_ground   db 1
jump_ready  db 1
form        db 0                
stomp_chain db 0
mario_hidden db 0
flag_hit    db 0


cam_x       dw 0
clk_acc     dw 0
pop_x       dw 0
pop_y       dw 0
pop_timer   db 0
dtimer      db 0
win_phase   db 0
ltimer      dw 0
bonus_val   dw 0
pre_lo      dw 0
pre_hi      dw 0

enemies     times ENEMY_MAX*E_SIZE db 0
