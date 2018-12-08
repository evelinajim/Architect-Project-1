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
	push    {ip,lr}

	ldr     r0,=x       @ x=0;
	mov     r1,#0
    str     r1,[r0]

    b do // branch to the do protion

do:
	// this is where the printing is happening

    ldr     r0,=string  @ printf("\n x is : %d",x) Note: Printf may change registers R0,R1,R2,R3,R4
    ldr     r1,=x
    ldr     r1,[r1]
    bl      printf

	b while

while:
	// increae the r0++
	ldr     r0,=x
    ldr     r1,[r0]
    add     r1,r1,#1    @++X
    str     r1,[r0]



    cmp r0, 10      /* compare r0 and 10 */
		 blt do

    mov     R0,#0

    pop     {ip, pc}    @ This is the return to the operating system

