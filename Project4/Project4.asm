TITLE Project4		(project4.asm)

; Author: Chris Jacobs
; Last Modified: 2/22/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:                 Due Date: 2/21/2021 (2 Grace Days)
;
; Description: Prime Number Calculator: Accepts a number between 1 and 200 from the user. If the user enters invalid input, the program
; throws an error message and reprompts the user for valid input. When valid input is enterd, the program outputs that number of primes,
; outputting 10 per line. The porgram then says goodbye and terminates.
;              

INCLUDE Irvine32.inc

; global constants
UPPER_INPUT_BOUND = 200
LOWER_INPUT_BOUND = 1
START_PRIME = 2

.data

; data for user prompts
introLine1					BYTE		"Hello, and welcome to Prime Calculator! I'm Chris Jacobs, the guy who made this program.",0
introLine2					BYTE		"This program allows you to enter a number between 1 and 200",0
introLine3					BYTE		"When you give the correct input, it will display the number of primes based on the number you entered",0
inputPrompt					BYTE		"Please enter an integer between 1 and 200 now: ",0
errorPrompt					BYTE		"ERROR: Invalid Input. Please enter an integer between 1 and 200: ",0
goodbyePrompt				BYTE		"Goodbye!",0

; data for formatting
outputSpacer				BYTE		"   ",0

; data for user input
userInput					DWORD		?

; data for boolean flags
validInputFlag				DWORD		1
testIsPrimeFlag				DWORD		1

; data for counters
numPrimesPrinted			DWORD		0


.code
main PROC

	PUSH	OFFSET introLine3
	PUSH	OFFSET introLine2
	PUSH	OFFSET introLine1
	CALL	Introduction		


	PUSH	OFFSET inputPrompt
	PUSH	OFFSET userInput
	PUSH	OFFSET errorPrompt
	CALL	GetInput
										
											
	PUSH	userInput
	CALL	ShowPrimes				
	

	PUSH	OFFSET goodbyePrompt
	CALL	Goodbye
	

	Invoke	ExitProcess,0		; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: Introduction
;
; Description: Provides user with an introduction and
; directions for the program.
;
; Preconditions: None
;
; Postconsiditons: None
;
; Receives:
;		[ebp+16]	= mem OFFSET introLine3
;		[ebp+12]	= mem OFFSET introLine2
;		[ebp+8]		= mem OFFSET introLine1
;
; Returns: None
;
; ---------------------------------------------------------------------------------------------------------------
Introduction PROC
	PUSH	EBP
	MOV		EBP, ESP

	CALL	Crlf

	; Displays first intro string
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Displays second intro string
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Displays third intro string
	MOV		EDX, [EBP + 16]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Return to main procedure
	POP		EBP
	RET		12
Introduction ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: GetInput
;
; Description: Receives input from the user using ReadDec, 
; checks input by calling ValidateInput, loops until valid 
; input is received and stores that input in mem userInput
;
; Preconditions:
;		mem validInputFlag must be set to 1		
;
; Postconsiditons:
;		mem validInputFlag = 0
;
; Receives:
;		[EBP+16]	= mem OFFSET inputPrompt
;		[EBP+12]	= mem OFFSET userInput
;		[EBP+8]		= mem OFFSET errorPrompt
;
; Returns:
;		mem userInput = validated uesr's input
; ---------------------------------------------------------------------------------------------------------------
GetInput PROC
	PUSH	EBP
	MOV		EBP, ESP

	_loopWhileInputInvalid:
		; Prompt user for input and read in input using ReadDec procedure.
		MOV		EDX, [EBP + 16]
		CALL	WriteString
		CALL	ReadDec
		CALL	Crlf
		; Jump to _inputWasInvalid if invalid input detected by ReadDec procedure
		JC		_inputWasInvalid
		
		; Write user's input to memory variable userInput
		MOV		EDI, [EBP + 12]
		MOV		[EDI], EAX

		; Call ValidateInput procedure
		PUSH	EAX
		PUSH	OFFSET validInputFlag
		CALL	ValidateInput

		; Check validInputFlag to see if it was set to True (0) during the ValidateInput procedure
		; If True (0), we have valid input and can exit the procedure.
		; If False (1), continue to _inputWasInvalid and repeat the while loop.
		MOV		EBX, validInputFlag
		CMP		EBX, 0
		JZ		_exitGetInput

		; Alert the user that invalid input was detected and then repeat the while loop
		_inputWasInvalid:
			CALL	Crlf	
			MOV		EDX, [EBP + 8]
			CALL	WriteString
			CALL	Crlf
			JMP		_loopWhileInputInvalid

	; Exit the GetInput procedure
	_exitGetInput:
		POP		EBP
		RET		12
