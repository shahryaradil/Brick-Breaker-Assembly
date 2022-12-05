include Brick.inc
include Ball.inc
.model small
.stack 0100h
.data

f1 db "File1.txt", 0
buffer db 999 dup('$')
fileinfo dw 0

score dw 0
currTime db ?
rowsOfBricks dw 3
colsOfBricks dw 6
ballSpeedX dw 3
ballSpeedY dw 3
brickColor db 14
brickLength dw 10
brickWidth dw 30
brickStartX dw 40
brickStartY dw 50
paddleLength dw 5
paddleWidth dw 30
paddleX dw 145
count db 0
highScoresText db "High Scores"
instructionsTop db "Instructions"
instructions1 db "Use left - right cursor keys to move  paddle and break bricks"
instructions2 db "Avoid missing the pedal"
mainMenuString1 db "BRICK BREAKER GAME"
mainMenuString2 db "New Game"
mainMenuString3 db "Resume"
mainMenuString4 db "Instructions"
mainMenuString5 db "High Score"
mainMenuString6 db "Exit"
namePrompt db "Enter your name:"
levelScreenTop db "Choose a level"
level1text db "Level 1"
level2text db "Level 2"
level3text db "Level 3"
defaultSelect db 1
username db 15 dup ('$')

bricks Brick 18 dup (<?,?,10,30,1,1,14,0,10>)
numberOfBricks dw 18
numberOfCurrBricks dw 18

balls Ball <150, 185, 1, -1, 1, 2, 2, 1>

level db 1
lives db 2

.code

mov ax,@data
mov ds,ax

mov ax,0

jmp main

; Macro to draw a rectangle at x, y coordinates
drawrect macro length,width,x,y,color

	local drawrows, drawcols	; set labels as local to avoid redefinition error

	push si		; push all registers used
	push ax
	push bx
	push cx
	push dx

	mov si, width	
	add si, x	; final pixel position x

	mov bx, length
	add bx, y	; final pixel position y

	mov cx, x	; initial pixel position x
	mov dx, y	; initial pixel position y

	mov al, color ; set pixel color

	drawrows:
			
		mov cx, x	; start from initial pixel position x

		drawcols:

			mov ah, 0ch
			int 10h		; draw

			inc cx		; increment column
			
			cmp cx, si	; compare with final column pixel position

		jne drawcols

		inc dx		; increment row
		cmp dx, bx	; compare with final row pixel position

	jne drawrows

	pop dx		; pop all registers used
	pop cx
	pop bx
	pop ax
	pop si

endm

drawStringInitialize macro x, y ;initialize cursor position before drawing stirng

	mov ah, 02h
	mov dh, y ;Y co-ordinate
	mov dl, x ;X co-ordinate
	int 10h

endm

drawString macro inp, color ;draw string at initialized cursor position with input color value. inp is strng variable name.
	
	local loop1
	
	push si
	
	mov si, offset inp
	
	mov cx, lengthof inp
	
	loop1: ;loop to output string one character at a time
	mov al, [si]
	inc si
	mov bl, color
	mov bh, 0
	mov ah, 0EH
	int 10h
	loop loop1
	
	pop si

endm

pageUpdate macro pNo ;change page number

	mov ah, 00h
	mov al, 13h
	int 10h

	mov al, 14
	mov bh, pNo

endm

drawFrame macro

	local timeLoop, changeLevel, level3
	
	push cx
	push dx

	timeLoop:
		
		mov ah, 2ch
		int 21h

		movePaddle	; move paddle left or right

		cmp dl, currTime
		je timeLoop

		mov currTime, dl

		drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,0
		moveBall
		drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,15

		cmp numberOfCurrBricks, 0
		je changeLevel

		jmp timeLoop

	changeLevel:
		cmp level, 1
		jne level3
		mov level, 2
		drawGame2 rowsOfBricks, colsOfBricks
		jmp timeLoop

		level3:
			mov level, 3
			jmp timeLoop

	pop dx
	pop cx

