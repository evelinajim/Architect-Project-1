// this is complete

.global main

main:

    b for // branch to the for function
for:
    /*iniltiaze int i = 0*/
    MOV R0, #0   // start
    MOV R1, #20  // end (length)

loop:
    //compare i to length
    cmp r0, r1      /* compare r0 and r1 */

    // if true branch here
    blt true_portion

    //if false branch here
    b false_protion

true_portion:
    add R0, R0,#1  // is equal to i++
    b loop         // hop back to the looping function

false_protion:
    bx lr // end program
