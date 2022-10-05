.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC 
public _main

.data
inputText db 100 dup (?)
infoText db 'Wpisz znaki: ', 0
caesarOffset db 15

.code

_main PROC
push 13
push OFFSET infoText
push 1
call __write
add esp, 12

push 100
push OFFSET inputText
push 0
call __read
add esp, 12

mov ecx, eax ; liczba znaków
dec ecx
xor edx, edx ; edx- current index
xor ebx, ebx ; clean

;32 - 125
caesar:
mov bl, inputText[edx]

add bl, caesarOffset
cmp bl, 125
jb good
sub bl, 125
add bl, 32
good:

mov inputText[edx], bl

inc edx
loop caesar

push edx
push OFFSET inputText
push 1
call __write
add esp, 12

push 0
call _ExitProcess@4
_main ENDP

END