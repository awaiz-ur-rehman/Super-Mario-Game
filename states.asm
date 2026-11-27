
UpdateGame:
    mov  byte [flag_hit], 0
    call UpdateMario
    call UpdateEntities
    call ResolveEntities
    call UpdateClock
    call CheckDeathAndFlag
    cmp  byte [state], ST_PLAYING
    jne  .out
    call UpdateCamera
.out:
    ret


StateTitle:
    cmp  byte [redraw], 0
    je   .input
    call DrawTitleScreen
    call PresentAll
    mov  byte [redraw], 0
.input:
    mov  bl, SC_UP
    call ConsumeEdge
    or   al, al
    jnz  .toggle
    mov  bl, SC_DOWN
    call ConsumeEdge
    or   al, al
    jz   .enter
.toggle:
    xor  byte [menusel], 1
    mov  byte [redraw], 1
.enter:
    mov  bl, SC_ENTER
    call ConsumeEdge
    or   al, al
    jz   .esc
    cmp  byte [menusel], 0
    jne  .quit
    call NewGame
    ret
.esc:
    mov  bl, SC_ESC
    call ConsumeEdge
    or   al, al
    jz   .out
.quit:
    mov  byte [quit], 1
.out:
    ret

StatePlaying:
    mov  bl, SC_P
    call ConsumeEdge
    or   al, al
    jz   .nop
    mov  byte [state], ST_PAUSED
    mov  byte [redraw], 1
    ret
.nop:
    mov  bl, SC_ESC
    call ConsumeEdge
    or   al, al
    jz   .go
    mov  byte [state], ST_TITLE
    mov  byte [redraw], 1
    mov  byte [menusel], 0
    call ClearEdges
    ret
.go:
    call UpdateGame
    call DrawWorld
    call PresentPlay
    ret

StatePaused:
    cmp  byte [redraw], 0
    je   .in
    call DrawWorld
    call DrawPauseBox
    call PresentPlay
    mov  byte [redraw], 0
.in:
    mov  bl, SC_P
    call ConsumeEdge
    or   al, al
    jz   .esc
    mov  byte [state], ST_PLAYING
    ret
.esc:
    mov  bl, SC_ESC
    call ConsumeEdge
    or   al, al
    jz   .out
    mov  byte [state], ST_TITLE
    mov  byte [redraw], 1
    mov  byte [menusel], 0
    call ClearEdges
.out:
    ret

StateLifeLost:
    cmp  byte [redraw], 0
    je   .wait
    call DrawLifeLostScreen
    call PresentAll
    mov  byte [redraw], 0
.wait:
    sub  word [ltimer], 1
    jg   .out                       
    call ResetLevel                 
.out:
    ret

StateComplete:
    cmp  byte [redraw], 0
    je   .in
    call DrawCompleteScreen
    call PresentAll
    mov  byte [redraw], 0
.in:
    mov  bl, SC_ENTER
    call ConsumeEdge
    or   al, al
    jz   .out
    mov  byte [state], ST_TITLE
    mov  byte [redraw], 1
    mov  byte [menusel], 0
    call ClearEdges
.out:
    ret

StateGameOver:
    cmp  byte [redraw], 0
    je   .in
    call DrawGameOverScreen
    call PresentAll
    mov  byte [redraw], 0
.in:
    mov  bl, SC_ENTER
    call ConsumeEdge
    or   al, al
    jz   .out
    mov  byte [state], ST_TITLE
    mov  byte [redraw], 1
    mov  byte [menusel], 0
    call ClearEdges
.out:
    ret
