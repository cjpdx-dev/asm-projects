TITLE Project 2 Basic Logic and Arithmetic Program   (Project2_ChrisJacobs.asm)

; Author: Chris Jacobs
; Last Modified: 1/25/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 2                Due Date: 1/24/2021			Submitted: 1/25/2021 (1 Grace Day)
; -------------------------------------------------------------------------------------------------------------------------
; Description: A MASM x86 Assembly program that performs addition, subtraction and division calculations. The program first
; displays a title and author, followed by instructions for the user and a description of the extra credit features. The
; program then accepts a series of inputs from the user which are stored. If the inputs are not in decending order, the
; program displays an error message and asks the user to reenter the numbers. 
; 
; When a correct series of values have been entered by the user, the programs performs and displays the calculations. The 
; program then asks the user if they would like to rerun the program. If the user inputs [ENTER] only, the program restarts.
; If the user hits "X" (or anything other input) the program exits.
; -------------------------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data

	; Variables for name, title, program instructions, and extra credit prompts.
	displayNameAndTitle			BYTE	"Addition and Subtraction Calculator - By Chris Jacobs",0
	userIntructions				BYTE	"Please enter three numbers (A, B, C) in decending order to get the sums and differences of those numbers. ",0
	extraCreditPrompt_1			BYTE	"**EC: Program verifies the numbers are in decending order.",0
	extraCreditPrompt_2			BYTE	"**EC: Program handles negative results and computes B-A, C-A, C-B, and C-B-A",0
	extraCreditPrompt_3			BYTE	"**EC: Program repeats until the user chooses to quit",0
	extraCreditPrompt_4			BYTE	"**EC: Program calculates the quotients A/B, A/C, B/C, printing the quotient and remainder",0

	; Variables for input prompts
	inputPrompt_A				BYTE	"First Number: ",0
	inputPrompt_B				BYTE	"Second Numbner: ",0
	inputPrompt_C				BYTE	"Third Number: ",0

	; Variables to store user input
	userInput_A					DWORD	?
	userInput_B					DWORD	?
	userInput_C					DWORD	?

	; Variables to store each result as its calculated

	result_A_plus_B				DWORD	? 
	result_A_minus_B			DWORD	?

	result_A_plus_C				DWORD	?
	result_A_minus_C			DWORD	?

	result_B_plus_C				DWORD	?
	result_B_minus_C			DWORD	?

	result_A_plus_B_plus_C		DWORD	?

	; Variables to store extra credit results
	result_B_minus_A			DWORD	?
	result_C_minus_A			DWORD	?
	result_C_minus_B			DWORD	?
	
	result_C_minus_B_minus_A	DWORD	?

	; Subtraction, addition, and equal sign strings
	sub_sign					BYTE	" - ",0
	add_sign					BYTE	" + ",0
	div_sign					BYTE	" / ",0
	equal_sign					BYTE	" = ",0
	r_prefix					BYTE	'r',0


	; Error and exit variables
	nonDecendingErrorPrompt		BYTE	"ERROR: Numbers were not in non-decending order. Please try again...",0

	exitUserInput				DWORD	?	
	
	askToContinuePrompt			BYTE	"Would you like to play again? Press [ENTER] to play again or enter [X] to exit: ",0
	exitDetectedPrompt			BYTE	"Exit Input Detected: Program Terminating",0
	goodbyePrompt				BYTE	"Goodbye!",0

.code
main PROC

; Display name, program title and instructions on the output screen
	
	MOV		EDX, OFFSET displayNameAndTitle
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	MOV		EDX, OFFSET extraCreditPrompt_1
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	MOV		EDX, OFFSET extraCreditPrompt_2
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	MOV		EDX, OFFSET extraCreditPrompt_3
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	MOV		EDX, OFFSET extraCreditPrompt_4
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Prompts the user with instructions, then prompts user to enter three numbers and store each in memory.
; Checks to see if inputs are in decending order. If not in decending order, throw error message and
; repeat the input prompts. This sequence repeats until the user hits enter with no input,  at which
; point the program exits.

_TryInputs:
	
	MOV		EDX, OFFSET userIntructions
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	; First Input - Terminate program if user hits enter with no input
	MOV		EDX, OFFSET inputPrompt_A
	CALL	WriteString
	CALL	ReadDec
	MOV		userInput_A, EAX

	; Get second input
	MOV		EDX, OFFSET inputPrompt_B
	CALL	WriteString
	CALL	ReadDec
	MOV		userInput_B, EAX

	; Check to see if first and second inputs are in decending order
	MOV		EAX, userInput_A
	CMP		EAX, userInput_B
	JBE		_PromptNonDecendingError

	; Get third input
	MOV		EDX, OFFSET inputPrompt_C
	CALL	WriteString
	CALL	ReadDec
	JC		_PromptExitInputDetected
	MOV		userInput_C, EAX

	; Check to see if third input is in decending order from second (and logically, first)
	MOV		EAX, userInput_B
	CMP		EAX, userInput_C
	JBE		_PromptNonDecendingError

	CALL	CrLf


