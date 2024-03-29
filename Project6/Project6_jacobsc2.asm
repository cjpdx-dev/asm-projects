TITLE Project6   (Project6_jacobsc2.asm)


; Author: Chris Jacobs
; Last Modified: 3/14/2021
; OSU email address: Jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 3/14/2021
;
; Description: Project 6 for 271 - Reads in 10 numbers from the user. These numbers can be positive or negative integers.
; Writes those numbers to the screen and displays the sum and average of all 10 numbers, then exits.


INCLUDE Irvine32.inc


; CONSTANTS
MAX_INPUT_SIZE = 13
VALUE_STORAGE_SIZE = 10


;****************************************************************************************************************************************************
; Macro Name: 	mGetString
; 
; Description: 	Reads a string from the user and stores that string
; 				in an array named mGetStringArrRef. Also saves the number of bytes
; 				that were read.
; 
; Preconds: 	?
; 
; Receives:		inputPromptRef		= array address for userInputPrompt
;				countVal			= value for count (for length of input string to accomodate)
;				mGetStrArrRef		= array address for mGetStringArrRef (to store the string that is read in)
;				bytesReadRef		= address for bytesReadRef (to store the number of bytes that were read in)
;
; Returns:		mGetStrArr			= read in string array holding user input
;				bytesRead			= integer representing number of bytes read in from user
; 
;****************************************************************************************************************************************************
mGetString	MACRO	promptRef, countVal, mGetStrInputArrRef, bytesReadRef 
	; setup stack / save registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	; display the input prompt
	CALL	Crlf
	MOV		EDX, promptRef
	CALL	WriteString
	
	; setup and call ReadString
	MOV		EDX, mGetStrInputArrRef
	MOV		ECX, countVal
	CALL	ReadString

	; store bytes read
	MOV		ESI, bytesReadRef
	MOV		[ESI], EAX
	
	; restore stack / registers
	POP	ESI
	POP EDX
	POP	ECX
	POP EBX
	POP EAX
ENDM


;****************************************************************************************************************************************************
; Macro Name: 	mDisplayString
; 
; Description:	prints a string which is stored in the displayStringArr array
; 
; Preconds: 	displayString array has been initialized and holds a valid ascii string
; 
; Receives:		displayStringRef	= address of displayStringArr
;
; Returns:		None
; 
;****************************************************************************************************************************************************
mDisplayString	MACRO	displayStrRef
	; setup stack / save registers
	
	
	; restore stack / registers
ENDM

.data

; main proc data
goodbyePrompt			BYTE	"Goodbye.",0


; Introductions data
programDescription		BYTE	"Welcome to Project 6: Designing Low Level Procedures and Macros - Written by Chris Jacobs",0
programDirections1		BYTE	"Please enter a series of 10 positive or negative integer values. These numbers will be saved ",0
programDirections2		BYTE	"and then repeated back to you, along with their sum and their average.",0
exampleInputPrompt		BYTE	"Example input: '-157' ... '+293' ... '3492'",0	


; ReadVal data
errorPromptNotInt		BYTE	"The input failed because your input included a non-integer value or invalid symbol. Please try again.",0
errorPromptTooBig		BYTE	"The value you input was too large. Please try again.",0
readValOutputArr		SDWORD	VALUE_STORAGE_SIZE DUP("$")
convertedValueArr		SDWORD	MAX_INPUT_SIZE DUP("$")

; readValOutputArr Storage Index
storageIndex			DWORD	0

; ReadVal Status Flags
signFlag 				DWORD	0 ; False
negFlag					DWORD	0 ; False
errorFlag				DWORD	0 ; False

; mGetString data
inputPrompt				BYTE	"Input number: ",0
count					DWORD	MAX_INPUT_SIZE
mGetStrInputArr			BYTE	MAX_INPUT_SIZE DUP(?)
numBytesRead			DWORD	0


; WriteVal/mDisplayString data
displayStrArray			BYTE	MAX_INPUT_SIZE DUP(?)


; DisplayCalculations data
sumLabel				BYTE	"Sum: ",0
averageLabel			BYTE	"Average: ",0


; Debug Flags
flag1					BYTE	"flag1",0
invalidInputFlag		BYTE	"invalidInputFlag",0


