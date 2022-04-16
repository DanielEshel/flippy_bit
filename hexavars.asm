
	;mask vars
	newpos dw 0 			;variable for new position number in the screen to print a mask
	oldpos dw 0				;variable to save the postion number in the screen of a mask that was or going to be covered by another mask or pixels
	maskhigh dw 0			;height of a mask for printing
	maskwidth dw 0			;width of a mask for printing
	maskname dw 0			;name of the background of the mask
	notmaskname dw 0		;name of the mask





	;bmp vars
	filenameend  db 'end.bmp',0				;saves the name of the endscreen bmp picture
    filenamestart    db 'start.bmp',0		;saves the name of the startscreen (menu) bmp picture
	filenameinfo	db 'instruct.bmp',0		;saves the name of the instructions screen bmp picture
	filenameW   	db 'finish.bmp',0		;saves the name of the winning screen bmp picture

	offsetfilename dw 0 					;var to keep the offset of the filename (so there won't be a seprete printing proc for each bmp image)
    filehandle  dw ?						;handle for bmp file
    Header      db 54 dup (0)				;header for bmp file
    Palette     db 256*4 dup (0)			;bmp color ballete
    ScrLine     db 320 dup (0)				;save line of pixels to copy from bmp image to screen
    ErrorMsg    db 'Error in open file', 13, 10,'$'	;messege if bmp image printing failed




	;shapes vars:
	startrow	dw (?)				;srarting row to print a square on screen
	endrow 	 	dw (?)				;neding row to print a square on the screen
	startcolunm dw (?)				;starting colunm
	endcolunm	dw (?)				;ending colunm
	color 		db (?)				;color of pixels to print

	;clock vars
	Clock 		equ es:6Ch			;the clock
	Clockcounter dw 0				;counter for the clock (to count clocktick (scroll, random and more..)
	Clockendcounter dw 2			;to save number of clockticks wanted


	;sound vars:
	sound1 db  98h					;first sound to play
	sound2 db 0Ah					;second sound to play
	note db ?

	;slot vars:
	number db 00h					;saves the hexanumber the user made each time
	switch db 00h					;acts like boolean if the user pressed a key down (so the keys will act like a t flip-flop)


	;randomvars:
	randomcounter db 0				;counter for how many clockticks until a random hexanumber is printed
	toplimit db 0					;top limit for random number genarator
	bottomlimit db 0 				;bottom limit for random number genarator
	timestillnextrand db 90
	randxor dw 0
	hexanum db 15 dup (0)			;array to keep the numbers invading
	hexanumplace dw 15 dup (0)		;array to keep the placements of the numbers
	lastrandom1 db 0 				;keep the last place a hexanumber was placed
	lastrandom2 db 0				;keep the last place a hexanumber was placed
	killcount dw 0					;var to hold how many hexadecimals the player exploded
	killcountindex dw 0				;var to hold how many kills to get the game more difficult


	;bullet vars:
	explosion dw 3 dup (0)			;var to hold the place of the explosion
	explosioncount db 3 dup (0)		;counter for how many scrolls of the screen the explosion is alive (if its 0 , the explosion doesn't exist)
	offsetkeep dw 0					;keep the offsets of screenkeeps
	scrkeep1 db 13*18 dup (0) 		;keep pixels from the screen to move with them the missiles
	scrkeep2 db 13*18 dup (0)
	scrkeep3 db 13*18 dup (0)
	scrkeep4 db 13*18 dup (0)
	scrkeep5 db 13*18 dup (0)
	bullet dw 5 dup (0)				;holds the possition of the missiles (max num of missiles on the air at the same time is 5)

	;highscore vars:
	highscore db "00$"				;the highscore
	filename db "best.txt",0		;name of file that holds the prev highscores
	handler dw ?					;handler for highscore red and write
	handle dw ?						;handle for highscore read and write
	highscoretens db 0				;the tens digit of the highscore read
	highscoreones db 0				;the ones digit of the highscore read

	scoremessage db 'Score:',13,10,'$'		;message to print the score achived in game
	highscoremessage db 'Best:',13,10,'$'	;message to print the all time best
	;masks:


	;the mask for the hexadecimal number frame.
	hexaMask  db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
		  db 15,15,00,15,15,15,15,15,15,15,15,15,15,15,15,15,15,00,15,15
	      db 15,15,00,00,15,15,15,15,15,15,15,15,15,15,15,15,00,00,15,15
		  db 15,15,15,15,00,00,00,00,00,00,00,00,00,00,00,00,15,15,15,15
		  db 15,15,15,15,00,00,00,00,00,00,00,00,00,00,00,00,15,15,15,15
		  db 15,15,15,15,00,15,15,15,15,15,15,15,15,15,15,00,15,15,15,15
		  db 15,00,00,15,00,15,15,15,15,15,15,15,15,15,15,00,15,00,00,15
		  db 15,00,15,00,00,15,15,15,15,15,15,15,15,15,15,00,00,15,00,15
		  db 15,00,15,00,00,15,15,15,15,15,15,15,15,15,15,00,00,15,00,15
		  db 15,00,15,15,00,15,15,15,15,15,15,15,15,15,15,00,15,15,00,15
		  db 15,00,15,15,00,15,15,15,15,15,15,15,15,15,15,00,15,15,00,15
		  db 15,15,00,15,00,15,15,15,15,15,15,15,15,15,15,00,15,00,15,15
		  db 15,15,15,00,00,15,15,15,15,15,15,15,15,15,15,00,00,15,15,15
		  db 15,15,15,15,00,15,15,15,15,15,15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,00,15,15,15,15,15,15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,00,00,00,00,00,00,00,00,00,00,00,00,15,15,15,15
		  db 15,15,15,15,15,15,15,15,00,15,15,00,15,15,15,15,15,15,15,15
		  db 15,15,15,15,15,15,15,15,00,15,15,00,15,15,15,15,15,15,15,15
		  db 15,15,15,15,15,15,00,00,00,00,00,00,00,00,15,15,15,15,15,15
		  db 15,15,15,15,15,00,15,15,15,15,15,15,15,15,00,15,15,15,15,15

	;the image for the hexadecimal number frame.
	hexa  	  db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
		  db 14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h
	      db 14h,14h,004,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,004,14h,14h
		  db 14h,14h,14h,14h,004,004,004,004,004,004,004,004,004,004,004,004,14h,14h,14h,14h
		  db 14h,14h,14h,14h,004,004,004,004,004,004,004,004,004,004,004,004,14h,14h,14h,14h
		  db 14h,14h,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,14h,14h
		  db 14h,004,004,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,004,004,14h
		  db 14h,004,14h,004,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,004,14h,004,14h
		  db 14h,004,14h,004,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,004,14h,004,14h
		  db 14h,004,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,004,14h
		  db 14h,004,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,004,14h
		  db 14h,14h,004,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,004,14h,14h
		  db 14h,14h,14h,004,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,004,14h,14h,14h
		  db 14h,14h,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,14h,14h
		  db 14h,14h,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,14h,14h
		  db 14h,14h,14h,14h,004,004,004,004,004,004,004,004,004,004,004,004,14h,14h,14h,14h
		  db 14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h
		  db 14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h
		  db 14h,14h,14h,14h,14h,14h,004,004,004,004,004,004,004,004,14h,14h,14h,14h,14h,14h
		  db 14h,14h,14h,14h,14h,004,14h,14h,14h,14h,14h,14h,14h,14h,004,14h,14h,14h,14h,14h


	;the mask for a big 0 number (for the binary number the user types)
	zeromask  db 15,15,15,15,00,00,15,15,15,15
		  db 15,15,15,00,15,15,00,15,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,00,15,15,15,15,00,15,15
		  db 15,15,15,00,15,15,00,15,15,15
		  db 15,15,15,15,00,00,15,15,15,15

	 ;the image for a big 0 number (for the binary number the user types)
	zero  db 00,00,00,00,15,15,00,00,00,00
		  db 00,00,00,15,00,00,15,00,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,15,00,00,00,00,15,00,00
		  db 00,00,00,15,00,00,15,00,00,00
		  db 00,00,00,00,15,15,00,00,00,00





	 ;the mask for a big 1 number (for the binary number the user types)
	onemask   db 15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,00,00,15,15,15,15
		  db 15,15,15,00,00,00,15,15,15,15
		  db 15,15,00,00,15,00,15,15,15,15
		  db 15,15,00,15,15,00,15,15,15,15
		  db 15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,15,15,00,15,15,15,15
		  db 15,15,15,00,00,00,00,00,15,15
	;the image for a big 1 number (for the binary number the user types)
	one       db 00,00,00,00,00,15,00,00,00,00
		  db 00,00,00,00,15,15,00,00,00,00
		  db 00,00,00,15,15,15,00,00,00,00
		  db 00,00,15,15,00,15,00,00,00,00
		  db 00,00,15,00,00,15,00,00,00,00
		  db 00,00,00,00,00,15,00,00,00,00
		  db 00,00,00,00,00,15,00,00,00,00
		  db 00,00,00,00,00,15,00,00,00,00
		  db 00,00,00,00,00,15,00,00,00,00
		  db 00,00,00,15,15,15,15,15,00,00

	;the image for the number zero for an hexadecimal number.
	zerosmall 		db  14h,14h,14h,14h,14h
				db  14h,15,15,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,14h,15,14h
				db  14h,15,15,15,14h
				db  14h,14h,14h,14h,14h

	;the mask for the number zero for an hexadecimal number.
	zerosmallmask	db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,00,15
				db 15,15,15,15,15

	;the image for the number 1 for an hexadecimal number.
	onesmall        db 14h,14h,14h,14h,14h
				db 14h,14h,15,15,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,15,15,15
				db 14h,14h,14h,14h,14h
	;the mask for the number 1 for an hexadecimal number.
	onesmallmask	db 15,15,15,15,15
				db 15,15,00,00,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,00,00,00
				db 15,15,15,15,15



	;the image for the number 2 for an hexadecimal number.
	twosmall		db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,15,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number 2 for an hexadecimal number.
	twosmallmask    db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,00,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,15,15,15,15


	;the image for the number 3 for an hexadecimal number.
	threesmall		db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
;the mask for the number 3 for an hexadecimal number.
	threesmallmask	db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,00,00,00,15
				db 15,15,15,15,15


	;the image for the number 4 for an hexadecimal number.
	foursmall		db 14h,14h,14h,14h,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number 4 for an hexadecimal number.
	foursmallmask   db 15,15,15,15,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,15,15
	;the image for the number 5 for an hexadecimal number.
	fivesmall		db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h

	;the mask for the number 5 for an hexadecimal number.
	fivesmallmask   db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,00,00,00,15
				db 15,15,15,15,15

	;the image for the number 6 for an hexadecimal number.
	sixsmall		db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number 6 for an hexadecimal number.
	sixsmallmask    db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,00,15
				db 15,15,15,15,15
	;the image for the number 7 for an hexadecimal number.
	sevensmall      db 14h,14h,14h,14h,14h
				db 15,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number 7 for an hexadecimal number.
	sevensmallmask  db 15,15,15,15,15
				db 00,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,15,15

	;the image for the number 8 for an hexadecimal number.
	eightsmall      db 14h,14h,14h,14h,14h
				db 14h,15,15,14h,14h
				db 15,14h,14h,15,14h
				db 15,14h,14h,15,14h
				db 15,14h,14h,15,14h
				db 14h,15,15,14h,14h
				db 15,14h,14h,15,14h
				db 15,14h,14h,15,14h
				db 14h,15,15,14h,14h
				db 14h,14h,14h,14h,14h

	;the mask for the number 8 for an hexadecimal number.
	eightsmallmask  db 15,15,15,15,15
				db 15,00,00,15,15
				db 00,15,15,00,15
				db 00,15,15,00,15
				db 00,15,15,00,15
				db 15,00,00,15,15
				db 00,15,15,00,15
				db 00,15,15,00,15
				db 15,00,00,15,15
				db 15,15,15,15,15

	;the image for the number 9 for an hexadecimal number.
	ninesmall       db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,14h,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number nine for an hexadecimal number.
	ninesmallmask   db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,15,15,00,15
				db 15,00,00,00,15
				db 15,15,15,15,15


	;the image for the number A for an hexadecimal number.
	Asmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,14h,14h,14h,14h

	;the mask for the number A for an hexadecimal number.
	Asmallmask      db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,15,15,15,15

	;the image for the number B for an hexadecimal number.
	Bsmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,14h,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,14h,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,14h,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number B for an hexadecimal number.
	Bsmallmask      db 15,15,15,15,15
				db 15,00,00,15,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,15,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,15,15
				db 15,15,15,15,15

	;the image for the number C for an hexadecimal number.
	Csmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number C for an hexadecimal number.
	Csmallmask      db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,15,15,15,15


	;the image for the number D for an hexadecimal number.
	Dsmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,14h,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,14h,15,14h
				db 14h,15,15,14h,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number D for an hexadecimal number.
	Dsmallmask      db 15,15,15,15,15
				db 15,00,00,15,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,15,00,15
				db 15,00,00,15,15
				db 15,15,15,15,15

	;the image for the number E for an hexadecimal number.
	Esmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number E for an hexadecimal number.
	Esmallmask      db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,15,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,15,15,15,15
				db 15,00,15,15,15
				db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,15,15,15,15
	;the image for the number F for an hexadecimal number.
	Fsmall          db 14h,14h,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,15,15,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,15,14h,14h,14h
				db 14h,14h,14h,14h,14h
	;the mask for the number F for an hexadecimal number.
	Fsmallmask      db 15,15,15,15,15
				db 15,00,00,00,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,00,00,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,00,15,15,15
				db 15,15,15,15,15

	   ;a mask to cover an explosion or a missile when needs to.
	killmask 		db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h
				db 14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h,14h




	;an image for an explosion that needs to be printed.
	explosionA	db  00h, 00h, 00h, 00h, 28h, 28h, 28h, 28h, 00h, 00h, 00h, 00h, 27h, 28h, 28h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 28h, 28h, 28h, 28h, 28h, 28h, 28h, 2Bh, 28h, 28h, 28h, 28h, 28h, 28h, 00h, 00h, 00h, 00h
				db  00h, 00h, 28h, 28h, 28h, 28h, 29h, 2Bh, 2Bh, 29h, 28h, 2Ah, 29h, 28h, 28h, 28h, 28h, 28h, 00h, 00h, 00h, 00h
				db  00h, 28h, 28h, 28h, 28h, 28h, 29h, 41h, 2Bh, 41h, 42h, 29h, 28h, 28h, 29h, 28h, 28h, 28h, 00h, 00h, 00h, 00h
				db  00h, 28h, 28h, 28h, 29h, 2Ah, 2Bh, 42h, 2Bh, 42h, 2Bh, 2Ah, 0Ch, 41h, 0Ch, 29h, 28h, 28h, 28h, 27h, 00h, 00h
				db  00h, 28h, 28h, 28h, 28h, 2Bh, 44h, 2Bh, 2Bh, 2Bh, 2Bh, 2Bh, 0Eh, 42h, 42h, 0Eh, 2Ah, 29h, 29h, 28h, 00h, 00h
				db  28h, 0Ch, 2Ah, 00h, 41h, 0Eh, 0Eh, 2Bh, 0Eh, 2Ch, 0Eh, 0Eh, 44h, 43h, 2Bh, 2Bh, 28h, 2Ah, 2Ah, 29h, 00h, 00h
				db  28h, 00h, 2Bh, 2Ah, 2Bh, 2Bh, 2Bh, 2Bh, 0Eh, 0Eh, 44h, 1Eh, 44h, 44h, 0Eh, 2Ah, 29h, 2Ah, 29h, 2Ah, 00h, 00h
				db  00h, 28h, 2Ah, 29h, 2Ah, 2Bh, 2Ch, 0Eh, 44h, 44h, 0Fh, 0Fh, 5Bh, 0Eh, 2Ch, 2Ah, 2Ah, 2Bh, 29h, 2Ah, 2Bh, 28h
				db  00h, 28h, 29h, 28h, 29h, 0Eh, 2Bh, 2Ch, 44h, 5Ch, 0Fh, 0Fh, 5Ch, 0Eh, 2Ch, 0Eh, 0Ch, 29h, 00h, 2Ah, 2Ah, 28h
				db  00h, 00h, 2Ah, 2Ah, 29h, 2Bh, 2Ah, 0Eh, 0Eh, 43h, 5Bh, 44h, 5Ch, 44h, 2Bh, 0Ch, 29h, 29h, 29h, 29h, 2Ah, 28h
				db  00h, 00h, 29h, 29h, 28h, 2Ah, 2Bh, 42h, 43h, 0Eh, 0Eh, 43h, 44h, 43h, 41h, 29h, 29h, 2Ah, 2Ah, 2Ah, 28h, 28h
				db  00h, 28h, 28h, 28h, 29h, 29h, 0Ch, 2Bh, 2Bh, 0Eh, 44h, 43h, 43h, 43h, 2Bh, 2Bh, 29h, 2Bh, 2Ah, 28h, 28h, 28h
				db  00h, 28h, 28h, 28h, 2Bh, 2Ah, 29h, 0Ch, 41h, 2Bh, 2Ah, 41h, 0Ch, 41h, 2Bh, 2Ah, 29h, 28h, 29h, 2Ah, 2Ch, 00h
				db  00h, 00h, 28h, 28h, 28h, 29h, 2Ah, 2Ah, 28h, 29h, 2Ah, 2Ah, 2Ah, 2Ah, 29h, 28h, 28h, 2Ah, 2Ah, 2Bh, 28h, 00h
				db  00h, 00h, 00h, 28h, 28h, 28h, 28h, 2Ah, 28h, 28h, 29h, 29h, 29h, 2Ah, 28h, 28h, 28h, 2Bh, 2Ah, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 28h, 29h, 2Ah, 28h, 28h, 28h, 28h, 28h, 28h, 0Eh, 2Bh, 2Ah, 28h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 00h, 2Bh, 2Ah, 29h, 28h, 28h, 28h, 28h, 28h, 29h, 29h, 28h, 28h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 28h, 28h, 00h, 00h, 00h, 00h, 00h, 00h
	;a mask for an explosion that needs to be printed.
	explosionMask		db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh
				db  00h, 00h, 00h,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh
				db  00h,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh, 00h, 00h, 00h
				db 0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db 0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh
				db 0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh
				db 0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh, 00h, 00h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh





	;an image for a missile that needs to be printed.
	rocket		db  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h,0B8h, 70h,0B8h, 00h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 70h, 28h, 70h, 00h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h,0B8h, 28h, 28h, 28h,0B8h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 11h, 88h, 88h, 88h, 11h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 13h, 1Ah, 1Ch, 1Ah, 13h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 13h, 1Ah, 40h, 1Ah, 13h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 13h, 40h, 58h, 40h, 13h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 13h, 19h, 40h, 19h, 13h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 12h, 1Ah, 1Bh, 1Ah, 12h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 70h,0D0h, 1Ah, 1Bh, 1Ah,0D0h, 70h, 00h, 00h, 00h
				db  00h,0B8h, 04h, 28h, 6Fh, 1Ah, 1Bh, 1Ah, 6Fh, 28h, 04h,0B8h, 00h
				db  00h, 70h, 04h, 04h, 11h, 1Ah, 1Bh, 1Ah, 11h, 04h, 04h, 70h, 00h
				db  00h, 00h, 00h, 00h, 73h, 89h, 89h, 8Ah, 73h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 2Ch, 2Bh, 2Ah, 29h, 2Ah, 2Bh, 2Ch, 00h, 00h, 00h
				db  00h, 00h, 00h, 2Bh, 2Bh, 2Bh, 2Ah, 2Bh, 2Bh, 2Bh, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 2Bh, 2Bh, 2Bh, 2Bh, 2Bh, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 2Ch, 2Bh, 2Ch, 00h, 00h, 00h, 00h, 00h
	; a mask for a missile that needs to be printed.
	rocketMask		db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh, 00h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh
				db 0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh
				db 0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh
				db  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
				db 0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh
				db 0FFh,0FFh,0FFh,0FFh,0FFh, 00h, 00h, 00h,0FFh,0FFh,0FFh,0FFh,0FFh