GetInput ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: ValidateInput
;
; Description: Validates the input recieved by the GetInput procedure, with input limits based on global variables 
; UPPER_INPUT_BOUND and LOWER_INPUT_BOUND
;
; Preconditions:
;		- mem validInputFlag set to inital value of 1
;		- global UPPER_INPUT_BOUND has been set
;		- global LOWER_INPUT_BOUND has been set
;
; Postconsiditons: None
;
; Receives:
;		[ebp+12]	= mem OFFSET userInput
;		[ebp+8]		= mem OFFSET validInputFlag	
;
; Returns:
;		mem validInputFlag = 0 (True)
;
; ---------------------------------------------------------------------------------------------------------------
ValidateInput PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	; JMP to _exitValidateInput if userInput is greater than UPPER_INPUT_BOUND
	MOV		EBX, [EBP + 12]
	CMP		EBX, UPPER_INPUT_BOUND
	JA		_exitValidateInput

	; JMP to _exitValidateInput if userInput is less than LOWER_INPUT_BOUND
	CMP		EBX, LOWER_INPUT_BOUND
	JB		_exitValidateInput

	; userInput is valid, so update mem validInputFlag to 0 to return True
	MOV		EBX, 0
	MOV		EDI, [EBP + 8]
	MOV		[EDI], EBX

	; Exit ValidateInput Procedure
	_exitValidateInput:
		POP		EBP
		RET		8
ValidateInput ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: ShowPrimes
;
; Description:	Displays the number of primes based on the user's input, displaying 10 prime numbers per line.
; Verifies that a number is prime by calling the IsPrime procedure.
;
; Preconditions:
;		- mem userInput must have been properly initialized and validated to contain a valid positive integer value
;		- global START_PRIME is set to a value of 2
;
; Postconsiditons: None
;
; Receives:
;		[ebp+8]		= mem OFFSET userInput
;
; Returns: None
;
;---------------------------------------------------------
ShowPrimes PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	; Loop setup
	MOV		EAX, START_PRIME		; EAX = current test prime
	MOV		ECX, [EBP + 8]			; ECX = loop counter (userInput)
	
	; Begin the loop
	_showPrimesLoop:
		; Reset testIsPrimeFlag back to False (1)
		MOV		testIsPrimeFlag, 1

		_whileNotPrime:
			; Test if testIsPrime flag is set, if so, jump to _endWhileNotPrime.
			CMP		testIsPrimeFlag, 0
			JZ		_endWhileNotPrime

			; Push loop variables to stack to prevent changes during PROC IsPrime.
			PUSH	ECX					
			PUSH	EAX

			; Push OFFSET testIsPrimeFlag to stack and call PROC IsPrime.
			PUSH	OFFSET testIsPrimeFlag	
			CALL	IsPrime

			; Pop/restore loop variables from stack to return to current loop state.
			POP		EAX
			POP		ECX
			
			; If testIsPrimeFlag is still False (1), JMP to _notPrime. Otherwise, print the validated prime.
			CMP		testIsPrimeFlag, 0
			JNZ		_notPrime

			; Print the current prime.
			CALL	WriteDec

			; Increment the number of primes that have been printed.
			MOV		EBX, numPrimesPrinted
			INC		EBX
			MOV		numPrimesPrinted, EBX

			; Offsets each prime by 3 spaces for formatting requirement.
			MOV		EDX, OFFSET outputSpacer
			CALL	WriteString

			; PUSH/store EAX to prepare for overwrite from CALL DIV then determine. If numPrimesPrinted % 10 
			; is 0, start a new line.
			PUSH	EAX
			MOV		EAX, numPrimesPrinted
			MOV		EDX, 0
			MOV		EBX, 10
			DIV		EBX
			CMP		EDX, 0

			; POP/restore EAX register.
			POP		EAX
			
			; If remainder is not 0, number of inputs was not a multiple of 10, so JMP to _notMultOfTen
			; Otherwise, continue through and call Crlf to display new line.
			JNZ		_notMultOfTen
			CALL	Crlf
			CALL	Crlf

			; Done printing foudn prime, so increment test prime (EAX) and exit _whileNotPrime loop.
			_notMultOfTen:
				INC		EAX
				JMP		_endWhileNotPrime

			; Increment current test prime (EAX), then repeat _whileNotPrime loop.
			_notPrime:
				INC	EAX
				JMP		_whileNotPrime

		; Found a prime number and printed it, so loop back to _showPrimesLoop
		_endWhileNotPrime:
			LOOP _showPrimesLoop

	; Exit the procedure
	_exitShowPrimes:
	POP		EBP
	RET		4
