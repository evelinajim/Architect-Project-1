/* arm_recursive_mergesort.s */
.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"   @ define data format this is to print array
.balign 4
   string1: .asciz "\n l= %d,r=%d"
.balign 4
   A:       .skip 512 @128*4
.balign 4
   L:       .skip 256 @left half the array
.balign 4
   R:       .skip 256 @right half the array
.balign 4
   N:  .word 127

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

    @REFERENCES
    @ Merges two subarrays of arr[]. 
    @ First subarray is arr[l..m] 
    @ Second subarray is arr[m+1..r]	
	@ void merge(int arr[], int l, int m, int r){
merge: push  {r0,r1,r2,r3,LR}     //saves the state before entering method call
		   	   
	   push  {r5,r6,r7,r8,r9} // saves register state --> restore later
    @ int i, j, k;
    @requests labels for r5-r9
       i     .req r5
       j     .req r6
       k     .req r7
       n1	 .req r8
       n2    .req r9
    
	   push  {r2} //save m
    @ int n1 = m - l + 1;
       sub   r2,r2,r1       // r2 = r2-r1 = m-l 
	   add 	 n1,r2,#1		// n1 = m-l+1
	   
	   pop   {r2} //restore m
    
       sub   n2,r3,r2       // n2 = r3-r2 = r-m; int n2 = r-m

    @create arrays in data section
    @ temp arrays
    @ int L[n1], R[n2];
    
       push  {r0,r1,r2,r3}       		  
                                @ data copied into temp arrays L[] and R[] 
                                @ for (i = 0; i < n1; i++)
       mov   i,#0                  @ i = 0;
  forL:cmp   i,n1                  @ compare i < n1
       bge   forLend               @ end loop if false
                                @ L[i] = arr[l + i];
       add   r2,r1,i			   @ r2 --> r1 + 1, r2 = l + i
       ldr   r3,[r0,r2,lsl #2]     @ r3 = *&A[(l+i)*4] = arr[l+i]
       ldr   r2,=L                 @ load L into r2
       str   r3,[r2,i,lsl #2]      @ store arr[l+i] in L[i]
       add   i,i,#1                @ i++
       b     forL
forLend:
       pop   {r0,r1,r2,r3}	 		  

       push  {r0,r1,r2,r3}       
                                @ for (j = 0; j < n2; j++) 
       mov   j,#0                  @ j = 0;
  forR:cmp   j,n2                  @ compare j < n2
       bge   forRend               @ if false = end loop
    @ R[j] = arr[m + 1 + j]; 
       add   r1,r2,#1			   @ m is in r2, so r1 becomes r2+1 which is m+1
       add   r1,r1,j			   @ m+1 is in r1, r1 becomes m+1+j
       ldr   r3,[r0,r1,lsl #2]     @ load r3 with *[base&A + (m+1+j)*4] aka arr[m+1+j]
       ldr   r1,=R                 @ load &R into r1
       str   r3,[r1,j,lsl #2]      @ store arr[m+1+j] in R[j], R[j] = arr[m + 1 + j]; 
       add   j,j,#1                @ j++
       b     forR
forRend:	  
       pop   {r0,r1,r2,r3}       	   

    @ Merge temp arrays back into arr[l] arr[r]
    
		mov i,#0                    @ i = 0;  initial index of first subarray
        
    
		mov j,#0                    @ j = 0;  initial index of second subarray 
    
    
		mov k,r1                    @ k = l; initial index of merged subarray 
 
	 @ while (i < n1 && j < n2){
		push   {r1,r2,r3,r4}
while1: cmp    i,n1                  @ while i < n1 and
        bge    endWhile1             @ end loop if above statement is false
        cmp    j,n2                  @  j < n2
        bge    endWhile1             @ end loop if above statement is false
        ldr    r1,=L                 @ load r1 with base &L
        ldr    r2,[r1,i,lsl #2]      @ load r2 with *L[i*4] (cause of 4 byte alignment)
        ldr    r1,=R                 @ load r1 with base R
        ldr    r3,[r1,j,lsl #2]      @ load r3 with *R[j*4] (cause of 4 byte alignment)
     
     /* r2 holds L[i] and r3 holds R[j] */
     /* REMINDER base address of A SHOULD still be in r0 */     
     
	 @ if (L[i] <= R[j]){
	 /* conditional assignment r2 = (L[i] <= R[j]) ? r9:r10 is more efficient */
        cmp    r2,r3                 @ if (L[i] <= R[j])
        movgt  r2,r3                 @ r2 is L[i] or R[j] conditionally
	 @   	arr[k] = L[i]; 
        str    r2,[r0,k,lsl #2]      @ store r2 in A[k*4], A[k] = L[i] or R[j]
	 @ 	i++; 
        addle  i,i,#1                @ if r9 is L[i], i++
	 @ } 
	 @ else { 
	 @ 	arr[k] = R[j]; 
	 @ 	j++; 
        addgt  j,j,#1                @ if r9 is R[j], j++ 
	 @ } 
	 @ k++; 
        add    k,k,#1                @ k++
        b      while1                @ go to the start of loop
endWhile1:
	 @ }
	  
	 @ /* Copy the remaining elements of L[], if there are any */
	 @ while (i < n1){ 
while2: cmp    i,n1
        bge    while2end
	 @ 	arr[k] = L[i]; 
        ldr    r1,=L
        ldr    r2,[r1,i,lsl #2]
        str    r2,[r0,k,lsl #2]
	 @ 	i++; 
        add    i,i,#1
	 @ 	k++; 
        add    k,k,#1
        b      while2
	 @ }
while2end:	 
	 
     @ if any, copy the remaining elements of R[]
     @ while (j < n2){ 
while3: cmp    j,n2
        bge    while3end
     @		arr[k] = R[j]; 
        ldr    r1,=R
        ldr    r2,[r1,j,lsl #2]
        str    r2,[r0,k,lsl #2]
     @ 	j++; 
        add    j,j,#1
     @ 	k++; 
        add    k,k,#1
        b      while3
     @ } 
while3end:
        pop    {r1,r2,r3,r4}
        
        pop    {r5,r6,r7,r8,r9}

     /* REFERENCE; variable
    @  r0=arr @ r1=l @ r2=m @ r3=r
       i     .req r5
       j     .req r6
       k     .req r7
       n1	 .req r8
       n2    .req r9
     */

mergeEnd:
		 pop  {r0,r1,r2,r3,PC}
@ }

        @ mergeSort(int arr[], int l, int r) {
mergeSort: push  {r0,r1,r2,LR}     @saves state before entering recursive
       
           push  {r0,r1,r2}        // saves r0-r2 
           ldr   r0,=string1       // loads format
            bl   printf            // prints
           pop   {r0,r1,r2}        // returns r0-r2 to previous state
       
                                    @ if (l < r) {
           cmp   r1,r2              @ is l less than r?
           bge   mergeSortEnd       @ if so end mergesort
        
           push  {r1,r2}           @ saves L and R
           
                                    @ int m = l+(r-l)/2; also (l+r)/2 <-- this one overflows tho (i.e. l and h)
           sub   r2,r2,r1           @ r2 = r-l 
           lsr   r2,r2,#1           @ r2 = (r-l)/2
           add   r2,r2,r1           @ r2 = l+(r-l)/2 = m
           push  {r2}               @ save m
         
         @formal params
        @sort first and second halves HERE
        @ mergeSort(arr, l, m); 
        @Remember l is R1, R2 is r=m
             bl  mergeSort
            @ method call r0=arr, r1=l, r2=m 
        @@@@@@  setting params for method call @@@@@@ 
           pop   {r3}          @ pops m into r3 to use in m+1 operation
           pop   {r1,r2}       @ restores l and r; r1=l and r2=r
           push  {r1,r2}	   @ saves r1 and r2
           push  {r3}          @ saves m 
           add   r1,r3,#1 	   @ r1 = m+1           
        
            @formal params 
        @ mergeSort(arr, m+1, r);
            bl   mergeSort
           
        @@@@@@ setting params for method call @@@@@@ 
           pop   {r3}		   @ restore r3, r3 = m 
           pop   {r1,r2}       @ restore r1 and r2, r1=l,r2=r
           push  {r2}		   @ save r 
           mov	 r2,r3		   @ r2 = m
           pop 	 {r3}		   @ r3 = r 
		
        /* register should contain r0=arr,r1=l,r2=m,r3=r */ 
        @ merge(arr, l, m, r);
		    bl 	 merge	   
        
        @ }
       
mergeSortEnd:			 
           pop {r0,r1,r2,PC}  @ notice put LR into PC to force return
        @ }

main:
    push    {ip,lr}     @ returns to  Operating System
    
@@@@@@@@@@@@@@@@ ARRAY LOOP @@@@@@@@@@@@@@@@
/* this section creates an array of size N */
    mov  r5,#0           @ move 0 into register 5; int i = 0
    ldr  r4,=A           @ load r4 with A
    
loop1:
    ldr  r0,=N           @ load r0 with N stores the constant N
    ldr  r0,[r0]         @ load r0 with *N REMEMBER: actual value of N is defined in data section
    cmp  r5, r0          @ i < n; loop reached all N interations?
    bge  end1            @ if r5 >= r0, goto end1 (ENDS LOOP) this happens after the loop has reached N iterations.
     bl  rand            @ else, continue. calls fxn random to generate random number
    and  r0,r0,#255      @ calculate a random number between 0 and 255 by using the AND result w/ 255
    @r4 = &A+4: update address in r4 by 4 bytes
    str  r0,[r4],#4      @ Store current contents of r0 at &A
    add  r5,r5,#1        @ i++; add 1 to r5
    b    loop1           @ returns to the start of loop1
end1:
@@@@@@@@@@@@@@@@ PRINT LOOP @@@@@@@@@@@@@@@@
/* prints all the elements in an array of size N */
    mov  r5,#0           @ int i = 0
    ldr  r4,=A           @ load r4 with A
    
loop2:
    ldr  r0,=N           @ holds the value of the constant N! Loads r0 with N
    ldr  r0,[r0]         @ Loads r0 with *N
    cmp  r5, r0          @ i < n; compare the values in r5 and r0
    beq  end2            @ if yes, goto end2
                         @ string contains the format of our output
    ldr  r0,=string      @ else load r0 with string. 
    mov  r1,r5           @ r1 = r5
    ldr  r2,[r4],#4      @ r4 = &A+4; load r2 with *A then point to the next element
     bl  printf          
    add  r5, r5, #1      @ i++
    b    loop2           @ return to the start of loop2
end2:

 /* this is where the parameters for mergeSort are set */
 @ mergeSort(arr, l, r);
 
    ldr     r0,=A		@ load A; here is int ;arr[]
    mov     r1,#0  		@ r1 = 0;  here is l
    ldr     r2,=N		@ load r2; with N
    ldr     r2,[r2]		@ r2 = *N;  here is r
     bl     mergeSort
     
@@@@@@@@@@@@@@@ PRINT LOOP 2 @@@@@@@@@@@@@@@@
/* this loop prints the array which should be sorted */
      mov  r5,#0
      ldr  r4,=A
loop3:
      ldr  r0,=N
      ldr  r0,[r0]
      cmp  r5, r0
      beq  end3
      ldr  r0,=string
      mov  r1,r5
      ldr  r2,[r4],#4
       bl  printf
      add  r5,r5,#1
      b    loop3
end3:

    mov     r0,#0

    pop     {ip, pc}    @ returns to the os
