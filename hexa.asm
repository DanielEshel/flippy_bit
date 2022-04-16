include hexamac.asm
IDEAL

jumps

MODEL small
STACK 100h
DATASEG
	include "hexavars.asm"
		
CODESEG
	include "hexaproc.asm"
start:
	mov ax, @data
	mov ds, ax
	mov ax,0A000h
	mov es,ax
; --------------------------
; Your code here
; --------------------------
	graphic_mode
menu:

	mov [offsetfilename],offset filenamestart

	;printing the menu picture
	call printPic

	;checking for input 
checkdata:
	mov ah,0ch
	mov al,7h
	int 21h
	
	;if esc key
	cmp al,27
	jne cont18
	jmp finish
cont18:
	;if 'i'
	cmp al,'i'
	je instruct
	;if 'm'
	cmp al,'m'
	je menu
	
	;if not 'i','m' or esc but something was pressed
	jmp startgame
instruct:
	;print instructions
	mov [offsetfilename], offset filenameinfo
	call printpic
	jmp checkdata
	
StartGame:
	
	;reseting color palet 
	text_mode
	graphic_mode
	
	;printing the sorroundings:
	;background color
	mov [word ptr startrow] ,0
	mov [word ptr endrow] , 320
	mov [word ptr startcolunm],0
	mov [word ptr endcolunm],200
	mov [byte ptr color]  , 7fh			;blue
	call printsquare
	
	;the sky
	mov [word ptr startrow] ,55
	mov [word ptr endrow] , 305
	mov [word ptr startcolunm],6
	mov [word ptr endcolunm],180
	mov [byte ptr color]  , 14h			;gray
	call printsquare
	
	;the ground
	mov [word ptr startrow] ,55
	mov [word ptr endrow] , 305
	mov [word ptr startcolunm],181
	mov [word ptr endcolunm],196
	mov [byte ptr color]  , 3			;turkize
	call printsquare
	
	;number slots:
	mov [word ptr startrow] ,65
	mov [word ptr endrow] , 85
	mov [word ptr startcolunm],174
	mov [word ptr endcolunm],196
	mov [byte ptr color]  , 1Bh		;gray
	mov cx,8
	

numslotloop:
	call printsquare
	add [word ptr startrow],30
	add [word ptr endrow],30
	loop numslotloop

	mov [word ptr startrow] , 55
	mov [word ptr endrow] , 305
	mov [word ptr startcolunm],180
	mov [word ptr endcolunm],181
	mov [byte ptr color]  , 0			;black
	call printsquare
	
	call reset		;make the number slots all 0;
	
	;killcount place
	mov [word ptr startrow] , 5
	mov [word ptr endrow] , 50
	mov [word ptr startcolunm],6
	mov [word ptr endcolunm],31
	mov [byte ptr color]  , 18h			;gray
	call printsquare
	;hexa - translator place
	mov [word ptr startrow] , 5
	mov [word ptr endrow] , 50
	mov [word ptr startcolunm],171
	mov [word ptr endcolunm],196
	mov [byte ptr color]  , 18h			;gray
	call printsquare
	
	;print killcount in wanted place
	call printkillcount
	;print hexa - calculator
	call printbin

waitdata:
	mov [clockcounter],0 	;reset the counter 
	
	;getting clock data
	mov ax, 40h
	mov es,ax
cont1:
	mov ax, [clock]
cont2:
	cmp ax,[clock]		;check if clcock changed
	je check1			;if not
	jmp check			;if clock changed
check1:
	
	;continue here whatever i want do between clock ticks:
	push ax
	;getting keyboard data
	in 	al, 64h 			; Read keyboard status port
	cmp 	al, 10b 		; Data in buffer? 
	je	WaitData 			; Wait until available
	in 	al, 60h 			; Get keyboard data
	
	cmp al,27
	je finish
	
	push bp
	mov bl,2h
	mov dh , 82h
	mov ah,80h
	mov si,58630
	mov bp,65
	mov di,85
	mov bh,098h
	mov dl ,0ah
	mov cx,8
