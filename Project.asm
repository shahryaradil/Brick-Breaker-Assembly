include Brick.inc
.model small
.stack 0100h
.data

brickLength dw 10
brickWidth dw 30
brickStartX dw 40
brickStartY dw 50
paddleLength dw 5
paddleWidth dw 20
paddleX dw 145
temp dw ?
count db 0
mainMenuString1 db "BRICK BREAKER GAME"
mainMenuString2 db "New Game"
mainMenuString3 db "Resume"
mainMenuString4 db "Instructions"
mainMenuString5 db "High Score"
mainMenuString6 db "Exit"
defaultSelect db 1

bricks Brick 18 dup (<?,?,10,30,1,1,14>)
brick1 Brick <?,?,10,30,1,1,14>

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

mainScreenFunction macro
	
	local top, up, down, label1, label2, label3, label4, label5, select, startGame
	
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
		je startGame
		cmp defaultSelect, 5
		je exit
	jmp top

	startGame:
		pageUpdate 1 ; startGame func to be added ;
		drawGame 3,6

endm

drawGame macro rows, cols, paddleCol

	local startBrickDrawOuter, startBrickDrawInner, contLoop	; set labels as local to avoid redefinition error

	push cx							; push all registers to be used
	push si
	push ax
	push dx
	push bx

	mov ah,0
	mov al,13h
	int 10h

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
			jne contLoop			; only draw active bricks

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

	drawrect paddleLength,paddleWidth,paddleX,195,9

	pop bx							; pop all registers that were used
	pop dx
	pop ax
	pop si
	pop cx

endm

movePaddle macro

	top: ;infinite loop to take user input 
		mov ah, 0
		int 16h
		cmp ah, 77
		je up
		cmp ah, 75
		je down
		cmp ah, 1
		je exit
	jmp top
	jz top

	up: ;case validator in case of up key being pressed
		add paddleX, 5
		drawGame 3, 6
	jmp top

	down:
		sub paddleX, 5
		drawGame 3, 6
	jmp top

endm

main proc

	pageUpdate 0 ;page number for main menu

	mainScreenDraw ;initialize main menu and draw all objects
	mainScreenFunction ;function to take user input for choice selection
	
	movePaddle	

main endp

exit:

mov ah, 4ch
int 21h
end