.code
main PROC


	; Display Program Description and Descriptions
	PUSH	OFFSET programDescription
	PUSH	OFFSET programDirections1
	PUSH	OFFSET programDirections2
	PUSH	OFFSET exampleInputPrompt
	
	; Call Introductions
	CALL	Introductions
	
	
	; Begin input loop
	MOV		ECX, VALUE_STORAGE_SIZE 
	MOV		EBX, ECX
	_readValLoop:
	
		; ReadVal inputs
		
		PUSH	OFFSET storageIndex			; [ebp+52]
		PUSH	OFFSET errorFlag			; [ebp+48]
		PUSH	OFFSET signFlag				; [ebp+44] 
		PUSH	OFFSET negFlag				; [ebp+40]
		PUSH	OFFSET errorPromptNotInt	; [ebp+36]
		PUSH	OFFSET errorPromptTooBig	; [ebp+32]

		; ReadVal outputs
		PUSH	OFFSET readValOutputArr		; [ebp+28]
		PUSH	OFFSET convertedValueArr	; [ebp+24]
		
		; mGetString inputs
		PUSH	OFFSET inputPrompt			; [ebp+20]
		MOV		EBX, count
		PUSH	EBX							; [ebp+16]
		
		; mGetString outputs				
		PUSH 	OFFSET mGetStrInputArr		; [ebp+12]
		PUSH	OFFSET numBytesRead			; [ebp+8]

		; Call ReadVal
		CALL	ReadVal

		MOV		ESI, OFFSET errorFlag
		MOV		EBX, [ESI]
		CMP		EBX, 1

		JNE		_continueLoop

		INC		ECX
		; Write Error Here using PROC mDisplayString

	_continueLoop:
	LOOP _readValLoop

	MOV		ESI, OFFSET readValOutputArr
	MOV		ECX, VALUE_STORAGE_SIZE
	_readValOutput:
		LODSD
		CALL	Crlf
		CALL	WriteInt
		CALL	Crlf

	LOOP	_readvalOutput

		



	; Begin output loop
	MOV		ECX, VALUE_STORAGE_SIZE
	_writeValLoop:							
	
		PUSH 	OFFSET readValOutputArr		; WriteVal inputs
		PUSH	OFFSET displayStrArray		; mDisplayString inputs
		CALL	WriteVal
		
		; Call WriteVal
		CALL	WriteVal
	LOOP _writeValLoop
	
	
	PUSH 	OFFSET readValOutputArr		; DisplayCalculations input
	CALL	DisplayCalculations
	
	
	; Exit prompt
	CALL	Crlf
	MOV		EDX, OFFSET goodbyePrompt
	CALL	WriteString

	; Exit program.
	Invoke ExitProcess,0	; exit to operating system
main ENDP


;****************************************************************************************************************************************************
; Proc Name: 	Introductions
; 
; Description: 	Displays program introduction and instructions
; 
; Preconds:		None
;
; Postconds:	None
; 
; Receives: 	[ebp+20] = OFFSET programDescription 
;				[ebp+16] = OFFSET programDirections1 
;				[ebp+12] = OFFSET programDirections2 
; 				[ebp+8]  = OFFSET exampleInputPrompt 
;
; Returns:		None
; 
;****************************************************************************************************************************************************
Introductions PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	CALL	Crlf
	MOV		EDX, [ebp+20]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	
	MOV		EDX, [ebp+16]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	
	MOV		EDX, [ebp+12]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf
	
	MOV		EDX, [ebp+8]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	POP		EBP
	RET		16
Introductions ENDP