checknextinput:
	;input checking:
	cmp al,bl			;if its 1
	jne char11			;if not
	char ah			
	jmp cont12
char11:
	cmp al, dh			;if 1 is releasedtasm/
	jne unchar11
	test [switch], ah	
	jz cont12			;if number slot doesn't need changing
	unchar ah , si , bp ,  di , bh , dl	;change the number slot
	jmp cont12	
unchar11:

	
	inc bl
	inc dh
	add si,30
	add bp,30
	add di,30
	inc bh
	inc dl
	shr ah,1
	loop checknextinput
	
	

cont12:
	pop bp
	;esc key?
	
	
	
	;check if one of the bullets has heached it's target
	mov bx, offset bullet
	mov [offsetkeep], offset scrkeep1
	mov cx,5
nextbullet2:
	cmp [word ptr bx],0
	je nextbullet21
	mov dx,[word ptr bx]
	mov [newpos],dx

	mov si,14
	call checkcolorwhite
	cmp al,15	
	jne nextbullet21
	
	mov [word ptr bx],0
	jmp killnum
nextbullet21:
	add bx,2
	add [offsetkeep], 13*18
	loop nextbullet2
	
	
	;check if one of the hexadecimal numbers is the same as the one the user typed:
	cmp [number],0			
	je cont11		;skip if the user's number is 0
cont111:

	mov cx,15
	mov si, offset hexanum
	mov bx,offset hexanumplace
checknext:
	mov dl, [number]
	cmp dl, [byte ptr si]
	jne checknext1

	mov [byte ptr si],0
	mov dx,[word ptr bx]
	jmp shootnum
	
	checknext1:
	inc si
	add bx,2
	loop checknext
	
cont11:
	
	;check if one of the numbers reached the ground
	mov bx,offset hexanumplace
	mov cx,15
checknextplace:
	cmp [word ptr bx],159*320
	jae EndGame1
	add bx,2
	loop checknextplace
	
	cmp [killcount] , 99
	jae endgame1
	
	jmp cont15
EndGame1: 
	jmp endgame
cont15:


	;change difficulty over time:
	mov bx, [killcountindex]
	cmp bx, [killcount]
	jne cont3
		
	add [killcountindex],3			;every 3 kills
	cmp [timestillnextrand],20		;max randspeed will be 20
	je cont3
	
	cmp [timestillnextrand], 50		;if bellow 2.75 seconds to spawn, sub 0.165 seconds every time
	ja sub10	
	mov [clockendcounter],1
	sub[timestillnextrand],3
	jmp cont3
sub10:
	sub [timestillnextrand],10		;make 0.55 seconds faster to spawn a number
	
cont3:

	;checking if need to spawn a hexa number.
	mov bl,[timestillnextrand]
	cmp [randomcounter],bl
	jb rand1
	jmp rand
rand1:
	pop ax 
	jmp cont2
	
	
	
check:;if the timer changed , counting it and if it was changed wanted wanted amount of times, scrolling
	add [clockcounter],1
	inc [randomcounter]
	mov bx, [clockcounter]
	cmp bx,[clockendcounter]
	jae scroll
	jmp cont1
	
	
	
scroll:
	;add to the place of every hexadecimal number that is alive 320 pixels (1 row)
	mov bx, offset hexanumplace 
	mov cx,15
addnext:
	cmp [word ptr bx],0 
	je addnext1
	add [word ptr bx],320
addnext1:
	add bx,2
	loop addnext


cont9:
	;if a missile is alive , move it up 6 rows (will be scrolled down later so its 5 total)
	mov [maskhigh], 18
	mov [maskwidth],13
	mov [maskname], offset rocketmask
	mov [notmaskname], offset rocket
	push dx
	
	mov bx, offset bullet
	mov [offsetkeep], offset scrkeep1
	mov cx,5
checknextbullet:
	cmp [word ptr bx] , 0
	je checknextbullet11
	mov dx, [word ptr bx]
	mov [newpos], dx
	mov [oldpos],dx
	sub [newpos],320*6
	call retSqr
	call takeSqr
	sub [newpos],320
	call anding 
	call oring
	sub [word ptr bx], 320*6
