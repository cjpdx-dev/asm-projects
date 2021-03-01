TITLE Program Template     (template.asm)

; Author: Chris Jacobs
; Last Modified: 2/28/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5               Due Date: 2/28/2021
; Description:	A program that populates an array of a constant size with random numbers, sorts those numbers, finds
;				the median of the array, and then creates another array that represents the frequency of each number in the
;				random number array.
;

INCLUDE Irvine32.inc

ARRAYSIZE		= 200
LO				= 10
HI				= 29

.data

; intro data
intro1				BYTE	"Welcome to List Sorter, written by Chris Jacobs. This program generates and displays a random and unsorted list of numbers.",0
intro2				BYTE	"It then sorts the list in ascending order, calculates and displays the median value of the list, and then displays the sorted list.",0
intro3				BYTE	"The program then generates and displays an array that holds the frequency of each value in the previously sorted list.",0
intro4				BYTE	"So sit back, relax, and enjoy the medocrity of bubble sort!",0


; user prompt data
sortedNumbersPrompt	BYTE	"Sorted numbers: ",0
medianValuePrompt	BYTE	"Median value: ",0
numberFreqPrompt	BYTE	"Frequency of values: ",0
goodbyePrompt		BYTE	"Goodbye!",0

; data for formatting output
outputSpacer		BYTE	" ",0


; main data structures
randArray			DWORD	ARRAYSIZE DUP(?)
counts				DWORD	((HI - LO) + 1) DUP(?)

; flag data for sortList and helper functions

; output storage for sortList and helper functions

; flag data for displayMedian and helper functions

; output storage for displayMedian and helper functions
halfwayPoint		DWORD	?
arraySizeMod2		DWORD	?

lowMiddleMost		DWORD	?
highMiddleMost		DWORD	?
medianValue			DWORD	?

.code
main PROC

	PUSH	OFFSET	intro1
	PUSH	OFFSET	intro2
	PUSH	OFFSET	intro3
	PUSH	OFFSET  intro4
	CALL	introduction


	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	PUSH	TYPE randArray
	PUSH	LO
	PUSH	HI
	CALL	fillArray

	PUSH	OFFSET outputSpacer
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	PUSH	TYPE randArray
	CALL	displayList


	; CALL	sortList

	; CALL	displayList

	; CALL	displayMedian

	; CALL	countList

	; CALL	displayList

	PUSH	OFFSET goodbyePrompt
	CALL	Goodbye
	

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: Introduction
;
; Description: Provides user with an introduction and description of the program.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [ebp+20]	= mem OFFSET intro1
;			[ebp+16]	= mem OFFSET intro2
;			[ebp+12]	= mem OFFSET intro3
;			[ebp+8]		= mem OFFSET intro4
;
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 20]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	MOV		EDX, [EBP + 16]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	POP		EBP
	RET		16
Introduction ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: fillArray
;
; Description: fills randArray with random integers whose range corresponds to the LO and HI constants.
;
; Preconditions: address for randArray and constant values ARRAYSIZE, LO, and HI must all have been pushed to the stack
; (see below)
;
; Postconditions: None
;
; Receives:
;		[ebp+24]	= mem offset randArray
;		[ebp+20]	= const ARRAYSIZE
;		[ebp+16]	= imm TYPE randArray
;		[ebp+12]	= const LO
;		[ebp+8]		= const HI
;
; Returns: 
;		randArray
;
;----------------------------------------------------------------------------------------------------------------------
fillArray PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ECX, [EBP+20]
	MOV		EDI, [EBP+24]
	
	_fillArrayLoop:
		MOV		EAX, [EBP+8]
		INC		EAX
		CALL	RandomRange

		CMP		EAX, [EBP+12]
		JGE		_valueGreaterOrEqualtoLow

		ADD		EAX, [EBP+12]

		_valueGreaterOrEqualtoLow:
			MOV		[EDI], EAX
			ADD		EDI, [EBP+16]

			LOOP	_fillArrayLoop

	POP		EBP
	RET		20
fillArray ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: sortList
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
sortList PROC
	PUSH	EBP
	MOV		EBP, ESP

sortList ENDP

;----------------------------------------------------------------------------------------------------------------------
; Name: sortListHelper
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
sortListHelper PROC
	PUSH	EBP
	MOV		EBP, ESP

sortListHelper ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: exchangeElements
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
exchangeElements PROC
	PUSH	EBP
	MOV		EBP, ESP

exchangeElements ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: displayMedian
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
displayMedian PROC
	PUSH	EBP
	MOV		EBP, ESP

displayMedian ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: displayList
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[ebp+20]	= OFFSET outputSpacer
; 		[ebp+16]	= OFFSET randArray
;		[ebp+12]	= LENGTHOF randArray
;		[ebp+8]		= TYPE randArray
;	
; Returns: None
;----------------------------------------------------------------------------------------------------------------------
displayList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	MOV		ESI, [ebp+16]	; starting index for randArray
	MOV		ECX, [ebp+12]   ; array size
	
	MOV		EBX, 0			; counter for knowning when to start a new display line
	
	MOV		EDX, [EBP+20]	; offset for outputSpacer for between numbers

	_displayList:
		
		; check the current display counter
		CMP		EBX, 20
		JNE		_writeDec
		
		; if the display counter equals 20, start a new line and reset the display counter
		CALL	Crlf
		MOV		EBX, 0

		; get the integer from randArray, write it and the formatting space, increment the source index for the array, and increment the display counter, then loop if ECX > 0
		_writeDec:
			MOV		EAX, [ESI]
			CALL	WriteDec
			CALL	WriteString
			ADD		ESI, [ebp+8]
			INC		EBX
			LOOP	_displayList

	POP		ESI
	POP		EBP
	RET		16
displayList ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: countList
;
; Description: 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
countList PROC
	PUSH	EBP
	MOV		EBP, ESP

countList ENDP


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

	MOV		EDX, [EBP + 8]
	CALL	Crlf
	CALL	Crlf
	CALL	WriteString
	CALL	Crlf

	POP		EBP
	RET		4
Goodbye ENDP


END main
