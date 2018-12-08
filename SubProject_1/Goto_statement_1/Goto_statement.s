/* this one works correctly */

/* -- first.s */
/* Description 

	Intent: 
		To show the process and example of a goto statment in assembly 
	
	process in c  code: 
	
		
	
		main(){
			int var1 = 10; 
			goto func1;
		
		}
		
		func1(){
			var1 = 5;
			goto func3
		}
		func2(){
				var1 = 3;
			int var2 = 3;

		}
		
		func3(){
			var1 = 0;
			goto var2;
		}
		
		
	
	
	Registers used:
		r0
		r1
		
	
	
	Process of completion: 




 */

.global main

main:
    mov r0, #10
    b func1

func1:
    mov r0, #5
    b func3
func2:
    mov r0, #3
    mov r1, #3
    bx lr
	
func3:
    mov r0, #0
    b func2