checknextbullet11:
	add bx,2
	add	[offsetkeep ] ,13*18
	loop checknextbullet
	
	
	;if one of the explosions was alive for more than 2 counts, covering it.
	pop dx
	mov si, offset explosioncount
	mov bx, offset explosion
	mov cx,2
nextexp:
	cmp [byte ptr si],0 
	je nextexp1
	inc [byte ptr si]
	cmp [byte ptr si], 3
	jbe nextexp1
	mov [byte ptr si],0
	call coverexplosion
nextexp1:
	inc si
	add bx,2
	loop nextexp

	;scrolling the screen 
	call scrollline
	
	;closing the sound if exists
	call closesound
	;back to the start of the loop
	jmp waitdata
	

	
	
	
rand:
	;printing the frame
newrandom:

	;get random place to print in 
	mov [randomcounter],0
	mov [toplimit],11				;from 0 to 11
	mov [bottomlimit],1				;plus 1 (from 1 to 12)
	call random
	cmp al, [lastrandom1]
	je newrandom
	cmp al, [lastrandom2]
	je newrandom
	mov bl, [lastrandom1]
	mov [lastrandom1],al
	mov [lastrandom2],bl
	
	xor ah,ah
	;print in wanted position
	mov [maskhigh],20
	mov [maskwidth],20
	mov [maskname], offset hexaMask
	mov [notmaskname], offset hexa
	mov [newpos],20
	mul [word ptr newpos]
	mov [newpos],ax
	sub [newpos],10
	add [newpos],320*7
	add [newpos],55
	call anding
	call oring
	
	;check store the data of the new hexa number in the first available variables (max numbers are 15)
	mov si, offset hexanum
	mov bx, offset hexanumplace
	mov cx,15
nexthexanum:
	cmp [byte ptr si],0
	jne nexthexanum1
	push dx
	mov di,si
	mov dx, [newpos]
	mov [word ptr bx],dx
	jmp cont6
nexthexanum1:
	inc si
	add bx,2
	loop nexthexanum

cont6:
	pop dx
	;printing the number
	;get the first random digit from 1-15 
	add [newpos],1605
	mov [maskhigh],10
	mov [maskwidth],5
	
	mov [toplimit],15
	mov [bottomlimit],0
	mov [randomcounter],0
	call random
	

	mov [byte ptr di],al
	;check what digit we got and print it
	cmp al,0
	jne next1
	print_values zerosmallmask ,zerosmall
	;change the limit if the first digit is 0 , the second one won't be 0.
	mov [toplimit],14
	mov [bottomlimit],1
	jmp cont4
next1:
	cmp al,1
	jne next2
	print_values  onesmallmask ,  onesmall	
	jmp cont4
next2:
	cmp al,2
	jne next3
	print_values  twosmallmask ,  twosmall	
	jmp cont4
next3:
	cmp al,3
	jne next4
	print_values  threesmallmask ,  threesmall	
	jmp cont4
next4:
	cmp al,4
	jne next5
	print_values  foursmallmask ,  foursmall	
	jmp cont4
next5:
	cmp al,5
	jne next6
	print_values  fivesmallmask ,  fivesmall	
	jmp cont4
next6:
	cmp al,6
	jne next7
	print_values  sixsmallmask ,  sixsmall	
	jmp cont4
next7:
	cmp al,7
	jne next8
	print_values  sevensmallmask ,  sevensmall	
	jmp cont4
next8:
	cmp al,8
	jne next9
	print_values  eightsmallmask ,  eightsmall	
	jmp cont4
next9:
	cmp al,9
	jne next10
	print_values  ninesmallmask ,  ninesmall	
	jmp cont4
next10:
	cmp al,10
	jne next11
	print_values  Asmallmask ,  Asmall	
	jmp cont4
next11:
	cmp al,11
	jne next12
	print_values  Bsmallmask ,  Bsmall
	jmp cont4
