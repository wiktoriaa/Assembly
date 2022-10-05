.686
.model flat
extern _ExitProcess@4 : PROC
extern _MessageBoxW@16 : PROC
public _main

.data
tytul dw 'o','k','n','o',0
tekst db "edhsba", 0b3h, "ab", 0e6h, "a", 0b3h, "a", 0 ;12
output dw 11 dup (0)

.code
_main PROC

mov ecx, 11
mov edx, 0
mov esi, 0
xor eax, eax
mov eax, OFFSET tekst

petla:
xor ebx, ebx
mov bl, [eax + edx]

cmp bl, "a"
jne skok
mov bl, [eax + edx + 1]
cmp bl, 0b3h
jne skok
mov bl, [eax + edx + 2]
cmp bl, "a"
jne skok
add edx, 3
mov output[esi], 2691h
add esi, 2
jmp koniec

skok:
mov bl, [eax + edx]
;polskie znaki
cmp bl, 0b1h
jne dalej1
mov bx, 0105h
dalej1:
cmp bl, 0e6h
jne dalej2
mov bx, 0107h
dalej2:
cmp bl, 0eah
jne dalej3
mov bx, 0119h
dalej3:
cmp bl, 0b3h
jne dalej
mov bx, 0142h

dalej:
mov output[esi], bx
add esi, 2
inc edx
koniec:
loop petla

mov ecx, 11
mov edx, 2
mov eax, OFFSET output

push 0 
push OFFSET tytul
push OFFSET output
push 0
call _MessageBoxW@16


push 0
call _ExitProcess@4
_main ENDP
END
