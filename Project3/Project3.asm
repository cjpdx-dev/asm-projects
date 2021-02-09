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

nameAndProgramTitle		BYTE		"Project 3 - Min, Max and Average Calculator - By Chris Jacobs",0	
extraCreditPrompt1		BYTE		"EC 1: Number the lines during user input. Increment the line number only for valid number entries.",0

namePrompt				BYTE		"Please enter your name: ",0
userNameBuffer			BYTE		21 DUP(0)
userNameByteCount		DWORD		?
userGreeting			BYTE		"Hello ",0

userInstructions1		BYTE		"Please enter a series of numbers in the ranges of -200 to -100 (inclusive) and -50 to -1 (inclusive).",0
userInstructions2		BYTE		"When you are finished, enter a positive number to end your input.",0
userInstructions3		BYTE		"You will then be given the number of inputs, the minimum and maximum value you entered, and the average.",0

userInput				SDWORD		?

numInputs				SDWORD		0
sumOfInputs				SDWORD		0
minValue				SDWORD		?
maxValue				SDWORD		?
averageValue			SDWORD		?
averageValueRemainder	SDWORD		?
numInputsDiv2			SDWORD		?
valueOf2				SDWORD		-2

outOfRangeErrorPrompt	BYTE		"You entered a value outside the range of [-200 to -100] or [-50 to -1]. Please try again, or enter a positive number to quit.",0
noInputsDetectedPrompt	BYTE		"You didn't input any values.",0

loopTerminatedPrompt	BYTE		"Data Input Completed. Here are your results: ",0
numInputsPrompt			BYTE		"Number of inputs: ",0
minValuePrompt			BYTE		"Minimum Value: ",0
maxValuePrompt			BYTE		"Maximum Value: ",0
sumOfInputsPrompt		BYTE		"Sum of all inputs: ",0
averageValuePrompt		BYTE		"Rounded average of all inputs: ",0

goodbyePrompt			BYTE		"Goodbye!",0

; Extra Credit
lineNumberLabel			BYTE		"Line ",0
lineNumberSpacer		BYTE		": ",0
lineNumber				DWORD		1