endm

mainScreenDraw macro ;initialize main menu 
	
	drawStringInitialize 11, 4
	drawString mainMenuString1, 15
	drawStringInitialize 16, 8
	drawString mainMenuString2, 14
	drawStringInitialize 17, 11
	drawString mainMenuString3, 14
	drawStringInitialize 14, 14
	drawString mainMenuString4, 14
	drawStringInitialize 15, 17
	drawString mainMenuString5, 14
	drawStringInitialize 18, 20
	drawString mainMenuString6, 14

endm

levelScreenDraw macro
	
	drawStringInitialize 13, 4
	drawString levelScreenTop, 15
	drawStringInitialize 16, 9
	drawString level1text, 14
	drawStringInitialize 16, 14
	drawString level2text, 14
	drawStringInitialize 16, 19
	drawString level3text, 14

endm

mainScreenFunction macro
	
	local top, up, down, label1, label2, label3, label4, label5, select, startGame, selectHighScores, selectInstructions, selectStart
	
	mov al, 0Dh ; color
	mov ah, 0ch ; mode
	int 10h ; interrupt
	
	jmp label1
	
	top: ;infinite loop to take user input 
		mov ah, 0
		int 16h
		cmp ah, 48h
		je up
		cmp ah, 50h
		je down
		cmp ah, 28
		je select
	jmp top
	jz top
	
	up: ;case validator in case of up key being pressed
		cmp defaultSelect, 1
	je top
		dec defaultSelect
		cmp defaultSelect, 1
		je label1
		cmp defaultSelect, 2
		je label2
		cmp defaultSelect, 3
		je label3
		cmp defaultSelect, 4
		je label4
	jmp top
	
	down: ;case validator in case of down key being pressed
		cmp defaultSelect, 5
	je top
		inc defaultSelect
		cmp defaultSelect, 2
		je label2
		cmp defaultSelect, 3
		je label3
		cmp defaultSelect, 4
		je label4
		cmp defaultSelect, 5
		je label5
	jmp top
	
	label1: ;change selected menu option color
		mainScreenDraw
		drawStringInitialize 16, 8
		drawString mainMenuString2, 12
	jmp top
	
	label2: ;change selected menu option color
		mainScreenDraw
		drawStringInitialize 17, 11
		drawString mainMenuString3, 12
	jmp top
	
	label3: ;change selected menu option color
		mainScreenDraw
		drawStringInitialize 14, 14
		drawString mainMenuString4, 12
	jmp top
	
	label4: ;change selected menu option color
		mainScreenDraw
		drawStringInitialize 15, 17
		drawString mainMenuString5, 12
	jmp top
	
	label5: ;change selected menu option color
		mainScreenDraw
		drawStringInitialize 18, 20
		drawString mainMenuString6, 12
	jmp top

	select:
		cmp defaultSelect, 1
		je selectStart
		cmp defaultSelect, 2
		je selectStart
		cmp defaultSelect, 3
		je selectInstructions
		cmp defaultSelect, 4
		je selectHighScores
		cmp defaultSelect, 5
		je exit
	jmp top
	
	selectStart:
	levelScreenFunction
	
	selectInstructions:
	instructionsScreen
	jmp top
	
	selectHighScores:
	highScoreMenu
	jmp top

	startGame:
		pageUpdate 1						; update page
		drawGame rowsOfBricks,colsOfBricks	; draw start of game
		drawFrame							; start drawing frames

endm

