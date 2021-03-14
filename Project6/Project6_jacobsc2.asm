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
MAX_INPUT_SIZE = 12
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
	
	; display the input prompt
	CALL	Crlf
	MOV		EDX, promptRef
	CALL	WriteString
	
	; setup and call ReadString
	MOV		EDX, mGetStrInputArrRef
	MOV		ECX, countVal
	CALL	ReadString

	; store bytes read
	MOV		EBX, bytesReadRef
	MOV		[EBX], EAX
	
	; restore stack / registers
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
	CALL Crlf
	
	
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
convertedArr			SDWORD	MAX_INPUT_SIZE DUP(?)
sdwordValueArr			SDWORD	VALUE_STORAGE_SIZE DUP(?)

; ReadVal Status Flags
signFlag 				BYTE	0 ; False
negFlag					BYTE	0 ; False

; mGetString data
inputPrompt				BYTE	"Input number: ",0
count					DWORD	VALUE_STORAGE_SIZE
mGetStrInputArr			BYTE	MAX_INPUT_SIZE DUP(?)
numBytesRead			DWORD	?


; WriteVal/mDisplayString data
displayStrArray			BYTE	MAX_INPUT_SIZE DUP(?)


; DisplayCalculations data
sumLabel				BYTE	"Sum: ",0
averageLabel			BYTE	"Average: ",0





; (insert variable definitions here)


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
	_readValLoop:
	
		; ReadVal inputs
		PUSH	OFFSET signFlag				; [ebp+44] 
		PUSH	OFFSET negFlag				; [ebp+40]
		PUSH	OFFSET errorPromptNotInt	; [ebp+36]
		PUSH	OFFSET errorPromptTooBig	; [ebp+32]
		PUSH	OFFSET convertedArr			; [ebp+28]
		
		; ReadVal outputs
		PUSH	OFFSET sdwordValueArr		; [ebp+24]
		
		; mGetString inputs
		PUSH	OFFSET inputPrompt			; [ebp+20]
		MOV		EBX, count
		
		PUSH	EBX							; [ebp+16]
		
		; mGetString outputs				
		PUSH 	OFFSET mGetStrInputArr		; [ebp+12]
		PUSH	OFFSET numBytesRead			; [ebp+8]

		; Call ReadVal
		CALL	ReadVal
	
	LOOP _readValLoop

	
	; Begin output loop
	MOV		ECX, VALUE_STORAGE_SIZE
	_writeValLoop:							
	
		PUSH 	OFFSET sdwordValueArr		; WriteVal inputs
		PUSH	OFFSET displayStrArray		; mDisplayString inputs
		
		; Call WriteVal
		CALL	WriteVal
	LOOP _writeValLoop
	
	
	PUSH 	sdwordvalueArr					; DisplayCalculations input
	
	; CALL DisplayCalculations
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
; Receives:		[ebp+44] = OFFSET signFlag
;				[ebp+40] = OFFSET negFlag
;				[ebp+36] = OFFSET errorPromptNotInt
;				[ebp+32] = OFFSET errorPromptTooBig
;				[ebp+28] = OFFSET convertedArr
;				[ebp+24] = OFFSET sdwordValueArr
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
	
	; Save registers (ECX, EBX)
	PUSH 	ECX
	PUSH 	EBX

	; Invoke macro mGetString 
	mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8]

	; Check numBytesRead
	;CALL	Crlf
	;MOV	EBX, [ebp+8]
	;MOV	ECX, [EBX]
	;CALL	WriteDec


	; Setup ESI for _conversionLoop
	CLD
	MOV		ESI, [ebp+12]	; set to first index of mGetStrInputArr
	MOV		EDI, [ebp+28]	; set to first index of convertedArr
	
	; Setup ECX for _conversionLoop
	MOV		EBX, [ebp+8]
	MOV		ECX, [EBX]		; ECX = numBytesRead
	MOV		EBX, ECX		; EBX = numBytesRead
	
	_conversionLoop:
	LODSB
	MOV		DL, AL
	CALL	WriteString
	
	
		
		
		
	
		
		
		
		
	


	
	

	_abortReadVal
	; Restore registers (ECX, EBX)
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
