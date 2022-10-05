.686
.model flat

extern		_ExitProcess@4	: PROC
extern		_MessageBoxW@16	: PROC
public _main

.data
slowa		  dw 'D','i','l','u','c'
			  dw ' '
			  dw 's','p','r','z','e','d','a','j','e'
			  dw ' '
			  dw 'w', 'i', 'n', 'o'
koniec_slow	  dw 0

output		  dw 21 dup (0)

.code

_main PROC

xor ebx, ebx ; indeks pocz¹tku wyrazu
xor edx, edx ; indeks koñca wyrazu
mov ecx, 3

xor eax, eax

szukaj:
mov ax, [slowa + edx]
inc edx
cmp ax, ' '
jne szukaj
mov eax, OFFSET slowa
add eax, ebx
;dec eax
push eax
mov ebx, edx
loop szukaj

xor ebx, ebx
pop eax

mov ecx, 3
mov edx, 0

;pierwszy bajt
mov bx, [eax]
mov bl, bh
mov output[edx], bx
mov edx, 1
add eax, 2

pierwszy:
mov bx, [eax]
mov output[edx], bx
add eax, 2
add edx, 2
loop pierwszy

add edx, 1
mov output[edx], ' '
add edx, 1

pop eax
mov ecx, 9

drugi:
mov bx, [eax]
mov output[edx], bx
add eax, 2
add edx, 2
loop drugi

add edx, 1
mov output[edx], ' '
add edx, 2

pop eax
mov ecx, 5

trzeci:
mov bx, [eax]
mov output[edx], bx
add eax, 2
add edx, 2
loop trzeci

push    0
push    OFFSET slowa
push    OFFSET output
push    0
call    _MessageBoxW@16

push 0
call _ExitProcess@4

_main ENDP
END