levelScreenFunction macro

	local top, up, down, label1, label2, label3, select, selectLevel1, selectLevel2, selectLevel3
	
	clearScreen
	mov defaultSelect, 1
	
	mov al, 0Dh ; color
	mov ah, 0ch ; mode
	int 10h ; interrupt
	
	levelScreenDraw
	jmp label1
	
	top: ;infinite loop to take user input 
		mov ah, 0
		int 16h
		cmp ah, 48h
		je up
		cmp ah, 50h
		je down
		cmp ah, 28
		je select
	jmp top
	jz top
	
	up: ;case validator in case of up key being pressed
		cmp defaultSelect, 1
	je top
		dec defaultSelect
		cmp defaultSelect, 1
		je label1
		cmp defaultSelect, 2
		je label2
	jmp top
	
	down: ;case validator in case of down key being pressed
		cmp defaultSelect, 3
	je top
		inc defaultSelect
		cmp defaultSelect, 2
		je label2
		cmp defaultSelect, 3
		je label3
	jmp top
	
	label1: ;change selected menu option color
		levelScreenDraw
		drawStringInitialize 16, 9
		drawString level1text, 12
	jmp top
	
	label2: ;change selected menu option color
		levelScreenDraw
		drawStringInitialize 16, 14
		drawString level2text, 12
	jmp top
	
	label3: ;change selected menu option color
		levelScreenDraw
		drawStringInitialize 16, 19
		drawString level3text, 12
	jmp top

	select:
		cmp defaultSelect, 1
		je selectLevel1
		cmp defaultSelect, 2
		je selectLevel2
		cmp defaultSelect, 3
		je selectLevel3
	jmp top
	
	selectLevel1:
		clearScreen
		drawGame rowsOfBricks,colsOfBricks	; draw start of game
		drawFrame							; start drawing frames
	
	selectLevel2:
		clearScreen							; update page
		drawGame2 rowsOfBricks,colsOfBricks	; draw start of game
		drawFrame							; start drawing frames
		
	selectLevel3:
		clearScreen							; update page
		add ballSpeedX, 1
		add ballSpeedY, 1
		sub paddleWidth, 2
		drawGame3 rowsOfBricks,colsOfBricks	; draw start of game
		drawFrame							; start drawing frames

endm

drawGame macro rows, cols

	local startBrickDrawOuter, startBrickDrawInner, contLoop	; set labels as local to avoid redefinition error

	push cx							; push all registers to be used
	push si
	push ax
	push dx
	push bx

	mov brickStartX, 40
	mov brickStartY, 50

	mov cx, rows	
	mov si, offset bricks
	mov bx, type bricks

	startBrickDrawOuter:			; nested loop for creating rows and columns of bricks
		
		mov dx, cx
		mov cx, cols
		mov brickStartX, 40

		startBrickDrawInner: 

			mov al, 1
			cmp [si + 6], al		; check if bricks.isActive is 1
			jne contLoop			; only draw active bricks		; Code Check

			drawrect brickLength,brickWidth,brickStartX,brickStartY,14
			mov ax, brickStartX
			mov [si], ax			; store x value of brick in brick struct array
			mov ax, brickStartY
			mov [si + 2], ax		; store y value of brick in brick struct array
			add brickStartX, 40
			add si, bx				; move on to next brick

			contLoop:

		loop startBrickDrawInner

		mov cx, dx
		add brickStartY, 20

	loop startBrickDrawOuter

	drawrect paddleLength,paddleWidth,paddleX,195,9				; Draw Paddle on initial position

	pop bx							; pop all registers that were used
	pop dx
	pop ax
	pop si
	pop cx

endm