;****************************************************************************************************************************************************
; Proc Name: 	ReadVal
; 
; Description: 	Invokes the mGetString macro to get the uesr's input in the form of a string of ASCII digits. Converts
; 				that string to its numeric value representation, storing that conversion in a SDWORD. Validates the user's 
;				input as being a valid integer and then stores the value in a memory location.
; 
; Preconds: 	ECX is set to counter for main proc _readValLoop
;				EBX is set to the value of count but this procedure accesses that value through the stack
;
; Postconds: 	numBytesRead stores the last number of bytes read
;				sdwordValueArr has been updated with another value
;				ECX and EBX registers are restored to original values
;				
; 
; Receives:		[ebp+52] = OFFSET storageIndex
;				[ebp+48] = OFFSET errorFlag		
;				[ebp+44] = OFFSET signFlag
;				[ebp+40] = OFFSET negFlag
;				[ebp+36] = OFFSET errorPromptNotInt
;				[ebp+32] = OFFSET errorPromptTooBig
;				[ebp+28] = OFFSET readValOutputArr
;				[ebp+24] = OFFSET convertedValueArr
;				[ebp+20] = OFFSET inputPrompt 
;				[ebp+16] = VALUE  count
;				[ebp+12] = OFFSET mGetStrInputArr
; 				[ebp+8]  = OFFSET numBytesRead
;
;
; Returns:		sdwordValueArr updated
; 
;****************************************************************************************************************************************************
ReadVal PROC
	; Setup stack
	PUSH	EBP
	MOV		EBP, ESP
	
	
	; Save registers (ECX, EBX, EDX, ESI)
	PUSH 	ECX
	PUSH 	EBX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI


	; Invoke macro mGetString 
	mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8]

	; Verify that numBytesWritten != 0
	MOV		ESI, [ebp+8]
	CMP		DWORD PTR [ESI], 0
	JNE		_continueWithConversion
	; *** TODO: PRINT ERROR MESSAGE HERE ***
	JMP		_abortReadVal
	
	_continueWithConversion:							; Setup ESI for _conversionLoop
	CLD
	MOV		ESI, [ebp+12]								; Set to first index of BYTE mGetStrInputArr
	MOV		EDI, [ebp+24]								; Set to first index of SDWORD convertedValueArr
	
	MOV		EBX, [ebp+8]								; Setup ECX for _conversionLoop
	MOV		ECX, [EBX]									; ECX = numBytesRead
	MOV		EBX, ECX									; EBX = numBytesRead	
		
	_conversionLoop:									; Convert each ascii byte in mGetStrInputArr to its signed value,
		
		LODSB	

		MOV		BL, AL
		MOVZX	EAX, BL
		SUB		EAX, 48

		STOSD											; Store converted value in convertedValueArr
	
	LOOP	_conversionLoop

	MOV		ESI, [ebp+48]								; Clear errorFlag
	MOV		EBX, 0
	MOV		[ESI], EBX

	MOV		ESI, [ebp+24]								; Handle if only zero entered or if only a + or - are entered
	MOV		EAX, [ESI]
	CMP		EAX, -5
	JE		_checkSecondIndex				
	CMP		EAX, -3
	JE		_checkSecondIndex
	CMP		EAX, 0
	JNE		_beginValidation
	ADD		ESI, 4
	MOV		EAX, [ESI]
	CMP		EAX, "$"
	JNE		_abortReadVal
	MOV		EAX, 0
	JMP		_storeValue

	_checkSecondIndex:
	ADD		ESI, 4
	MOV		EAX, [ESI]
	CMP		EAX, "$"
	JE		_abortReadVal

	_beginValidation:
	CLD													; Setup ESI and ECX for _validateLoop
	MOV		ESI, [ebp+24]
	MOV		EBX, [ebp+8]
	MOV		ECX, [EBX]									; ECX = numBytesRead
	
	_validateLoop:										; Validate input for non-integer characters (except for "+" and "-" at beginning)
		LODSD
	
		CMP		EAX, 0									; Check for value less than 0
		JL		_checkForPosSign
		
		CMP		EAX, 9									; Check for value greater than 9
		JG		_checkForPosSign	
		
		JMP		_continue								; Found a value between 0 and 9
		
		
		_checkForPosSign:								; Check if we encountered a "+" symbol
		CMP		EAX, -5
		JNE		_checkForNeg

		MOV		EBX, [ebp+44]							; Check signFlag
		CMP		DWORD PTR [EBX], 1
		JE		_abortReadVal							; If set, jump to _abortReadVal (means we already encountered a sign at the first index)
		
		MOV		EDI, [ebp+24]							; Else: assign 0 to first index of array, and continue	
		MOV		SDWORD PTR [EDI], 0
		JMP		_continue
		
		_checkForNeg:									; Check if we encountered a "-" symbol
		CMP		EAX, -3
		JNE		_abortReadVal							; Value at ESI is not a -, +, or valid integer, so abort
		
		MOV 	EBX, [ebp+44]
		CMP		DWORD PTR [EBX], 1
		JE		_abortReadVal							; If set, jump to _abortReadVal
			
		MOV		EDI, [ebp+40]							; else, set negFlag, assign 0 to current ESI, and continue		
		MOV		DWORD PTR [EDI], 1
		
		MOV		EDI, [ebp+24]
		MOV		SDWORD PTR [EDI], 0
	
	_continue:
		PUSH	ESI										; set the signflag (we do this first on the first loop and then if we find any more signs, we abort)
		MOV		ESI, [ebp+44]
		MOV		SDWORD PTR [ESI], 1
		POP		ESI				
	LOOP	_validateLoop


	_generateValue:
	
	MOV		ESI, [ebp+24]
	CMP		SDWORD PTR [ESI], 0							; Detect a sign character
	JE		_firstIndexIsZero
														; Setup for input with no sign character
															
	MOV		ESI, [ebp+8]
	MOV		ECX, [ESI]									; Setup ECX for _generatePower loop
	PUSH	ECX											; Save that ECX value for later when we hit _generateValueLoop

	MOV		ESI, [ebp+24]								; Setup ESI for _generateValueLoop
	PUSH	ESI

	MOV		EAX, 1
	JMP		_generatePower
	
	
	_firstIndexIsZero:									; Setup for input value that included a sign character
	MOV		ESI, [ebp+8]
	MOV		ECX, [ESI]			
	DEC		ECX											; Setup ECX for _generatePower loop
	PUSH	ECX											; Save that ECX value for later when we hit _generateValueLoop

	MOV		ESI, [ebp+24]								; Setup ESI for _generateValueLoop
	ADD		ESI, 4
	PUSH	ESI
	
	MOV		EAX, 1
	_generatePower:
		CMP		ECX, 1									; If ECX is at the ones place, then we can exit the loop
		JE		_breakFromGeneratePower
		MOV		EBX, 10
		MUL		EBX						
		MOV		EBX, EAX
	LOOP _generatePower
	
	_breakFromGeneratePower:
	MOV		EBX, EAX									; EBX holds our power
	POP		ESI											; ECX and ESI already set when setting up _generatePower, so we POP from stack
	POP		ECX							
	MOV		EAX, +1
	CLD

	_generateValueLoop:
		PUSH	EBX
		PUSH	EAX
		LODSD
		CWD
		IMUL	EBX
		JO		_overflowDetectedAfterIMUL				; Detected Overflow

		MOV		EBX, EAX
		POP		EAX
		ADD		EAX, EBX
		POP		EBX
		JO		_overflowDetectedAfterADD				; Detected Overflow
													
		PUSH	ESI										; check if we're on our first iteration, if we are then we need to decrement ecx by 1
		MOV		ESI, [ebp+8]							; to make up for adding 1
		CMP		DWORD PTR [ESI], ECX
		JNE		_notFirstIter
		DEC		EAX
		
		_notFirstIter:
		POP		ESI
		PUSH	EAX
		MOV		EAX, EBX
		MOV		EBX, 10
		MOV		EDX, 0
		DIV		EBX										; update the power
		MOV		EBX, EAX
		POP		EAX
		CMP		EBX, 0									; once the power is at zero, break
		JE		_exitGenerateValueLoop

	LOOP	_generateValueLoop
	JMP		_exitGenerateValueLoop

	
	_overflowDetectedAfterIMUL:							; Handle Overflow after IMUL
	POP		EAX
	POP		EBX
	JMP		_abortReadVal

	_overflowDetectedAfterADD:							; Handle Overflow after ADD
	JMP		_abortReadVal

	_exitGenerateValueLoop:

	PUSH	ESI											; Check if sign flag set, if yes, dec EAX by 1
	MOV		ESI, [ebp+44]
	CMP		DWORD PTR [ESI], 1
	POP		ESI
	JE		_checkNegFlag
	JMP		_storeValue

	_checkNegFlag:										; Check to see if neg flag was set, if it was, IMUL generated value by -1
	MOV		ESI, [ebp+40]
	CMP		DWORD PTR [ESI], 1
	JE		_negFlagSet
	JMP		_storeValue

	_negFlagSet:										; negFlag was set so we IMUL by -1 to get our final value.
	DEC		EAX
	CWD
	MOV		EBX, -1
	IMUL	EBX
	CALL	Crlf
	CALL	WriteInt
	CALL	Crlf

	_storeValue:										; Save value to readValOutputArr, based on the storageIndex
	PUSH	EAX											; Save final value in EAX with PUSH
	MOV		ESI, [ebp+52]	
	MOV		EBX, [ESI]									; EBX stores the value of the current storageIndex
	MOV		ESI, [ebp+28]
	MOV		EAX, TYPE ESI
	MUL		EBX
	ADD		ESI, EAX									; Set ESI to currentStorage index of readValOutputArr
	POP		EAX
	MOV		[ESI], EAX									; Write generated value to readValOutputArr

	; Increment the storageIndex
	PUSH	ESI
	MOV		ESI, [ebp+52]
	MOV		EBX, [ESI]
	INC		EBX
	POP		ESI
	PUSH	EDI
	MOV		EDI, [ebp+52]
	MOV		[EDI], EBX
	POP		EDI

	; clean up and exit
	JMP		_cleanUp

	; invalid input found, so abort the ReadVal procedure without writing to readValOutputArr
	_overflowDetectedAfterIMULNeg1:
	; print error here
	
	_abortReadVal:
	MOV		EDX, OFFSET invalidInputFlag
	CALL	WriteString
	CALL	Crlf

	MOV		ESI, [ebp+48]				; Set the errorFlag
	MOV		DWORD PTR [ESI], 1

	_cleanUp:
		MOV		ESI, [ebp+44]			; Clear the signFlag
		MOV		DWORD PTR [ESI], 0
	
		MOV		ESI, [ebp+40]			; Clear negFlag
		MOV		DWORD PTR [ESI], 0

		; *************************************
		; FOR TESTING PURPOSES - DELETE LATER
		MOV		ECX, MAX_INPUT_SIZE
		MOV		ESI, [ebp+24]
		_testLoop1:
		MOV		EAX, 0
		MOV		EAX, [ESI]
		CALL	Crlf
		CALL	WriteInt
		CALL	Crlf
		ADD		ESI, 4

		LOOP _testLoop1
		; END TEST
		;***************************************

		MOV		ECX, MAX_INPUT_SIZE
		MOV		ESI, [ebp+24]
		_resetConvertedValueArr:		
		MOV		SDWORD PTR [ESI], "$"
		ADD		ESI, 4
		LOOP	_resetConvertedValueArr

	; Restore registers (ECX, EBX, EDX, ESI)
	POP		EDI
	POP		ESI
	POP		EDX
	POP		EBX
	POP		ECX
	
	; Restore stack/exit
	POP		EBP
	RET		40
ReadVal ENDP


;****************************************************************************************************************************************************
; Proc Name: 	WriteVal
; 
; Description: 	Converts an SDWORD value to a string of ASCII digits and then invokes the mDisplayString macro, which
; 				prints the converted ASCII string to the screen.
; 
; Preconds: 	?
;
; Postconds:
; 
; Receives:		
;
; Returns:		
; 
;****************************************************************************************************************************************************
WriteVal PROC
	; Setup stack
	PUSH	EBP
	MOV		EBP, ESP
	
	; Save registers (ECX, ?)
	PUSH 	ECX
	
	; Restore registers (ECX, ?)
	POP 	ECX
	
	POP		EBP
	RET 	8
WriteVal ENDP


;****************************************************************************************************************************************************
; Proc Name: 	DisplayCalculations
; 
; Description: 	Performs and displays the caclulations that compute the sum and average of values stored in sdwordValueArr
; 
; Preconds: 	?
; 
; Receives:		
;
; Returns:		
; 
;****************************************************************************************************************************************************
DisplayCalculations PROC
	PUSH	EBP
	MOV		EBP, ESP
	; save registers (?)
	 
	
	
	; restore registers (?)
	POP 	EBP
	RET 	4

DisplayCalculations ENDP



END main
