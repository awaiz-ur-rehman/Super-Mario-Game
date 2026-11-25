
; KbdISR - keyboard interrupt service routine
; Port 60h gives a scan code: press = code, release = code OR 80h.
; keys[code] = 1 while held. kedge[code] = 1 for one new press (menus, P, Esc).

KbdISR:
    push ax
    push bx
    push ds
    push cs
    pop  ds                         ; DS = CS so we can reach our variables
    in   al, 60h
    cmp  al, 0E0h                   ; E0 = prefix of an extended key (arrows)
    jne  .notE0
    mov  byte [e0flag], 1
    jmp  .ack
.notE0:
    cmp  al, 0E1h
    je   .ack
    cmp  byte [e0flag], 0
    je   .normal
    mov  byte [e0flag], 0           ; byte after E0: ignore the "fake shift"
    mov  bl, al                     ; codes (2Ah / 36h) some keyboards send
    and  bl, 7Fh
    cmp  bl, 2Ah
    je   .ack
    cmp  bl, 36h
    je   .ack
.normal:
    mov  bl, al
    xor  bh, bh
    and  bl, 7Fh                    ; BX = key number
    test al, 80h
    jnz  .release
    cmp  byte [keys+bx], 0
    jne  .ack                       ; auto-repeat of a held key
    mov  byte [keys+bx], 1
    mov  byte [kedge+bx], 1
    jmp  .ack
.release:
    mov  byte [keys+bx], 0
.ack:
    in   al, 61h                    ; tell the keyboard controller we read it
    mov  ah, al
    or   al, 80h
    out  61h, al
    mov  al, ah
    out  61h, al
    mov  al, 20h                    ; End-Of-Interrupt
    out  20h, al
    pop  ds
    pop  bx
    pop  ax
    iret


; ConsumeEdge - was a key newly pressed?  In: BL = scan code
; Out: AL = 1 if yes (and the flag is cleared), else 0.  Other regs unchanged.

ConsumeEdge:
    push bx
    xor  bh, bh
    mov  al, [kedge+bx]
    mov  byte [kedge+bx], 0
    pop  bx
    ret

; ClearEdges - forget all pending key presses. Registers unchanged.
ClearEdges:
    push es
    push di
    push cx
    push ax
    push cs
    pop  es
    mov  di, kedge
    mov  cx, 64
    xor  ax, ax
    cld
    rep  stosw
    pop  ax
    pop  cx
    pop  di
    pop  es
    ret
