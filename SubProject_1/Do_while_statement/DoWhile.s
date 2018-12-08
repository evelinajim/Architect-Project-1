// done

.global main

main:

    b for           @FOR function branch
for:
    /*iniltiaze int i = 0*/
    MOV R0, #0      @ start length
    MOV R1, #20     @ end length

loop:
    @compare i to length, r0 and r1
    cmp r0, r1      /* compare r0 and r1 */

    @true branch here
    blt true_portion

    @false branch here
    b false_protion

true_portion:
    add R0, R0,#1       @ equals i++
    b loop              @ goes to the looping function

false_protion:
    bx lr @ ends the program
