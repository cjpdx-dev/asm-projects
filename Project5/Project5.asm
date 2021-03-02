TITLE Program Template     (template.asm)

; Author: Chris Jacobs
; Last Modified: 2/28/2021
; OSU email address: jacobsc2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5               Due Date: 2/28/2021	Submitted: 3/1/2021 (1 Grace Day)
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
unsortedPrompt		BYTE	"Unsorted numbers: ",0
sortedPrompt		BYTE	"Sorted numbers: ",0
medianPrompt		BYTE	"Median value: ",0
numberFreqPrompt	BYTE	"Frequency of values: ",0
goodbyePrompt		BYTE	"Goodbye!",0

; data for formatting output
outputSpacer		BYTE	" ",0


; main data structures
randArray			DWORD	ARRAYSIZE DUP(?)
counts				DWORD	((HI - LO) + 1) DUP(?)


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

	PUSH	OFFSET unsortedPrompt
	PUSH	OFFSET outputSpacer
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	PUSH	TYPE randArray
	CALL	displayList


	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	PUSH	TYPE randArray
	CALL	sortList


	PUSH	OFFSET sortedPrompt
	PUSH	OFFSET outputSpacer
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	PUSH	TYPE randArray
	CALL	displayList


	PUSH	TYPE randArray
	PUSH	OFFSET medianPrompt
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE
	CALL	displayMedian


	PUSH	OFFSET randArray
	PUSH	LENGTHOF randArray
	PUSH	TYPE randArray
	PUSH	OFFSET counts
	PUSH	LENGTHOF counts
	PUSH	TYPE counts
	PUSH	HI
	PUSH	LO
	CALL	countList


	PUSH	OFFSET numberFreqPrompt
	PUSH	OFFSET outputSpacer
	PUSH	OFFSET counts
	PUSH	LENGTHOF counts
	PUSH	TYPE counts
	CALL	displayList


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

	; Write intro1
	MOV		EDX, [EBP + 20]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Write intro2
	MOV		EDX, [EBP + 16]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Write intro3
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Write intro4
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; Exit proc
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
;		[ebp+24]	= (mem) offset randArray
;		[ebp+20]	= (const) ARRAYSIZE
;		[ebp+16]	= (imm) TYPE randArray
;		[ebp+12]	= (const) LO
;		[ebp+8]		= (const) HI
;
; Returns: 
;		randArray
;
;----------------------------------------------------------------------------------------------------------------------
fillArray PROC
	PUSH	EBP
	MOV		EBP, ESP

	; Set initial counter for _fillArrayLoop
	MOV		ECX, [EBP+20]
	
	; Set EDI to point to the 0th index of randArray
	MOV		EDI, [EBP+24]		

	; Generate the random seed for call to RandomRange
	CALL	Randomize
	
	_fillArrayLoop:
		MOV		EAX, [EBP+8]
		INC		EAX
		CALL	RandomRange					; Get a random number with a maximum value of the HI const and store in EAX

		
		CMP		EAX, [EBP+12]				
		JGE		_valueGreaterOrEqualtoLow

		ADD		EAX, [EBP+12]				; If random number in EAX is less than 10, add 10 to the value in EAX

		_valueGreaterOrEqualtoLow:
			MOV		[EDI], EAX				; Store the new random number in the index where EDI currently points to
			ADD		EDI, [EBP+16]			; Increment the EDI by TYPE randArray (4)

			LOOP	_fillArrayLoop			; Repeat the loop

	POP		EBP
	RET		20
fillArray ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: sortList
;
; Description: Sorts the random integers in randArray in accending order. Calls the exchangeElements procedure
;
; Preconditions: None
;
; Postconditions: integers stored in randArray are now sorted
;
; Receives:
;		[ebp+16]	= (mem) OFFSET randArray
;		[ebp+12]	= (const) ARRAYSIZE
;		[ebp+8]		= TYPE randArray
;
; Returns:
;		randArray
;
;----------------------------------------------------------------------------------------------------------------------
sortList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	; Initialize the ECX counter for the outer loop = ARRAYSIZE - 1
	
	MOV		ECX, [EBP+12]	
	DEC		ECX

	; Begin Outer loop
	_outerLoop:
		PUSH	ECX						; Push the ECX of the outer loop to the stack

		; Begin Inner loop
		_innerLoop:
			MOV		ESI, [EBP+16]		; Set the ESI to point to the 0th index of randArray

			POP		EBX		
			MOV		EAX, EBX			; EAX now holds the ECX value from the outer loop
			PUSH	EBX					; Push the outer ECX value back to the stack

			SUB		EAX, ECX			; EAX now holds the currentIndex we want to compare

			PUSH	EAX					; Store currentIndex on the stack

			MOV		EAX, [EBP+8]		; EAX now holds the TYPE of randArray(4)
			
			POP		EBX					; Pop currentIndex from stack
			
			MUL		EBX					; Multiply currentIndex by TYPE randArray (4)

			ADD		ESI, EAX			; After MUL, eax holds number of bytes to add to get to currentIndex's offset
										; we add this to ESI to point ESI to currentIndex

			MOV		EAX, [ESI]			; EAX now holds value of currentIndex

			ADD		ESI, [EBP+8]		; Add the TYPE of randArray (4) to point the ESI to currentIndex + 1
			MOV		EBX, [ESI]			; EBX now holds value of currentIndex + 1
				
			CMP		EAX, EBX			; Compare the value at currentIndex with the value at currentIndex + 1

			JLE		_indexLessOrEqualToIndexPlusOne

			
			PUSH	[EBP+8]				; Push TYPE of randArray to stack
			PUSH	EAX
			PUSH	EBX
			PUSH	ESI					; Push ESI to stack - current ESI represents offset for currentIndex + 1
			CALL	exchangeElements

		_indexLessOrEqualToIndexPlusOne:
		LOOP	_innerLoop
		
	POP		ECX							; retrieve the old _outerLoop ECX counter from the stack and store in ECX
	LOOP	_outerLoop

	; exit the procedure
	POP		ESI
	POP		EBP
	RET		12
