
	proc OpenFile
	;enter – file name in filename
	;exit - Open file, put handle in filehandle
	mov ah, 3Dh
	xor al, al
	mov dx, [offsetfilename]
	int 21h
	jc openerror
	mov [filehandle],ax
	ret
	openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	mov ax, 4c00h ; exit the program
	int 21h
	endp OpenFile

	proc ReadHeader
	; Read BMP file header, 54 bytes
      mov ah,3fh
      mov bx, [filehandle]
      mov cx , 54
      mov dx,offset Header
      int 21h 
      ret
	endp ReadHeader

	proc ReadPalette
	; Read BMP file color palette, 256 ; colors * 4 bytes (400h)
    mov ah,3fh
    mov bx, [filehandle]
    mov cx , 400h 
    mov dx,offset Palette
    int 21h 
    ret
	endp ReadPalette

	proc CopyPal
	; Copy the colors palette to the video memory registers 
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette 
	mov cx,256
	mov dx,3C8h
	mov al,0 
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx 

PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] 	; Get red value.
	shr al,2 		; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al		 ; Send it.
	mov al,[si+1] 	; Get green value.
	shr al,2
	out dx,al 		; Send it.
	mov al,[si] 	; Get blue value.
	shr al,2
	out dx,al 		; Send it.
	add si,4		 ; Point to next color.
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
	endp CopyPal

	proc CopyBitmap
	; BMP graphics are saved upside-down.
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200		;picture height
PrintBMPLoop:
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx 
	shl cx,6 
	shl di,8 
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320   ;picture width
	mov dx,offset ScrLine
	int 21h 
	; Copy one line into video memory
	cld 		; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb 	; Copy line to the screen
	pop cx
	loop PrintBMPLoop
	Ret
	endp CopyBitmap

	proc CloseFile
	;enter – filehandle
	;exit – close the 
	mov ah,3Eh
	mov bx, [filehandle]
	int 21h
	ret
	endp CloseFile

	;in: pic to print, gaps, width and height
	;out: bmp picture printed
	proc printPic
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
    call CloseFile
	ret
	endp printPic




	proc takeSqr
	;in: position in newpos
	;out: take 28x40 bytes from screen into scrkeep
	dopush es,ax,si,di,cx

	
	mov ax,0A000h
	mov es, ax
	mov di,[newpos]
	mov si, [offsetkeep]
	mov cx,[maskhigh]
takeLine:
	push cx
	mov cx, [maskwidth]
takecol:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takecol
	add di,320
	
	sub di, [maskwidth]
	pop cx
	loop takeLine
	
	dopop cx,di,si,ax,es
	
	ret
	endp takeSqr
	
	;in: position in oldpos
	;out: return 28X40 bytes from scrkeep to screen in oldpos 
	proc retSqr
	dopush es,ax,si,di,cx
	
	mov ax, 0a000h
	mov es, ax
	mov di, [oldpos]
	mov si, [offsetkeep] 
	mov cx, [maskhigh]
retLine:
	push cx
	mov cx,[maskwidth]
retcol:
	mov al,[si]
	mov [es:di], al 
	inc si
	inc di 
	loop retcol 
	add di,320
	sub di, [maskwidth]
	pop cx
	
	loop retLine 
	
	dopop cx,di,si,ax,es
	ret
	endp retSqr
	
	;in: position for mask in var newpos, mask height in var maskhigh and mask width in var maskwidth, the mask name  in var maskname
	;out: anding the mask with the screen 
	proc anding 
	dopush ax,es,di,si,cx
	mov ax,0A000h
	mov es, ax 
	mov di, [newPos]
	mov si, [maskname]
	mov cx,[maskhigh]
and1:
	push cx
	mov cx,[maskwidth]
xx:
	lodsb
	and [es:di], al
	inc di
	loop xx
	add di,320
	sub di, [maskwidth]
	pop cx 
	loop and1
	
	dopop cx,si,di,es,ax
	ret 
	endp anding
	

	;in: position for mask in var newpos, mask height in var maskhigh and mask width in var maskwidth, the image in var notmaskname
	;out: oring the mask with the screen 
	proc oring
	dopush	ax,es,di,si,cx

	
	mov ax, 0a000h
	mov es, ax
	mov di, [newpos]
	mov si, [notmaskname]
	mov cx, [maskhigh]
