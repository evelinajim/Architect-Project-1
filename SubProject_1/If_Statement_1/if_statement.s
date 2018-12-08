/* wprks well */

/* -- first.s */
/* start*/
.global main

main:
    mov r0, #10
    mov r1, #20
    b compare

compare:
    cmp r0, r1      @ compare r2 and 22
    bgt then           @ if true

    b else          @if not

then:
    mov r0, #1
    bx lr
else:
    mov r0, #2
    bx lr