.code
main PROC

	; Display program title and programmer name, and extra credit prompts
	MOV		EDX, OFFSET nameAndProgramTitle
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	MOV		EDX, OFFSET extraCreditPrompt1
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Prompt user to enter their name
	CALL	Crlf
	MOV		EDX, OFFSET namePrompt
	CALL	WriteString

	; Read the name and store in a null terminated byte array
	MOV		EDX, OFFSET userNameBuffer
	MOV		ECX, SIZEOF	userNameBuffer
	CALL	ReadString
	MOV		userNameByteCount, EAX

	; Greet the user
	CALL	Crlf
	MOV		EDX, OFFSET userGreeting
	CALL	WriteString
	MOV		EDX, OFFSET userNameBuffer
	CALL	WriteString
	CALL	Crlf

	; Give the user instructions
	CALL	Crlf
	MOV		EDX, OFFSET userInstructions1
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	MOV		EDX, OFFSET userInstructions2
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	MOV		EDX, OFFSET userInstructions3
	CALL	WriteString
	Call	Crlf

	; Enter the input loop
	_InputLoop:

		; Display the line number (Extra Credit)
		CALL	Crlf
		MOV		EDX, OFFSET lineNumberLabel		
		CALL	WriteString
		MOV		EAX, lineNumber
		CALL	WriteDec
		MOV		EDX, OFFSET lineNumberSpacer
		CALL	WriteString

		; Get the user's input
		CALL	ReadInt							
		MOV		userInput, EAX

		; Exit loop if value was positive
		JNS		_EndInputLoop					

		; Check if userInput < LOWER_LIMIT_1
		MOV		EAX, LOWER_LIMIT_1
		CMP		userInput, EAX
		JL		_PromptInputOutOfRange	
		
		; Check if userInput > UPPER_LIMIT_1
		; If it is, JMP to _CheckLowerLimit2 to make sure that userInput > LOWER_LIMIT_2
		MOV		EAX, UPPER_LIMIT_1
		CMP		userInput, EAX
		JG		_CheckLowerLimit2			
		JMP		_UpdateValues

		; Check if userInput > LOWER_LIMIT_2
		_CheckLowerLimit2:
			MOV		EAX, LOWER_LIMIT_2
			CMP		userInput, EAX
			JL		_PromptInputOutOfRange		; userInput is greater than -100 but less than -50, so handle invalid input
			JMP		_UpdateValues				; Else, update the running values

		; Prompt the user that their value is out of the required range
		_PromptInputOutOfRange:
			CALL	Crlf
			MOV		EDX, OFFSET outOfRangeErrorPrompt
			CALL	WriteString
			CALL	Crlf
			JMP		_InputLoop
				
		; Update the values for minValue, maxValue, numberOfInputs, and averageValue
		_UpdateValues:

			; Increment the line number (Extra Credit)
			MOV		EDX, lineNumber
			INC		EDX
			MOV		lineNumber, EDX

			; Increment the number of inputs
			MOV		EDX, numInputs
			INC		EDX
			MOV		numInputs, EDX

			; Detect whether the input is the first input
			CMP		EDX, 1
			JE		_DetectedFirstInput				; If numberOfInputs = 1, JMP to _DetectedFirstInput

			; Check if we have a new minValue
			MOV		EDX, minValue
			CMP		userInput, EDX
			JG		_DetectNewMaxValue
			MOV		EDX, userInput
			MOV		minValue, EDX

		; Check if we have a new maxValue
		_DetectNewMaxValue:

			MOV		EDX, maxValue
			CMP		userInput, EDX
			JL		_AddUserInputToTotal
			MOV		EDX, userInput
			MOV		maxValue, EDX

		; Add new userInput to running total
		_AddUserInputToTotal:
			MOV		EDX, sumOfInputs
			ADD		EDX, userInput
			MOV		sumOfInputs, EDX
			JMP		_InputLoop						; Repeat the loop

		; Initialize minValue, maxValue and sumOfInputs to the value of the first input
		_DetectedFirstInput:
			MOV		EDX, userInput
			MOV		minValue, EDX
			MOV		maxValue, EDX
			MOV		sumOfInputs, EDX
			JMP		_InputLoop						; Repeat the loop
				

	; Alert the user that they quit the input phase, calculate average (normal form and decimal form),
	_EndInputLoop:
		
		; Check to see if the user entered zero inputs.
		MOV		EAX, numInputs
		CMP		EAX, 0
		JE		_NoInputsDetected					; If numInputs == 0, JMP to _NoInputsDetected

		CALL	Crlf
		CALL	Crlf
		MOV		EDX, OFFSET loopTerminatedPrompt 
		CALL	WriteString							; Display input completion message
		CALL	Crlf
		CALL	Crlf

		; Calculate rounded non-decimal average
		MOV		EDX, 0
		MOV		EAX, sumOfInputs
		CDQ
		IDIV	numInputs
		MOV		averageValue, EAX
		MOV		averageValueRemainder, EDX

		; Calculate half the value of numInputs
		MOV		EDX, 0
		MOV		EAX, numInputs
		CDQ
		IDIV	valueOf2

		; Decide whether to round the non-decimal
		CMP		EAX, averageValueRemainder
		JLE		_DisplayResults
		MOV		EAX, averageValue
		DEC		EAX
		MOV		averageValue, EAX


	; Display results and then exit program
	_DisplayResults:

		; Display numInputsPrompt and numInputs
		MOV		EDX, OFFSET numInputsPrompt
		CALL	WriteString
		MOV		EAX, numInputs
		CALL	WriteDec
		CALL	Crlf

		; Display minValuePrompt and minValue
		CALL	Crlf
		MOV		EDX, OFFSET minValuePrompt
		CALL	WriteString
		MOV		EAX, minValue
		CALL	WriteInt
		CALL	Crlf

		; Display maxValuePrompt and maxValue
		CALL	Crlf
		MOV		EDX, OFFSET	maxValuePrompt
		CALL	WriteString
		MOV		EAX, maxValue
		CALL	WriteInt
		CALL	Crlf

		; Display sumOfInputsPrompt and sumOfInputs
		CALL	Crlf
		MOV		EDX, OFFSET sumOfInputsPrompt
		CALL	WriteString
		MOV		EAX, sumOfInputs
		CALL	WriteInt
		CALL	Crlf

		; Display averageValuePrompt and averageValue
		CALL	Crlf
		MOV		EDX, OFFSET averageValuePrompt
		CALL	WriteString
		MOV		EAX, averageValue
		CALL	WriteInt
		CALL	Crlf

	; Say goodbye and exit to operating system
	_ExitProgram:
		CALL	Crlf
		MOV		EDX, OFFSET goodbyePrompt
		CALL	WriteString
		CALL	Crlf
		Invoke	ExitProcess,0					; Exit to operating system

	; Prompts user that no inputs were detected, then jumps to _ExitProgram
	_NoInputsDetected:
		CALL	Crlf
		MOV		EDX, OFFSET	noInputsDetectedPrompt
		CALL	WriteString
		CALL	Crlf
		CALL	Crlf
		JMP		_ExitProgram

main ENDP

; (insert additional procedures here)

END main