next12:
	cmp al,12
	jne next13
	print_values  Csmallmask ,  Csmall
	jmp cont4
next13:
	cmp al,13
	jne next14
	print_values  Dsmallmask ,  Dsmall
	jmp cont4
next14:
	cmp al,14
	jne next15
	print_values  Esmallmask ,  Esmall
	jmp cont4
next15:
	print_values  Fsmallmask ,  Fsmall
	
cont4:
	
	;get the next random digit
	call random
	
	shl [byte ptr di],4
	add [byte ptr di],al

	;check what digit we got and print it in wanted place
	add [newpos],5
	cmp al,0	
	jne nextb1
	print_values  zerosmallmask ,  zerosmall
	jmp cont3
nextb1:
	cmp al,1
	jne nextb2
	print_values  onesmallmask ,  onesmall
	jmp cont3
nextb2:
	cmp al,2
	jne nextb3
	print_values  twosmallmask ,  twosmall
	jmp cont3
nextb3:
	cmp al,3
	jne nextb4
	print_values  threesmallmask ,  threesmall
	jmp cont3
nextb4:
	cmp al,4
	jne nextb5
	print_values  foursmallmask ,  foursmall
	jmp cont3
nextb5:
	cmp al,5
	jne nextb6
	print_values  fivesmallmask ,  fivesmall
	jmp cont3
nextb6:
	cmp al,6
	jne nextb7
	print_values  sixsmallmask ,  sixsmall
	jmp cont3
nextb7:
	cmp al,7
	jne nextb8
	print_values  sevensmallmask ,  sevensmall
	jmp cont3
nextb8:
	cmp al,8
	jne nextb9
	print_values  eightsmallmask ,  eightsmall
	jmp cont3
nextb9:
	cmp al,9
	jne nextb10
	print_values  ninesmallmask ,  ninesmall
	jmp cont3
nextb10:
	cmp al,10
	jne nextb11
	print_values  Asmallmask ,  Asmall
	jmp cont3
nextb11:
	cmp al,11
	jne nextb12
	print_values  Bsmallmask ,  Bsmall
	jmp cont3
nextb12:
	cmp al,12
	jne nextb13
	print_values  Csmallmask ,  Csmall
	jmp cont3
nextb13:
	cmp al,13
	jne nextb14
	print_values  Dsmallmask ,  Dsmall
	jmp cont3
nextb14:
	cmp al,14
	jne nextb15
	print_values  Esmallmask ,  Esmall
	jmp cont3
nextb15:
	print_values  Fsmallmask ,  Fsmall
	jmp cont3
	

	
	
shootnum: 
	mov [word ptr bx],0
	mov [maskname], offset rocketmask
	mov [notmaskname] , offset rocket
	mov [maskhigh], 18
	mov [maskwidth],13
	
checknextrow:;get where we want to print the missle 
	add dx, 320
	cmp dx,165*320
	jb checknextrow
	
	add dx, 4
	mov [newpos],dx
	
	;check for available variable to store the data of the new missle
	mov bx, offset bullet
	mov [offsetkeep], offset scrkeep1
	sub bx,2
	sub [offsetkeep], 13*18
checknextbullet1:
	add [offsetkeep], 13*18
	add bx,2
	cmp [word ptr bx] , 0
	jne checknextbullet1
	mov [word ptr bx],dx
		
	call takeSqr	;keep the screen before the bullet (to move it later)
	
cont10:
	;print the bullet
	call anding
	call oring
	;reset the number the user typed so he can type a new one.
	call reset
	jmp cont3
	
	

killnum:
	;sound of the hit
	mov [sound1] , 0A0h
	mov [sound2], 049h

	call makesound
	
	;covering the missile:
	mov [newpos],dx
	
	mov bx , dx
	mov [maskname],offset killmask
	mov [notmaskname], offset killmask
	sub dx,320*15
	sub dx,6
	call anding
	call oring
	
	
	;search for available variable to store the data of the explosion
	mov bx, offset explosion
	mov si, offset explosioncount
	mov cx,2
