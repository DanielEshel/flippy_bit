	; get name maskname and notmaskname , inputing the values into var maskname and notmaskname and printing the mask
	print_values macro  mask_name, not_mask_name
	mov [word ptr maskname], offset mask_name
	mov [word ptr notmaskname] ,  offset not_mask_name
	call anding 
	call oring
	endm
	
	;receives: number 
	;pushes: the number ored with var switch
	char macro number
	or [switch], number
	endm
	
	;recives: the bit we need to change in number , position ,starting row of number slot,ending row of numbers slot and sound
	;gives: the number slot of the wanted bit changed from 0 to one or from 1 to 0 if needed, and sound playing .
	unchar macro number , pos, startr , endr ,soundone, soundtwo
	mov bl, number
	mov [newpos],pos
	mov [word ptr startrow] , startr
	mov [word ptr endrow] , endr
	mov [word ptr startcolunm],178
	mov [word ptr endcolunm],196
	mov [sound1],soundone
	mov [sound2],soundtwo
	call uncharnum

	endm 
	
	; receives: list of registers
	; pushes the given registers to the stack
	doPush macro r1,r2,r3,r4,r5,r6,r7,r8,r9
			irp register,<r9,r8,r7,r6,r5,r4,r3,r2,r1>
					ifnb <register>
							push register
					endif
			endm
	endm

	; receives: list of registers
	; pops the given registers from the stack
	doPop macro r1,r2,r3,r4,r5,r6,r7,r8,r9
        irp register,<r9,r8,r7,r6,r5,r4,r3,r2,r1>
                ifnb <register>
                        pop register
                endif
        endm
	endm

	; receives: nothing
	; initializes bp for accessing the procedure's parameters
	initBp  macro
			push bp
			mov bp, sp
			add bp, 2
	endm

	; change to graphic mode
	graphic_mode macro
	mov ax, 13h
	int 10h
	endm

	; change to text mode
	text_mode macro
	mov ax, 3
	int 10h
	endm