drawGame2 macro rows, cols

	local startBrickDrawOuter, startBrickDrawInner, contLoop, setData	; set labels as local to avoid redefinition error

	push cx							; push all registers to be used
	push si
	push ax
	push dx
	push bx

	drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,0

	add ballSpeedX, 1
	add ballSpeedY, 1

	sub paddleWidth, 2

	mov cx, numberOfBricks
	mov numberOfCurrBricks, cx
	mov si, offset bricks
	mov bx, type bricks
	mov brickColor, 12

	mov balls.x, 150
	mov balls.y, 185
	mov balls.xDir, 1
	mov balls.yDir, -1

	setData:

		mov al, 1
		mov [si + 6], al				; set brick as active
		mov al, 2
		mov [si + 7], al				; set number of hits as 2
		mov al, 12
		mov [si + 8], al				; set color as red
		mov al, 20
		mov [si + 10], al				; set score as 20

		add si, bx						; move on to next brick

	loop setData

	mov brickStartX, 40
	mov brickStartY, 50

	mov cx, rows	
	mov si, offset bricks
	mov bx, type bricks

	startBrickDrawOuter:			; nested loop for creating rows and columns of bricks
		
		mov dx, cx
		mov cx, cols
		mov brickStartX, 40

		startBrickDrawInner: 

			mov al, 1
			cmp [si + 6], al		; check if bricks.isActive is 1
			jne contLoop			; only draw active bricks		; Code Check

			drawrect brickLength,brickWidth,brickStartX,brickStartY,brickColor
			mov ax, brickStartX
			mov [si], ax			; store x value of brick in brick struct array
			mov ax, brickStartY
			mov [si + 2], ax		; store y value of brick in brick struct array
			add brickStartX, 40
			add si, bx				; move on to next brick

			contLoop:

		loop startBrickDrawInner

		mov cx, dx
		add brickStartY, 20

	loop startBrickDrawOuter

	drawrect paddleLength,paddleWidth,paddleX,195,9				; Draw Paddle on initial position

	pop bx							; pop all registers that were used
	pop dx
	pop ax
	pop si
	pop cx

endm

drawGame3 macro rows, cols

	local startBrickDrawOuter, startBrickDrawInner, contLoop, setData	; set labels as local to avoid redefinition error

	push cx							; push all registers to be used
	push si
	push ax
	push dx
	push bx

	drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,0

	add ballSpeedX, 1
	add ballSpeedY, 1

	mov cx, numberOfBricks
	mov numberOfCurrBricks, cx
	sub numberOfCurrBricks, 6
	mov si, offset bricks
	mov bx, type bricks
	mov brickColor, 12

	mov balls.x, 150
	mov balls.y, 185
	mov balls.xDir, 1
	mov balls.yDir, -1

	setData:

		mov al, 1
		mov [si + 6], al				; set brick as active
		mov al, 3
		mov [si + 7], al				; set number of hits as 3
		mov al, 10
		mov [si + 8], al				; set color as green
		mov al, 30
		mov [si + 10], al				; set score as 30

		add si, bx						; move on to next brick

	loop setData

	mov si, offset bricks
	mov cx, 6

	setUnbreakable:

		mov al, 1						
		mov [si + 9], al				; set brick as unbreakable
		mov al, 1
		mov [si + 8], al				; set color as blue

		add si, bx						; move on to next brick		

	loop setUnbreakable

	mov brickStartX, 40
	mov brickStartY, 50

	mov cx, rows	
	mov si, offset bricks
	mov bx, type bricks

	startBrickDrawOuter:			; nested loop for creating rows and columns of bricks
		
		mov dx, cx
		mov cx, cols
		mov brickStartX, 40

		startBrickDrawInner: 

			mov al, 1
			cmp [si + 6], al		; check if bricks.isActive is 1
			jne contLoop			; only draw active bricks		; Code Check

			mov ah, [si + 8]
			mov brickColor, ah		; get brick color
			drawrect brickLength,brickWidth,brickStartX,brickStartY,brickColor
			mov ax, brickStartX
			mov [si], ax			; store x value of brick in brick struct array
			mov ax, brickStartY
			mov [si + 2], ax		; store y value of brick in brick struct array
			add brickStartX, 40
			add si, bx				; move on to next brick

			contLoop:

		loop startBrickDrawInner

		mov cx, dx
		add brickStartY, 20

	loop startBrickDrawOuter

	drawrect paddleLength,paddleWidth,paddleX,195,9				; Draw Paddle on initial position

	pop bx							; pop all registers that were used
	pop dx
	pop ax
	pop si
	pop cx