sortList ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: exchangeElements
;
; Description: Swaps the elements between the current index and current index + 1
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[ebp+8]		= (imm) ESI that represents OFFSET for currentIndex + 1
;		[ebp+12]	= (imm) value of currentIndex + 1
;		[ebp+16]	= (imm) value of currentIndex
;		[ebp+20]	= (imm) TYPE of randArray
;	
; Returns:
;		randArray
;
;----------------------------------------------------------------------------------------------------------------------
exchangeElements PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	; Set currentIndex + 1 = currentIndex
	MOV		ESI, [EBP+8]				
	MOV		EBX, [EBP+16]				
	MOV		[ESI], EBX					

	; Set currentIndex = currentIndex + 1
	SUB		ESI, [EBP+20]				
	MOV		EBX, [EBP+12]
	MOV		[ESI], EBX

	; exit procedure
	POP		ESI
	POP		EBP
	RET		16
exchangeElements ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: displayMedian
;
; Description: displays the median value for the set of numbers in randArray. For any non-fractional median value
; we use the "round half up" rule.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[ebp+20]	= imm TYPE for randArray (4)
;		[ebp+16]	= OFFSET for medianPrompt
;		[ebp+12]	= mem OFFSET randArray
;		[ebp+8]		= const ARRAYSIZE
;	
; Returns: None
;
;----------------------------------------------------------------------------------------------------------------------
displayMedian PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	CALL	Crlf
	CALL	Crlf
	MOV		EDX, [EBP+16]
	CALL	WriteString

	; Set ESI to first element of randArray
	MOV		ESI, [EBP+12]			


	; Get the remainder of ARRAYSIZE / 2, then compare with 0
	MOV		EAX, [EBP+8]
	MOV		EDX, 0
	MOV		EBX, 2
	DIV		EBX			
	CMP		EDX, 0

	JE		_listHasEvenNumberOfElements
			
	; Get the median of an odd set of numbers

	; If ARRAYSIZE was odd, EAX now holds the middle index

	MOV		EBX, [EBP+20]			; set EBX to TYPE value of randArray (4)
	MUL		EBX						; EAX now holds number of bytes to offset ESI to reach median value


	ADD		ESI, EAX				; ESI now points to median index
	MOV		EAX, [ESI]				; EAX now holds median value
	
	; Display the median value and exit the procedure
	CALL	WriteDec
	CALL	Crlf
	JMP		_exitDisplayMedian


	; Get the median for an even set of numbers
	_listHasEvenNumberOfElements:

									; If ARRAYSIZE was even, then EAX now holds the upper middle index
	MOV		EBX, [EBP+20]			; Set EBX to TYPE value of randArray (4)
	MUL		EBX						; EAX now holds number of bytes to offset ESI to reach upper middle index

	ADD		ESI, EAX				; ESI now points to upper middle index
	MOV		EAX, [ESI]				; EAX now holds upper-middle index value

	SUB		ESI, [EBP+20]			; Subtract TYPE value of randArray (4) from ESI. ESI now points to lower middle index
	MOV		EBX, [ESI]				; EBX now holds lower-middle index value

	ADD		EAX, EBX				; EAX now holds summation of lower-middle index value and upper-middle index value
	
	MOV		EDX, 0
	MOV		EBX, 2
	DIV		EBX						; EAX now holds the quotient of the calculation (lower middle + upper middle) / 2
									; and EDX holds the remainder of that calculation
									
	CMP		EDX, 0					; Compare EDX with 0
	JNE		_medianNotAWholeNumber					
	
	CALL	WriteDec				; If EDX is 0, then the median is a whole number and we can just display EAX as is
	CALL	Crlf
	JMP		_exitDisplayMedian
	

	_medianNotAWholeNumber:			; If EDX was not 0, then the median is fractional (EAX + .5) and we must use the 
									; round half up rule

	INC		EAX						; So increment EAX and then display that value as our estimated median
	CALL	WriteDec
	CALL	Crlf

	; exit procedure
	_exitDisplayMedian:
	POP		ESI
	POP		EBP
	RET		16
