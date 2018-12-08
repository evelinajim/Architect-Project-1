.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"
.balign 4
   string2: .asciz "\n k= %d,left=%d"
.balign 4
   A:       .skip 512 @128*4
.balign 4
   N:  .word 128

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

main:
    push    {ip,lr}     @ This is needed to return to the Operating System

    @@@  This bloc of code uses R4,R5,  R0,R1,R2,R3 are used for the call to random
    mov r5,#0           @ Initialize 128 elements in the array
    ldr r4,=A
loop1:
    ldr r0,=N
    ldr r0,[r0]
    cmp r5, r0
    bge end1
    bl      rand
    and r0,r0,#255
    str r0, [r4], #4
    add r5, r5, #1
    b loop1                  /* Go to the beginning of the loop */
end1:

    mov r5,#0           @ Print out the array
    ldr r4,=A
loop2:
    ldr r0,=N
    ldr r0,[r0]
    cmp r5, r0
    beq end2
    ldr r0,=string
    mov r1,r5
    ldr r2,[r4],#4
    bl printf
    add r5, r5, #1

    b loop2                  /* Go to the beginning of the loop */
end2:
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ OUTER LOOP @@@@@@@@@@@@@@@@@@@@@@@@@@


@ num,r0
@ k, r1
@ left, r2

@    for (int k=1; k < num; k *= 2 ) {

        mov r1,#1
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
OLoop1: ldr r0,=N       @ put N into r0 since r0 is num
        ldr r0,[r0]
        cmp r1,r0
        bge OLoop1e
        @ print the string
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
@        for (int left=0; left+k < num; left += k*2 ) {
        mov r2,#0
OLoop2: add r3,r2,r1   @ left+k < num;
        ldr r0,=N       @ put N into r0 since r0 is num
        ldr r0,[r0]
        cmp r3,r0
        bge OLoop2e
@ Here we can print out the loop variables to verify operation
@ We will need to save the registers which printf will alter
@ We can put these on the stack....
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
        lsl r3,r1,#1   @ left += k*2
        add r2,r2,r3
        b OLoop2
OLoop2e:
        lsl r1,r1,#1
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
        b OLoop1
OLoop1e:
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    mov     r0,#0

    pop     {ip, pc}    @ This is the return to the operating system

