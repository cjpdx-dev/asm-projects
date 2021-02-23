TITLE Project4		(project4.asm)

; Author: Chris Jacobs
; Last Modified: 2/22/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:                 Due Date: 2/21/2021 (1 Grace Day)
;
; Description: Prime Number Calculator: Accepts a number between 1 and 200 from the user. If the user enters invalid input, the program
; throws an error message and reprompts the user for valid input. When valid input is enterd, the program outputs that number of primes,
; outputting 10 per line. The porgram then says goodbye and terminates.
;              

INCLUDE Irvine32.inc

; (insert macro definitions here)

UPPER_INPUT_BOUND = 200
LOWER_INPUT_BOUND = 1
START_PRIME = 2

.data

beginMainPrompt			BYTE		"Starting main procedure of Project4.asm...",0

introLine1				BYTE		"Hello, and welcome to Prime Calculator! I'm Chris Jacobs, the guy who made this program",0
introLine2				BYTE		"This program allows you to enter a number between 1 and 200",0
introLine3				BYTE		"When you give the correct input, it will display the number of primes based on the number you entered",0

inputPrompt				BYTE		"Please enter an integer between 1 and 200 now: ",0
userInput				DWORD		?
validInputFlag			DWORD		1
errorPrompt				BYTE		"ERROR: Invalid Input. Please enter an integer between 1 and 200: ",0

testIsPrimeFlag			DWORD		1
currentPrimeOutput		DWORD		1
outputSpacer			BYTE		"   ",0
numPrimesPrinted		DWORD		0


goodbyePrompt			BYTE		"Goodbye!",0


.code
main PROC

	MOV		EDX, OFFSET beginMainPrompt
	CALL	WriteString
	CALL	Crlf

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


; ---------------------------------------------------------
; Name: Introduction
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
;---------------------------------------------------------
Introduction PROC
	PUSH	EBP
	MOV		EBP, ESP

	; Displays first intro string
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	Crlf

	; Displays second intro string
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	Crlf

	; Displays third intro string
	MOV		EDX, [EBP + 16]
	CALL	WriteString
	CALL	Crlf

	; Return to main procedure
	POP		EBP
	RET		12
Introduction ENDP


; ---------------------------------------------------------
; Name: GetInput
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
;---------------------------------------------------------
GetInput PROC
	PUSH	EBP
	MOV		EBP, ESP

	_loopWhileInputInvalid:
		; Prompt user for input and read in input using ReadDec procedure.
		MOV		EDX, [EBP + 16]
		CALL	WriteString
		CALL	ReadDec

		; Jump to _inputWasInvalid if invalid input detected by ReadDec procedure
		JC		_inputWasInvalid
		
		; Write user's input to memory variable userInput
		MOV		EDI, [EBP + 12]
		MOV		[EDI], EAX

		; Call ValidateInput procedure
		; Input Parameter: EAX (decimal read in by ReadDec)
		; Output Parameter: Output Parameter: OFFSET for validInputFlag
		PUSH	EAX
		PUSH	OFFSET validInputFlag
		CALL	ValidateInput

		; Check validInputFlag to see if it was set to 0 during the ValidateInput procedure
		; If so we have valid input and can exit with procedure
		; If not, continue to _inputWasInvalid and repeat the loop
		MOV		EBX, validInputFlag
		CMP		EBX, 0
		JZ		_exitGetInput

		; Alert the user that invalid input was detected and then repeat the loop
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


; ---------------------------------------------------------
; Name: ValidateInput
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
;---------------------------------------------------------
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

	; userInput is valid, so adjust flag in memory that we passed as an output variable (OFFSET of validFlag)
	MOV		EAX, 0
	MOV		EDI, [EBP + 8]
	MOV		[EDI], EAX

	; Exit ValidateInput Procedure
	_exitValidateInput:
		POP		EBP
		RET		8
ValidateInput ENDP


; ---------------------------------------------------------
; Name: ShowPrimes
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
; Note: The results must be displayed 10 prime numbers per line, in ascending order, with at 
; least 3 spaces between the numbers. The final row may contain fewer than 10 values.
;---------------------------------------------------------
ShowPrimes PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	MOV		EAX, START_PRIME		; EAX = current test prime
	MOV		ECX, [EBP + 8]			; ECX = loop counter (userInput)
	_showPrimesLoop:
		MOV		testIsPrimeFlag, 1

		_whileNotPrime:
			CMP		testIsPrimeFlag, 0
			JZ		_endWhileNotPrime

			PUSH	EAX
			PUSH	OFFSET testIsPrimeFlag
			CALL	IsPrime

			CMP		testIsPrimeFlag, 0
			JZ		_notPrime

			; Print the current prime
			CALL	WriteDec

			; Increment number of primes printed
			MOV		EBX, numPrimesPrinted
			INC		EBX
			MOV		numPrimesPrinted, EBX
			MOV		EDX, OFFSET outputSpacer
			CALL	WriteString

			; Determine if numPrimesPrinted % 10 is 0, if so, start a new line
			PUSH	EAX
			MOV		EAX, numPrimesPrinted
			MOV		EDX, 0
			MOV		EBX, 10
			DIV		EBX
			CMP		EDX, 0
			JNZ		_notMultOfTen
			CALL	Crlf

			_notMultOfTen:
				POP		EAX
				INC		EAX
				MOV		testIsPrimeFlag, 0
				JMP		_endWhileNotPrime

			_notPrime:
				INC	EAX


		_endWhileNotPrime:
			LOOP _showPrimesLoop

	_exitShowPrimes:
	POP		EBP
	RET		4
ShowPrimes ENDP


; ---------------------------------------------------------
; Name: IsPrime
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
;---------------------------------------------------------
IsPrime PROC
	PUSH	EBP
	MOV		EBP, ESP




IsPrime ENDP


; ---------------------------------------------------------
; Name: Goodbye
;
; Description:
;
; Preconditions:
;
; Postconsiditons:
;
; Receives:
;
; Returns:
;
;---------------------------------------------------------
Goodbye PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	Crlf

	POP		EBP
	RET		4
Goodbye ENDP


END main
