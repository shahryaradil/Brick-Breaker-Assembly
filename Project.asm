.model small
.stack 0100h
.data

lVal dw 120
bVal dw 20
temp dw ?
count db 0

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

main proc

	mov ah, 00h
	mov al, 13h
	int 10h

	mov ah, 0ch
	mov al, 14
	mov bh, 0
	
	
	
	mov ah, 00h
	mov al, 13h
	int 10h

	mov ah, 0ch
	mov al, 14
	mov bh, 1

	drawrect 10,30,40,50,14
	drawrect 10,30,80,50,14
	drawrect 10,30,120,50,14
	drawrect 10,30,160,50,14
	drawrect 10,30,200,50,14
	drawrect 10,30,240,50,14

	drawrect 10,30,40,70,13
	drawrect 10,30,80,70,13
	drawrect 10,30,120,70,13
	drawrect 10,30,160,70,13
	drawrect 10,30,200,70,13
	drawrect 10,30,240,70,13

	drawrect 10,30,40,90,12
	drawrect 10,30,80,90,12
	drawrect 10,30,120,90,12
	drawrect 10,30,160,90,12
	drawrect 10,30,200,90,12
	drawrect 10,30,240,90,12

	drawrect 5,20,145,195,9
	

main endp

mov ah, 4ch
int 21h
end