ShowPrimes ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: IsPrime
;
; Description: Determines if the current test number stored in EAX is prime. If prime, set the output parameter
; testIsPrimeFlag to True (0). Otherwise, do nothing.
;
; Preconditions:
;		- reg EAX holds a valid integer that can be tested for primeness
;		- reg ECX holds the previous loop counter from ShowPrimes and is overwritten during this procedure.

; Postconsiditons:
;		- reg EAX is unchanged
;		- reg ECX now holds a value of 2 and will need to be restored to its pre-call after calling procedure resumes.
;
; Receives:
;		[ebp+8]		= mem OFFSET testIsPrimeFlag
;
; Returns:
;		mem OFFSET testIsPrime = 0
;
; ---------------------------------------------------------------------------------------------------------------
IsPrime PROC
	PUSH	EBP
	MOV		EBP, ESP

	; If the current value in EAX is 2, return True.
	CMP		EAX, 2
	JZ		_returnTrue

	; Save EAX register to prepare for overwrite from CALL DIV.
	PUSH	EAX

	; If the current test prime div 2 has a remainder of 0 in EDX, pop/restore EAX register and then JMP to _returnFalse.
	; Otherwise, continue to the loop setup.
	MOV		EDX, 0
	MOV		EBX, 2
	DIV		EBX
	POP		EAX
	CMP		EDX, 0
	JZ		_returnFalse

	; Setup loop: starting loop at current test prime - 1
	MOV		ECX, EAX
	DEC		ECX

	; Start loop, decrement by 1 until ECX = 2
	_loopTestPrime:

		; If ECX = 2, the loop has compared every value above 2 and we can say the test value is prime, so JMP to _returnTrue.
		CMP		ECX, 2
		JZ		_returnTrue

		; Save value of EAX on stack
		PUSH EAX

		; Take current test prime (EAX) and divide it by the loop counter ECX, then Pop/Restore the EAX register that was overwritten by DIV.
		MOV		EDX, 0
		MOV		EBX, ECX
		DIV		EBX
		POP		EAX

		; If remainder (EDX) is 0, the current test value is divisable by ECX, so jub to _returnFalse.
		CMP		EDX, 0
		JZ		_returnFalse

		; If remainder (EDX) is not zero, continue the loop.
		LOOP	_loopTestPrime

	; Return true by setting the mem OFFSET for testIsPrimeFlag.
	_returnTrue:
		MOV		EBX, 0
		MOV		EDI, [EBP + 8]
		MOV		[EDI], EBX
		JMP		_exitIsPrime

	; Return false i.e. do nothing and keep the testIsPrimeFlag set to 1
	; Not sure if anything else needs to be done here but keeping this label for code readibility and 
	; in case anything needs to be added later.
	_returnFalse:

	; Exit the procedure
	_exitIsPrime:
	POP		EBP
	RET		4
IsPrime ENDP


; ---------------------------------------------------------------------------------------------------------------
; Name: Goodbye
;
; Description: A simple procedure to say goodbye.
;
; Receives:
;		[EBP+8]		= mem OFFSET goodbyePrompt
;
; ---------------------------------------------------------------------------------------------------------------
Goodbye PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 8] ; mem OFFSET goodbyePrompt
	CALL	Crlf
	CALL	Crlf
	CALL	WriteString
	CALL	Crlf

	POP		EBP
	RET		4
Goodbye ENDP


END main
