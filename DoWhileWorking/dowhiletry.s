.data
.balign 4
   string:  .asciz "\n x is : %d"
.balign 4
   x:       .word 0
.balign 4
   const1:  .word 10
/* CODE SECTION */
.text
.balign 4
.global main
.extern printf

main:
    push    {ip,lr}     @ This is needed to return to the Operating System

    ldr     r0,=x       @ x=1;
    mov     r1,#1
    str     r1,[r0]

do1:
    ldr     r0,=string  @ printf("\n x is : %d",x) Note: Printf may change registers R0,R1,R2,R3,R4
    ldr     r1,=x
    ldr     r1,[r1]
    bl      printf

    ldr     r0,=x
    ldr     r1,[r0]
    add     r1,r1,#1    @++X
    str     r1,[r0]
    ldr     r2,=const1
    ldr     r2,[r2]
    cmp     r1,r2       @ if (X<10)
    blt     do1

    mov     R0,#0

    pop     {ip, pc}    @ This is the return to the operating system