nextex:
	cmp [word ptr bx],0
	jne nextex1
	mov [word ptr bx],dx
	inc [byte ptr si]
	jmp cont13
nextex1:
	inc si
	add bx,2
	loop nextex
	
cont13:

	inc [killcount]
	call printkillcount	;print the new killcount
	
	;print the explosion:
	mov [maskhigh],19
	mov [maskwidth],22
	mov [maskname], offset explosionmask
	mov [notmaskname], offset explosionA
	mov [newpos],dx
	call anding
	call oring
	jmp cont3
	

	
EndGame:
	;checking if need to change highscore
	xor ax,ax
	xor bx,bx
	call readhighscore
	mov ax, [killcount]
	mov bl,10
	div bl
	cmp al,[highscoretens]
	jbe cont19
	call writeashighscore
	jmp cont20
cont19:
	cmp al,[highscoretens]
	jne cont20
	cmp ah , [highscoreones]
	jb cont20
	call writeashighscore
cont20:
	push ax
	;setting the starting point of the picture(0,0)

	
	cmp [killcount],99
	jb otherend
	
	
	mov [offsetfilename],offset filenameW
	
	;printing the picture
	call printPic
	call copypal
	mov [sound1], 8Dh
	mov [sound2] , 12h
	
	;make winning sound:
	mov cx,2
	call waittick
	call makesound
	
	mov cx,3
	call waittick
	call closesound
	mov cx,1
	call waittick
	mov [sound1], 87h
	mov [sound2] , 0Fh
	call makesound
	mov cx,3
	call waittick
	call closesound
	mov cx,1
	call waittick
	mov [sound1] , 80h
	mov [sound2], 0Ch
	call makesound
	mov cx,3
	call waittick
	call closesound

	jmp cont21
	
otherend:
	;print the loosing picture
	mov [offsetfilename], offset filenameend
	call printpic
	
	;make loosing sound:
	mov [sound1] , 80h
	mov [sound2], 013h
	
	mov cx,2
	call waittick
	call makesound
	
	
	mov cx,5
	call waittick
	call closesound
	mov cx,1
	call waittick
	mov [sound1], 87h
	mov [sound2] , 19h
	call makesound
	mov cx,5
	call waittick
	call closesound
	mov cx,1
	call waittick
	
	
	mov [sound1], 8Dh
	mov [sound2] , 23h
	call makesound
	mov cx,5
	call waittick
	call closesound
	
cont21:
	
	;print the score and highscore:
	; set cursor location 
	xor bh,bh
	mov dh,14
	mov dl,29
	mov ah,2h
	int 10h	
	
	mov ah,9							;printing score message
	mov dx, offset scoremessage
	int 21h
	xor bh,bh
	mov dh,14
	mov dl,36
	mov ah,2h
	int 10h
	pop ax
	
	mov dl,al
	mov bl,ah
	mov ah,2h
	add dl,48
	int 21h
	mov dl,bl
	add dl,48
	int 21h
	
	; set cursor location 
	xor bh,bh
	mov dh,16
	mov dl,29
	mov ah,2h
	int 10h	
	mov ah,9
	mov dx, offset highscoremessage
	int 21h
	xor bh,bh
	mov dh,16
	mov dl,36
	mov ah,2h
	int 10h
	
	call readhighscore
	
	mov dl,[highscoretens]
	mov ah,2h
	add dl,48
	int 21h
	mov dl,[highscoreones]
	add dl,48
	int 21h
	
	;reset vars for a new game 
	call newgame
checkinput:
	;wait for input
	mov 	ah,0Ch
	mov 	al,07h
	int 	21h	

	
	cmp al,'1' 
	jne not1
	jmp startgame
not1:

	cmp al,27
	je finish
	
	cmp al,'m'
	jne notm
	jmp menu
notm:	

	cmp al,'i'
	jne checkinput
	jmp instruct
	
finish:

	text_mode
	jmp exit
	
	
exit:
	mov ax, 4c00h
	int 21h
END start