or1:
	push cx
	mov cx,[maskwidth]
yy:
	lodsb
	or [es:di],al
	inc di
	loop yy
	add di,320
	sub di,[maskwidth]
	pop cx
	loop or1
	
	dopop cx,si,di,es,ax
	ret 
	endp oring
	
	;out: scrolling the screen once (rows 10 – 184 will go one row down) 
	proc scrollline
	dopush ax,dx,cx,es,ds
	;pointing to the screen
	mov ax, 0A000h
	mov es,ax
	mov ds,ax
	
	xor dx,dx
loopscroll:
	mov di, 179*320 +55   ;end row number
	sub di,dx
	mov si, 178*320	+55   ;one below end row number
	sub si,dx
	mov cx,125
	rep movsw
	add dx,320
	cmp dx,320*172		;how many rown to scroll from the end of the scroll
	jne loopscroll
return:
	dopop ds,es,cx,dx,ax
	ret 
	endp scrollline
	
	
	;in: the x in startrow, the y in startcolunm and color in var color
	;out: a pixel painted in the cordinates
	proc printP
	dopush cx,dx,ax
	mov cx, [word ptr startrow] 
	mov dx, [word ptr startcolunm]
	mov al, [byte ptr color]
	mov ah, 0ch
	int 10h
	dopop ax,dx,cx
	
	
	ret 
	endp printP
	
	;in: row number in startrow, starting colunm in startcolunm, ending colunm in endcolunm,and color in var color
	;out: a vertical line of pixels painted 
	proc printVL
	push cx
	push [word ptr startcolunm]
	mov cx,  [word ptr endcolunm]
	sub cx, [word ptr startcolunm]
loop1:
	call printP
	inc [word ptr startcolunm]
	loop loop1
	pop [word ptr startcolunm]
	pop cx
	ret 
	endp printVL
	
	; in: starting row in startrow , ending row in endrow . startcolunm in startcolunm , and ending colunm in endcolunm, color is in var color
	; out: a square of pixels painted in chosen color
	proc printsquare
	push [word ptr startrow]
	push cx
	mov cx,[word ptr endrow]
	sub cx, [word ptr startrow]
loop2:
	call printVL
	inc [word ptr startrow]
	loop loop2
	pop cx
	pop [word ptr startrow]
	ret 
	endp printsquare
	
	;in:  random numbers range in toplimit and bottomlimit 
	;out: a random number from the wanted range of numbers
	proc random
	push es
	push bx
	; initialize
	mov ax, 40h
	mov es, ax
	
	inc [randxor]			;changing every time to make the random more random
	mov bx,[randxor]
	; generate random number
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 			; xor memory and counter
	and al, [toplimit] 		
	add al,[bottomlimit]
	pop bx
	pop es
	
	ret 
	endp random
	

	;out: reset the binary number and the number slots on the screen to be 0.
	proc reset
	push cx
	mov [maskhigh],10
	mov [maskwidth],10
	mov [maskname], offset zeromask
	mov [notmaskname], offset zero
	mov [byte ptr color],0
	
	mov [newpos],58630
	mov [word ptr startrow] ,65
	mov [word ptr endrow] , 85
	mov [word ptr startcolunm],174
	mov [word ptr endcolunm],196
	
	mov [switch],0
	mov [number],0
	mov cx,8
	
loopreset1:
	call printsquare
	call anding
	call oring
	add [newpos],30
	add [startrow],30
	add [endrow],30
	loop loopreset1
	call printbin
	pop cx
	ret 
	endp reset
	
	;the proc will reset all needed vars for a new game
 	proc newgame
	mov [number] , 00h
	mov [switch] , 00h
	
	
	;randomvars:
	mov [toplimit ] ,0
	mov [bottomlimit] , 0 
	mov [randxor ], 0
	mov cx,15
	mov bx, offset hexanumplace
	mov si, offset hexanum