displayMedian ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: displayList
;
; Description: Displays an array of positive decimal integers
;
; Preconditions: Passed array has only positive unsigned decimal numbers.
;
; Postconditions: None
;
; Receives:
;		[ebp+24]	= OFFSET passedUserPrompt
;		[ebp+20]	= OFFSET outputSpacer
; 		[ebp+16]	= OFFSET passedArray
;		[ebp+12]	= LENGTHOF passedArray
;		[ebp+8]		= TYPE passedArray
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
	
	

	CALL	Crlf			; create an empty line for formatting
	MOV		EDX, [ebp+24]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	MOV		EDX, [EBP+20]	; offset for outputSpacer for between numbers

	_displayList:
		
		; check the current display counter
		CMP		EBX, 20
		JNE		_skipToWriteDec
		
		; if the display counter equals 20, start a new line and reset the display counter
		CALL	Crlf
		MOV		EBX, 0

		; get the integer from randArray, write it and the formatting space, increment the source index for the array, and increment the display counter, then loop if ECX > 0
		_skipToWriteDec:
			MOV		EAX, [ESI]
			CALL	WriteDec
			CALL	WriteString
			ADD		ESI, [ebp+8]
			INC		EBX
			LOOP	_displayList

	CALL	Crlf			; for fomatting

	; exit procedure
	POP		ESI
	POP		EBP
	RET		20
displayList ENDP


;----------------------------------------------------------------------------------------------------------------------
; Name: countList
;
; Description: Populates an array named counts. Each index in the counts array represents the frequency of each number
; found in the randArray
;
; Preconditions: randArray has been populated with only positive unsigned decimal numbers.
;
; Postconditions: None
;
; Receives:
;		[ebp+36]		= OFFSET randArray
;		[ebp+32]		= LENGTHOF randArray
;		[ebp+28]		= TYPE randArray
;		[ebp+24]		= OFFSET counts
;		[ebp+20]		= LENGTHOF counts
;		[ebp+16]		= TYPE counts
;		[ebp+12]		= HI
;		[ebp+8]			= LO
;	
; Returns:
;		counts
;
;----------------------------------------------------------------------------------------------------------------------
countList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	
	MOV		ECX, [EBP+32]		; init outerLoop ECX to LENGTHOF randArray
	
	; Begin outer loop
	_outerLoop:
		
		PUSH	ECX				; Push ECX to Stack
		MOV		ESI, [EBP+36]	; set ESI to 0th element of randArray

		MOV		EBX, ECX
		DEC		EBX				; EBX now holds the index for the value in randArray we want to use 

		MOV		EAX, [EBP+28]	; EAX now holds the TYPE of randArray (4)
		MUL		EBX

		ADD		ESI, EAX		; EAX now holds the number of bytes to add to ESI to point ESi to the index for the value we want
		MOV		EAX, [ESI]		; EAX now holds the value at randArray[ecx-1]
		PUSH	EAX				; Push EAX (randArray[ecx-1]) to stack
		
		MOV		EAX, [EBP+12]	; Set EAX to the starting "current" number, which is always the HI constant value

		MOV		EBX, [EBP+12]
		SUB		EBX, [EBP+8]
		INC		EBX
		MOV		ECX, EBX		; Subtract HI from LO, INC by 1 and store this value in ECX as our _innerLoop counter

		; Begin inner loop
		_innerLoop:
			POP		EBX			; Pop from stack - EBX holds num (randArray[ecx-1])
			CMP		EAX, EBX	; Compare with EAX (EAX holds the current number which starts at the HI constant value)
			PUSH	EBX

			JNZ		_currentDoesNotEqualNum

				MOV		ESI, [EBP+24]	; Set ESI to 0th element of counts
				
				MOV		EBX, ECX		; Set EBX to current ECX
				DEC		EBX				; EBX now holds the index of counts we need to increment
				
				MOV		EAX, [EBP+16]	; Set EAX to TYPE of counts (4)
				MUL		EBX				; EAX now holds the number of bytes to add to ESI to get value at the index we need to increment

				ADD		ESI, EAX		; Edit the ESI by adding EAX
				MOV		EAX, [ESI]		; EAX now holds the value we need to increment
				INC		EAX				; Increment EAX value

				PUSH	EDI				; Save EDI on Stack
				MOV		EDI, ESI		; Set the EDI to the previous ESI
				MOV		[EDI], EAX		; Append the newly incremented EAX value to the index where the old value was
				POP		EDI				; Restore EDI
				
				JMP		_breakInnerLoop	; Break out of the inner loop	
			
			_currentDoesNotEqualNum:
			DEC		EAX					; Decrement EAX (current number) and repeat loop
		
		LOOP _innerLoop

		_breakInnerLoop:
		POP		EBX						; Keep stack alligned!
		POP		ECX						; Restore outerLoop's counter
	LOOP _outerLoop

	; end procedure
	POP		ESI
	POP		EBP
	RET		32
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