endm

moveBall macro

	local incrementX, decrementX, incrementY, decrementY, changeDirectionX, changeDirectionY, changeBothDirections, done, checkCollision, outOfBounds, cont, cont1, here, here1, invertX, invertY

	push ax							; push all registers to be used
	push bx
	push cx
	push dx
	push di

	mov di, offset bricks			
	mov dx, type bricks
	mov cx, numberOfBricks	

	checkCollision:					; loop to check collision with bricks

		mov bl, [di + 6]			; check if brick is active
		cmp bl, 1
		jne cont1

		mov ax, [di + 2]			; check brick down side
		add ax, brickLength
		cmp balls.y, ax
		jg cont1

		sub ax, brickLength			; check brick up side
		cmp balls.y, ax
		jl cont1

		mov ax, [di]				; check brick left side
		cmp balls.x, ax
		jl cont1

		add ax, brickWidth			; check brick right side
		cmp balls.x, ax
		jg cont1

		mov bl, [di + 9]			; check if brick is unbreakable
		cmp bl, 1
		je here1

		mov bl, [di + 7]
		dec bl
		mov [di + 7], bl
		mov bh, [di + 8]
		dec bh
		mov [di + 8], bh
		drawrect brickLength, brickWidth,[di],[di + 2],[di + 8]
		cmp bl, 0
		jg here1
		
		drawrect brickLength,brickWidth,[di],[di + 2],0		; if ball gets in contact with brick, delete brick
		dec numberOfCurrBricks
		mov bx, [di + 10]
		add score, bx
		mov bh, 0
		mov [di + 6], bh

		here1:
		cmp balls.x, ax
		jle changeBothDirections	; change direction after hitting brick

		cont1:
		add di, dx					; move on to the next brick

	dec cx
	cmp cx, 0
	jne CheckCollision

	here:

	cmp balls.xDir, 1				; check which direction (x) the ball is moving in order to increment or decrement that direction
	je incrementX
	jmp decrementX
	
	incrementX:						
		cmp balls.x, 315
		jge changeDirectionX

		mov ax, ballSpeedX
		add balls.x, ax

		cmp balls.yDir, 1
		je incrementY
		jmp decrementY

	decrementX:						
		cmp balls.x, 5
		jle changeDirectionX
		
		mov ax, ballSpeedX
		sub balls.x, ax

		cmp balls.yDir, 1
		je incrementY
		jmp decrementY

	incrementY:						; increments y, also checks if ball goes out of bounds or hits paddle
		cmp balls.y, 195
		jge outOfBounds

		cmp balls.y, 190
		jl cont

		mov bx, paddleX
		cmp balls.x, bx
		jl cont

		add bx, paddleWidth
		mov cx, balls.x
		add cx, 2
		cmp cx, bx
		jle changeDirectionY

		cont:
		mov ax, ballSpeedY
		add balls.y, ax

		jmp done

	decrementY:
		cmp balls.y, 22
		jle changeDirectionY

		mov ax, ballSpeedY
		sub balls.y, ax

		jmp done

	changeDirectionX:
		neg balls.xDir
		
		cmp balls.yDir, 1
		je incrementY
		jmp decrementY

	changeDirectionY:
		neg balls.yDir
		jmp done

	changeBothDirections:
		mov ax, balls.x
		sub ax, ballSpeedX
		cmp ax, [di]
		jl invertX

		mov ax, balls.x
		add ax, ballSpeedX
		mov bx, [di]
		add bx, brickWidth
		cmp ax, bx
		jg invertX

		jmp invertY

		invertY:
			neg balls.yDir
			jmp here

		invertX: 
			neg balls.xDir
			jmp here

	outOfBounds:
		cmp lives, 0
		je exit 
		dec lives
		drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,0
		mov balls.x, 150
		mov balls.y, 185
		mov balls.xDir, 1
		mov balls.yDir, -1
		drawrect balls.lengthOfBall,balls.widthOfBall,balls.x,balls.y,15
		jmp done

	done:

	pop di							; pop all registers that were used
	pop dx
	pop cx
	pop bx
	pop ax

