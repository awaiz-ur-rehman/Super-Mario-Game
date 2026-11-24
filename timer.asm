
WaitRetrace:
    push ax
    push dx
    mov  dx, 3DAh
.end_old:
    in   al, dx
    test al, 8
    jnz  .end_old
.start_new:
    in   al, dx
    test al, 8
    jz   .start_new
    pop  dx
    pop  ax
    ret


UpdateClock:
    inc  word [clk_acc]
    cmp  word [clk_acc], 35
    jb   .inv
    mov  word [clk_acc], 0
    cmp  word [time_left], 0
    je   .inv
    dec  word [time_left]
.inv:
    cmp  word [invuln], 0
    jle  .pop
    dec  word [invuln]
.pop:
    cmp  byte [pop_timer], 0
    je   .out
    dec  byte [pop_timer]
.out:
    ret
