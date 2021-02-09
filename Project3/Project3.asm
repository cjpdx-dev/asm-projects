TITLE Project 3    (Project3.asm)

; Author: Chris Jacobs
; Last Modified: 2/9/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 3                Due Date: 2/7	Submitted: 2/9 (2 Grace Days)
; Description: A MASM program that (1) displays the program title and programmer's name, (2) gets the user name and greets the user,
;				(3) repeatedly prompts the user to enter a number, (4) validates the user's input to be in a specific range, (5) notifies
;				the user of an invalid input, (6) counts and accumulates the valid user's numbers until a non-negative number is entered 
;				using the sign flag, (7) calculates the rounded integer average of the valid numbers and store in a variable, then (8) displays
;				the count of validated numbers, the sum of the numbers, the min and max, and the average of the numbers. Then gives the user
;				and exit message.
;

INCLUDE Irvine32.inc

; Constants for input ranges: -200 to -100 (inclusive)
LOWER_LIMIT_1 =	-200
UPPER_LIMIT_1 =	-100

; Constants for input ranges: -50 to -1 (inclusive)
LOWER_LIMIT_2 = -50
UPPER_LIMIT_2 = -1

.data

nameAndProgramTitle		BYTE		"Project 3 - Data Validation, Looping, and Constants - By Chris Jacobs",0	

namePrompt				BYTE		"Please enter your name: ",0
userNameBuffer			BYTE		21 DUP(0)
userNameByteCount		DWORD		?  ; not sure if we need this, unless we wanted to handle user induced overflow
userGreeting			BYTE		"Hello ",0

userInstructions1		BYTE		"Please enter a series of numbers in the ranges of -200 to -100 (inclusive) and -50 to -1 (inclusive).",0
userInstructions2		BYTE		"When you are finished, enter a positive number to end your input.",0
userInstructions3		BYTE		"You will then be given the number of inputs, the minimum and maximum value you entered, and the average.",0

lineNumberLabel			BYTE		"Line ",0
lineNumberSpacer		BYTE		": ",0

userInput				SDWORD		?

numberOfInputs			DWORD		0
sumOfInputs				SDWORD		0
minValue				SDWORD		?
maxValue				SDWORD		?
averageValue			SDWORD		?

outOfRangeErrorPrompt	BYTE		"You entered a value outside the range of -200 to -100 or -50 to -1. Please try again, or enter a positive number to quit.",0

loopTerminatedPrompt	BYTE		"Data Input Completed. Here are your results: ",0
numInputsPrompt			BYTE		"Number of inputs: ",0
minValuePrompt			BYTE		"Minimum Value: ",0
maxValuePrompt			BYTE		"Maximum Value: ",0
sumOfInputsPrompt		BYTE		"Sum of all inputs: ",0
averageValuePrompt		BYTE		"Average of all inputs: ",0

goodbyePrompt			BYTE		"Goodbye!",0

.code
main PROC

	; display program title and programmer name
	MOV		edx, OFFSET nameAndProgramTitle
	CALL	WriteString
	CALL	Crlf

	; prompt user to enter their name,
	MOV		edx, OFFSET namePrompt
	CALL	WriteString

	; read the name and store in a null terminated byte array
	MOV		edx, OFFSET userNameBuffer
	MOV		ecx, SIZEOF	userNameBuffer
	CALL	ReadString
	MOV		userNameByteCount, eax

	; greet the user
	CALL	Crlf
	MOV		edx, OFFSET userGreeting
	CALL	WriteString
	MOV		edx, OFFSET userNameBuffer
	CALL	WriteString
	CALL	Crlf

	; give the user instructions
	CALL	Crlf
	MOV		edx, OFFSET userInstructions1
	CALL	WriteString
	CALL	Crlf
	MOV		edx, OFFSET userInstructions2
	CALL	WriteString
	CALL	Crlf
	MOV		edx, OFFSET userInstructions3
	CALL	WriteString
	Call	Crlf

	; enter the input loop
	_inputLoop:
		
		; display the line number
		MOV		edx, OFFSET lineNumberLabel		
		CALL	WriteString
		MOV		eax, numberOfInputs
		CALL	WriteDec
		MOV		edx, OFFSET lineNumberSpacer
		CALL	WriteString


		; get the user input
		CALL	ReadInt							
		MOV		userInput, eax


		; exit loop if value was positive
		JNS		_endInputLoop					


		; check if userInput < LOWER_LIMIT_1
		MOV		eax, LOWER_LIMIT_1
		CMP		userInput, eax
		JL		_PromptInputOutOfRange	
		

		; check if userInput > UPPER_LIMIT_1
		; if it is, JMP to _checkLowerLimit2 to make sure that userInput > LOWER_LIMIT_2
		MOV		eax, UPPER_LIMIT_1
		CMP		userInput, eax
		JG		_checkLowerLimit2			
		JMP		_updateValues


		; check if userInput > LOWER_LIMIT_2
		_checkLowerLimit2:
			MOV		eax, LOWER_LIMIT_2
			CMP		userInput, eax
			JL		_promptInputOutOfRange		; userInput is greater than -100 but less than -50, so handle invalid input
			JMP		_updateValues


		_PromptInputOutOfRange:
			CALL	Crlf
			MOV		edx, OFFSET outOfRangeErrorPrompt
			CALL	WriteString
			CALL	Crlf
			JMP		_inputLoop
				

		; update the values for minValue, maxValue, numberOfInputs, and averageValue
		_updateValues:
			MOV		edx, numberOfInputs
			INC		edx
			MOV		numberOfInputs, edx
			CMP		edx, 1
			JE		_detectedFirstInput			; if numberOfInputs = 1, JMP to _detectedFirstInput


			; check if we have a new minValue
			MOV		edx, minValue
			CMP		userInput, edx
			JG		_detectNewMaxValue
			MOV		edx, userInput
			MOV		minValue, edx

			_detectNewMaxValue:
				MOV		edx, minValue
				CMP		userInput, edx
				JL		_addUserInputToTotal
				MOV		edx, userInput
				MOV		minValue, edx

			_addUserInputToTotal:
				





			JMP		_inputLoop					; repeat the loop


			; initialize minValue, maxValue and sumOfInputs to the value of the first input
			_detectedFirstInput:
				MOV		EDX, userInput
				MOV		minValue, EDX
				MOV		maxValue, EDX
				MOV		sumOfInputs, EDX
				JMP		_inputLoop				; repeat the loop
				

	; end of loop, display results and then exit program
	_endInputLoop:
		CALL	Crlf
		MOV		edx, OFFSET loopTerminatedPrompt
		CALL	WriteString


	; say goodbye and exit to operating system
	_ExitProgram:
		MOV		edx, OFFSET goodbyePrompt
		CALL	WriteString
		Invoke ExitProcess,0					; exit to operating system

		
main ENDP

; (insert additional procedures here)

END main