endm

movePaddle macro

	local left, right, done

	push ax

	mov ah, 1
	int 16h

	jz done

	mov ah, 0
	int 16h	

	cmp ah, 77
	je right
	cmp ah, 75
	je left
	cmp ah, 1
	je exit

	jmp done

	right: ;case validator in case of up key being pressed

		mov ax, paddleWidth									; if paddle is at the end of screen, don't move further
		add ax, paddleX
		cmp ax, 320
		jge done

		drawrect paddleLength,paddleWidth,paddleX,195,0		; draw black on current position
		add paddleX, 5
		drawrect paddleLength,paddleWidth,paddleX,195,9		; draw new on updated position

	jmp done

	left:

		mov ax, paddleX										; if paddle is at the end of screen, don't move further
		cmp ax, 0
		jle done

		drawrect paddleLength,paddleWidth,paddleX,195,0		; draw black on current position
		sub paddleX, 5
		drawrect paddleLength,paddleWidth,paddleX,195,9		; draw new on updated position

	jmp done

	done:
	pop ax

endm

clearScreen macro

	push ax

	mov ah, 00h
	mov al, 13h
	int 10h
	
	pop ax
	
endm

instructionsScreen macro

	local top
	clearScreen
	drawStringInitialize 13, 3
	drawString instructionsTop, 15
	drawStringInitialize 2, 9
	drawString instructions1, 14
	drawStringInitialize 2, 16
	drawString instructions2, 14
	top: 
		mov ah, 0
		int 16h
	je top
	clearScreen
	mainScreenDraw
	drawStringInitialize 14, 14
	drawString mainMenuString4, 12
	
endm

nameInput macro
	local top, mEnd

	push ax
	push dx
	push si
	
	mov si, offset username
	
	drawStringInitialize 11, 6
	drawString namePrompt, 15
	drawStringInitialize 11, 11
	
	top: ;infinite loop to take user input 
		mov ah, 0
		int 16h
		
		cmp ah, 28
		je mEnd
		
		mov [si], al
		inc si
		
		mov dl, al
		mov ah, 2
		int 21h
	jmp top
	mEnd:

	pop ax
	pop dx
	pop si
endm

highScoreMenu macro
	
	local top, displayLoop
	
	push ax
	push bx
	push cx
	push dx
	push si

	clearScreen
	
	drawStringInitialize 14, 3
	drawString highScoresText, 15
	drawStringInitialize 11, 6

	mov ah, 3dh				; 3dh opens file
	mov al, 0				; 0 is file mode for reading
	mov dx, offset f1			; moves pointer of filename to dx
	int 21h					; interrupt

	mov fileinfo, ax

	mov ah, 3fh				; 3fh reads file
	mov cx, 100				; number of bytes to read
	mov dx, offset buffer			; moves pointer of file output to dx
	mov bx, fileinfo			; bx needs file handle
	int 21h					; interrupt

	mov dx, offset buffer
	mov ah, 09h
	int 21h
	
	mov ah, 3eh 				; service to close file
	mov bx, fileinfo 			; close file with pointer name
	int 21h					; interrupt
	
	top:
		mov ah, 0
		int 16h
		cmp ah, 0
	je top
	
	pop ax
	pop bx
	pop cx
	pop dx
	pop si
	
	drawStringInitialize 14, 3
	drawString highScoresText, 15
	
	clearScreen
	mainScreenDraw
	drawStringInitialize 15, 17
	drawString mainMenuString5, 12
	
endm

main proc

	clearScreen

	nameInput

	clearScreen

	mainScreenDraw		; initialize main menu and draw all objects
	mainScreenFunction	; function to take user input for choice selection
	
	movePaddle	

main endp

exit:

mov ah, 4ch
int 21h
end