makenextzero:
	mov [word ptr bx],0
	mov [byte ptr si],0
	add si,1
	add bx,2
	loop makenextzero
	
	
	mov [newpos] , 0 
	mov [oldpos] , 0


	mov [maskhigh] , 0
	mov [maskwidth] , 0
	mov [maskname ], 0
	mov [notmaskname] , 0
	
	mov [Clockendcounter] , 2
	mov [randomcounter] , 0
	
	mov [Clockcounter] , 0
	
	mov [timestillnextrand] , 100
	mov [killcount] , 0
	mov [killcountindex],  0
	
		;bullet vars:
	
	mov bx ,offset explosion
	mov si, offset explosioncount
	mov cx,2
makezeroexplosion:
	mov [word ptr bx],0
	mov [byte ptr si] , 0 
	loop makezeroexplosion


	mov bx, offset bullet
	mov cx,5
makebulletzero:
	mov [word ptr bx],0
	add bx,2
	loop makebulletzero
	
	ret 
	endp newgame
	
	
	;in: position in newpos, and num of pixels to check in si
	;out: al is 15 if one of the pixels is white
	proc checkcolorwhite
	dopush dx,cx,bx,di
	
	xor dx,dx
	mov ax, [newpos]
	xor di,di
	sub ax,320
	mov bx, 320
	div bx
	mov cx,dx
	mov dx,ax
	xor bh,bh
	mov ah,0dh 
checknextcolor:
	int 10h
	inc cx 
	inc di
	cmp al,15
	je exitloop
	cmp di,si
	jb checknextcolor
exitloop:
	dopop di,bx,cx,dx
	ret 
	endp checkcolorwhite
	
	;out: printing the current score on wanted place on the screen 
	proc printkillcount
	dopush dx,ax,bx
	; set cursor location 
	mov bh, 0
	mov dh,2
	mov dl,2
	mov ah,2h
	int 10h	
	
	xor dx,dx
	mov ax, [killcount]
	mov bl,10
	div bl
	
	mov dl,al
	mov bl,ah
	mov ah,2h
	add dl,48
	int 21h
	mov dl,bl
	add dl,48
	int 21h
	
	dopop bx,ax,dx
	ret 
	endp printkillcount
	
	;in: place to cover in [bx]
	;out: cover the explosion with a mask after a missile hits a target
	proc coverexplosion
	push dx
	mov dx,[bx]
	mov [newpos],dx

	
	mov [word ptr bx],0
	mov [maskname] , offset killmask
	mov [notmaskname], offset killmask
	mov [maskhigh],30
	mov [maskwidth], 22
	call anding 
	call oring
	pop dx
	ret 
	endp coverexplosion
	
	;out: print on the screen the hexadecimal number representing the binary number the user typed
	proc printbin
	dopush dx,ax,bx
	; set cursor location 
	mov bh, 0
	mov dh,22
	mov dl,2
	mov ah,2h
	int 10h	
	xor ax,ax
	xor dx,dx
	mov al, [number]
	mov bl,16
	div bl
	
	mov dl,al
	mov bl,ah
	mov ah,2h
	cmp dl,10
	jae add55
	add dl,48

	jmp cont16
add55:
	add dl,55
cont16:
	
	int 21h
	mov dl,bl

	cmp dl,10
	jae add552
	add dl,48
	jmp cont17
add552:
	add dl,55
