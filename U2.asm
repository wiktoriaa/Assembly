.686
.model flat
extern __write : PROC
extern _ExitProcess@4 : PROC
public _main

.data
; deklaracja tablicy 12-bajtowej do przechowywania
; tworzonych cyfr
znaki db 12 dup (?)

.code 

wyswietl_EAX PROC
; sprawdzenie znaku
test eax, eax
js signed
jmp next
xor edi, edi

signed:
neg eax
mov edi, 1

next:
mov esi, 10 ; indeks w tablicy 'znaki'
mov ebx, 10 ; dzielnik równy 10
konwersja:
mov edx, 0 ; zerowanie starszej czêœci dzielnej
div ebx ; dzielenie przez 10, reszta w EDX,
; iloraz w EAX
add dl, 30H ; zamiana reszty z dzielenia na kod
; ASCII
mov znaki [esi], dl; zapisanie cyfry w kodzie ASCII
dec esi ; zmniejszenie indeksu
cmp eax, 0 ; sprawdzenie czy iloraz = 0
jne konwersja ; skok, gdy iloraz niezerowy
; wype³nienie pozosta³ych bajtów spacjami i wpisanie
; znaków nowego wiersza
wypeln:

sub edi, 1
jz write_sign
jmp no_sign

write_sign:
mov byte PTR znaki [esi], '-' ; znak
dec esi
no_sign:

or esi, esi
jz wyswietl ; skok, gdy ESI = 0
mov byte PTR znaki [esi], 20H ; kod spacji
dec esi ; zmniejszenie indeksu
jmp wypeln

wyswietl:
mov byte PTR znaki [0], 0AH ; kod nowego wiersza
mov byte PTR znaki [11], 0AH ; kod nowego wiersza
; wyœwietlenie cyfr na ekranie
push dword PTR 12 ; liczba wyœwietlanych znaków
push dword PTR OFFSET znaki ; adres wyœw. obszaru
push dword PTR 1; numer urz¹dzenia (ekran ma numer 1)
call __write ; wyœwietlenie liczby na ekranie
add esp, 12 ; usuniêcie parametrów ze stosu
ret
wyswietl_EAX ENDP

_main PROC
mov ebx, 0 ; n = 1..10
mov esi, 0 ; 1- odejmowanie, 0 - dodawanie

mov eax, 1 ; pierwszy element ci¹gu

wypisz_ciag:
cmp esi, 1

je odejmowanie
add eax, ebx
mov esi, 1
jmp dalej

odejmowanie:
sub eax, ebx
xor esi, esi

dalej:
push ebx
push eax
push esi
call wyswietl_EAX
pop esi
pop eax
pop ebx

inc ebx
cmp ebx, 30
jbe wypisz_ciag

push 0
call _ExitProcess@4
_main ENDP

END