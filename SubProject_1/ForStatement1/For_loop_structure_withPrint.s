.data
.balign 4
   string:  .asciz "\n x is : %d"
.balign 4
   x:       .word 0
/* CODE SECTION */
.text
.balign 4
.global main
.extern printf

main:
	push    {ip,lr}     	@ returns to the Operating System

    b for 			@ branch to the FOR function
    
for:
	ldr     r0,=x       	@ Loads r0 with x; x=0
    mov     r1,#0
    str     r1,[r0]



loop:

	ldr     r0,=string  	@ printf("\n x is : %d\n",x) NOTE this may change registers R0,R1,R2,R3,R4
    ldr     r1,=x		@ Loads r1 with x
    ldr     r1,[r1]		@loads r0 with r1, the actual value of r1 is now defined in data section
    bl      printf

				@ incrementation of r0 + 1
	ldr     r0,=x
    ldr     r1,[r0]
    add     r1,r1,#1    @++X
    str     r1,[r0]

	//compares i to length
	
    cmp r1, #10
		blt loop         @ branches back to the looping function

   mov     R0,#0

    pop     {ip, pc}    	@ returns to the operating system
    pop     {ip, pc}    	@ returns to the operating system
