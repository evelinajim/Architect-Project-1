.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"
.balign 4
   string2: .asciz "\n k= %d,left=%d"
.balign 4
   A:       .skip 512 @128*4
.balign 4
   N:  .word 128
.balign 4
   B:       .skip 512 @128*4

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
        left .req r2
        k    .req r1
        num .req r0
@    for (int k=1; k < num; k *= 2 ) {

        mov k,#1

OLoop1: ldr r0,=N       @ put &N into r0
        ldr num,[r0]    @ (* (&N)) into r0 since r0 is num
        cmp k,num
        bge OLoop1e

@        for (int left=0; left+k < num; left += k*2 ) {
        mov left,#0
OLoop2: add r3,left,k   @ left+k < num;
        ldr r0,=N       @ put N into r0 since r0 is num
        ldr num,[r0]
        cmp r3,num
        bge OLoop2e
@ Here we can print out the loop variables to verify operation
@ We will need to save the registers which printf will alter
@ We can put these on the stack....
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            @rght = left + k;
            @ rght has been set at line 76

            @rend = rght + k;
            rend .req r4
            rght .req r3

            add rend,rght,k

            @if (rend > num) rend = num;

            @ rend = (rend>num)?num:rend;
            cmp rend,num
            movgt rend,num

            @m = left; i = left; j = rght;
            m .req r5
            i .req r6
            j .req r7

            mov m,left
            mov i,left
            mov j,rght

            @while (i < rght && j < rend) {
 while1:    cmp i,rght
            bge endWhile1
            cmp j,rend
            bge endWhile1
            @    if (a[i] <= a[j]) {
            ldr  r8,=A           @ r8 <- &A

            add  r9,r8,i,lsl #2 @ because i*4 is the integer we want r9 <- &A + 4*i
            ldr  r9,[r9]
            @ ldr  r9,[r8,i,lsl #2]  This may be used instead to load the value into r9
            add  r10,r8,j,lsl #2
            ldr  r10,[r10]   @ place the value of a[j] into r10

            cmp  r9,r10
            @  r9 = (a[i] <= a[j])? r9:r10;
            @  b[m] = r9
            @  remember, r9 has a[i], r10 has a[j]
            movgt  r9,r10  @ This is the else part
            addgt  j,j,#1  @ this is the update in the "else" part
            addle  i,i,#1  @ this is the update in the "then" part
            ldr    r11,=B
            add    r11,r11,m,lsl #2
            str    r9,[r11]
            add    m,m,#1
            @        b[m] = a[i]; i++;
            @    } else {

            @        b[m] = a[j]; j++;
            @    }
            @    m++;
            @}
            b  while1
    endWhile1:
    while2: cmp  i,rght
            bge  while2end
            @while (i < rght) {
            @    b[m]=a[i];
            ldr  r8,=A
            ldr  r9,[r8,i,lsl #2]
            ldr  r8,=B
            str  r9,[r8,m,lsl #2]
            @    i++; m++;
            add  i,i,#1
            add  m,m,#1
            @}
            b  while2
    while2end:
    while3: cmp j,rend
            bge while3end
            @while (j < rend) {
            @    b[m]=a[j];
            ldr  r8,=A
            ldr  r9,[r8,j,lsl #2]
            ldr  r8,=B
            str  r9,[r8,m,lsl #2]
            @    j++; m++;
            add  j,j,#1
            add  m,m,#1
            @}
            b while3
    while3end:
            mov m,left
    form:   cmp m,rend
            bge formend


            @for (m=left; m < rend; m++) {
            @    a[m] = b[m];
            ldr  r8,=B
            ldr  r9,[r8,m,lsl #2]
            ldr  r8,=A
            str  r9,[r8,m,lsl #2]
            add m,m,#1
            @}
            b form
    formend:
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @ left .req r3
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