cont17:
	int 21h

	dopop bx,ax,dx
	ret 
	endp printbin
	
	;out: a new file is opened named best(if not already exists, the kill count on the game will be printed on the new file (the file is a text file) this is used to save the high score.
	PROC writeashighscore
	dopush ax ,bx,dx,si
	xor ax, ax
	xor bx,bx
	xor dx,dx
	mov ax,[killcount]
	mov bx,10
	div bx
	add ax,48
	mov si, offset highscore
	mov [ si],ax
	add dx,48
	inc si
	mov [si],dx
	     
	;INITIALIZE DATA SEGMENT.
	mov  ax,@data
	mov  ds,ax

	;CREATE FILE.
	mov  ah, 3ch
	mov  cx, 0
	mov  dx, offset filename
	int  21h  

	;PRESERVE FILE HANDLER RETURNED.
	mov  [handler], ax

	;WRITE STRING.
	mov  ah, 40h
	mov  bx, [handler]
	mov  cx, 2  ;STRING LENGTH.
	mov  dx, offset highscore
	int  21h

	;CLOSE FILE (OR DATA WILL BE LOST).
	mov  ah, 3eh
	mov  bx, [handler]
	int  21h      
	
	dopop si,dx,bx,ax
	ret 
	endp writeashighscore
	
	;out: will read the file with the high score saven in it, and put the tens in var highscoretens and the ones in var highscoreones.
	proc readhighscore
	dopush dx,si,cx,bx,ax
	MOV AH, 3DH 	;Open the file
	MOV AL, 0 	;Open for reading
	LEA DX, [filename] 	;Presume DS points at filename
	INT 21H 	; segment
	MOV [HANDLE], AX 	;Save file handle
	XOR SI, SI
LP:
	MOV AH , 3FH 	;Read data from the file
	LEA DX, [handler] 	;Address of data buffer
	MOV CX, 40 	;Read 256 bytes
	MOV BX, [HANDLE]	 ;Get file handle value
	INT 21H
	
	xor ax,ax
	xor bx,bx
	xor dx,dx
	mov ax, [handler]
	sub al,48
	sub ah,48
	mov [highscoretens],al
	mov [highscoreones],ah

	dopop ax,bx,cx,si,dx
	ret 
	endp readhighscore
	
	;in: cx num of ticks
	;out: one clock tick delay
	proc waittick
	push ax
	push es
	mov ax, 40h
	mov es,ax
again: 
	
	mov ax,[clock]
wait1:
	cmp ax,[clock]
	je wait1
	loop again
	pop es
	pop ax
	ret
	endp waittick
	
	;in: var sound1 , and sound2 the sounds
	;out: the sounds playing 
	proc makesound
	push ax
	;making sound
	in al, 61h
	or al, 00000011b
	out 61h, al

	mov al, 0B6h
	out 43h, al
	mov al, [sound1]
	out 42h, al ; Sending lower byte
	mov al, [sound2]
	out 42h, al ; Sending upper byte
	
	pop ax
	ret 
	endp makesound
	
	;out: closing the sound playing
	proc closesound
	push ax
	;closing the sound 
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax
	ret 
	endp closesound
	
	;out: if one of the keys 1 - 8 is released, change the number of the user acordingly
	proc uncharnum
	push bx
	xor bl,11111111b
	and [switch],bl				;the second most left bit in switch will be 0
	xor bl,11111111b
	test [number],bl
	jz turnxto1
turnxto0:
	xor bl,11111111b
	and [number],bl
	call turnto0
	jmp return1
turnxto1:
	or [number],bl
	call turnto1
return1:
	pop bx
	ret
	endp uncharnum
	
	;in: two sounds to play , position to print the mask (0) , and cordinates to color the square.
	;out: the square and the mask of the number 0 printed on wanted spot, sound playing , changing the hexa translater as well .
	proc turnto0
	sub [sound1],15
	sub [sound2],5
	in al, 61h
	or al, 00000011b
	out 61h, al

	mov al, 0B6h
	out 43h, al
	mov al, [sound1]
	out 42h, al ; Sending lower byte
	mov al, [sound2]
	out 42h, al ; Sending upper byte

	mov [maskhigh],10
	mov [maskwidth],10
	mov [maskname], offset zeromask
	mov [notmaskname], offset zero
	mov [byte ptr color],0
	call printsquare
	call anding
	call oring
	call printbin
	ret
	endp turnto0
	
	;in: two sounds to play , position to print the mask (1) , and cordinates to color the square.
	;out: the square and the mask of the number 1 printed on wanted spot, sound playing 
	proc turnto1
	sub [sound1],14
	sub [sound2],4
	in al, 61h
	or al, 00000011b
	out 61h, al

	mov al, 0B6h
	out 43h, al
	mov al, [sound1]
	out 42h, al ; Sending lower byte
	mov al, [sound2]
	out 42h, al ; Sending upper byte

	mov [maskhigh],10
	mov [maskwidth],10
	mov [maskname], offset onemask
	mov [notmaskname], offset one
	call anding
	call oring
	mov [byte ptr color],0
	call printsquare
	call anding
	call oring
	call printbin
	ret 
	endp turnto1