; Calculate and display summations

	MOV		EAX, userInput_A				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET add_sign
	CALL	WriteString
	MOV		EAX, userInput_B
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_A		
	ADD		EAX, userInput_B		
	MOV		result_A_plus_B, EAX			; Store result A + B
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_A				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET add_sign
	CALL	WriteString
	MOV		EAX, userInput_C
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_A		
	ADD		EAX, userInput_C		
	MOV		result_A_plus_C, EAX			; Store result A + C
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_B				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET add_sign
	CALL	WriteString
	MOV		EAX, userInput_C
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_B		
	ADD		EAX, userInput_C		
	MOV		result_B_plus_C, EAX			; Store result B + C
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_A				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET add_sign
	CALL	WriteString
	MOV		EAX, userInput_B
	CALL	WriteDec
	CALL	WriteString
	MOV		EAX, userInput_C
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_A		
	ADD		EAX, userInput_B		
	ADD		EAX, userInput_C		
	MOV		result_A_plus_B_plus_C, EAX		; Store result A + B + C
	CALL	WriteInt

	CALL	CrLf
	CALL	CrLf

; Calculate and display subtractions
	
	MOV		EAX, userInput_A				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_B
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_A		
	SUB		EAX, userInput_B		
	MOV		result_A_minus_B, EAX			; Store result A - B
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_A				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_C
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_A		
	SUB		EAX, userInput_C		
	MOV		result_A_minus_C, EAX			; Store result A - C
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_B				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_C
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_B		
	SUB		EAX, userInput_C
	MOV		result_B_minus_C, EAX			; Store result B - C
	CALL	WriteInt

	CALL	CrLf
	CALL	CrLf

; Calculate and display subtractions that yield negative results
	
	MOV		EAX, userInput_B				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_A
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString
	
	MOV		EAX, userInput_B
	SUB		EAX, userInput_A				
	MOV		result_B_minus_A, EAX			; Store result B - A
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_C				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_A
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_C
	SUB		EAX, userInput_A				
	MOV		result_C_minus_A, EAX			; Store result C - A
	CALL	WriteInt

	CALL	CrLf
	
	MOV		EAX, userInput_C				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_B
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString
	MOV		EAX, userInput_C
	SUB		EAX, userInput_B			
	MOV		result_C_minus_B, EAX			; Store result C - B
	CALL	WriteInt

	CALL	CrLf

	MOV		EAX, userInput_C				; Display equation
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_B
	CALL	WriteDec
	MOV		EDX, OFFSET sub_sign
	CALL	WriteString
	MOV		EAX, userInput_A
	CALL	WriteDec
	MOV		EDX, OFFSET equal_sign
	CALL	WriteString

	MOV		EAX, userInput_C
	SUB		EAX, userInput_B			
	SUB		EAX, userInput_A		
	MOV		result_C_minus_B_minus_A, EAX	; Store result C - B - A
	CALL	WriteInt

	CALL	CrLf
	CALL	CrLf

; Calculate and display quotients and remainder of A/B, A/C, B/C

	
	


; Ask the user if they would like to continue. If they press enter, repeat the program.
; If the user enters X (or any other value), exit the program.

	MOV		EDX, OFFSET askToContinuePrompt
	CALL	WriteString
	CALL	ReadDec
	JC		_TryInputs						; if CF flag was set, user hit only enter, so jump to _TryInputs and repeat program
	JMP		_PromptExitInputDetected		; otherwise, user hit "X" (or some other input), so exit program

; Display a closing message and exit the program
_ExitProgram:

	CALL	CrLf
	MOV		EDX, OFFSET goodbyePrompt
	CALL	WriteString
	CALL	CrLf
	Invoke	ExitProcess,0	; exit to operating system

; Prints an error message for non decending user input, then jumps back to _TryInputs
_PromptNonDecendingError:
	
	CALL	CrLf
	MOV		EDX, OFFSET nonDecendingErrorPrompt
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	JMP		_TryInputs

_PromptExitInputDetected:
	CALL	CrLf
	MOV		EDX, OFFSET exitDetectedPrompt
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	JMP		_ExitProgram
	
main ENDP

; (insert additional procedures here)

END main
