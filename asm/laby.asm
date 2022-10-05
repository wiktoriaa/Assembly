; Program gwiazdki.asm
; Wyœwietlanie znaków * w takt przerwañ zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zakoñczenie programu po naciœniêciu klawisza 'x'
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16
ASSUME CS:rozkazy

;============================================================
; procedura obs³ugi przerwania zegarowego
obsluga_klawiatury PROC
; przechowanie u¿ywanych rejestrów
push ax
push bx
push es
push cx

in al, 60H ; kod klawisza w AL

movzx bx, cs:licznik_wykryc
cmp bx, 7
je koniec

mov bx, 0

wykryj:
mov cl, cs:sekwencja[bx]
cmp al, cl
jne nie_wykryto

mov al, cs:licznik_wykryc
inc al
mov byte ptr cs:licznik_wykryc, al

mov byte ptr cs:sekwencja[bx], 0

nie_wykryto:
inc bx
cmp bx, 7
jb wykryj



koniec:
; odtworzenie rejestrów
pop cx
pop es
pop bx
pop ax
; skok do oryginalnej procedury obs³ugi przerwania zegarowego
jmp dword PTR cs:wektor9
; dane programu ze wzglêdu na specyfikê obs³ugi przerwañ
; umieszczone s¹ w segmencie kodu
licznik dw 320 ; wyœwietlanie pocz¹wszy od 2. wiersza
wektor9 dd ?
sekwencja db 30, 31, 32, 33, 36, 37, 38
licznik_wykryc db 0 ; 6 - jest sekwencja
obsluga_klawiatury ENDP
;============================================================
; program g³ówny - instalacja i deinstalacja procedury
; obs³ugi przerwañ
; ustalenie strony nr 0 dla trybu tekstowego
zacznij:
mov al, 0
mov ah, 5
int 10h
mov ax, 0
mov ds,ax ; zerowanie rejestru DS
; odczytanie zawartoœci wektora nr 8 i zapisanie go
; w zmiennej 'wektor8' (wektor nr 8 zajmuje w pamiêci 4 bajty
; pocz¹wszy od adresu fizycznego 8 * 4 = 32)
mov eax,ds:[36] ; adres fizyczny 0*16 + 32 = 32
mov cs:wektor9, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG obsluga_klawiatury ; czêœæ segmentowa adresu
mov bx, OFFSET obsluga_klawiatury ; offset adresu
cli ; zablokowanie przerwañ
; zapisanie adresu procedury do wektora nr 8
mov ds:[36], bx ; OFFSET
mov ds:[38], ax ; cz. segmentowa
sti ;odblokowanie przerwañ
; oczekiwanie na naciœniêcie klawisza 'x'
aktywne_oczekiwanie:
mov ah,1
int 16H
; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jeœli
; naciœniêto jakiœ klawisz
jz aktywne_oczekiwanie
; odczytanie kodu ASCII naciœniêtego klawisza (INT 16H, AH=0)
; do rejestru AL
mov ah, 0
int 16H

mov bh, 0
mov ah, 0ah
int 10h

mov al, cs:licznik_wykryc
cmp al, 7
je wyjdz

cmp al, 'x' ; porównanie z kodem litery 'x'
jne aktywne_oczekiwanie ; skok, gdy inny znak
; deinstalacja procedury obs³ugi przerwania zegarowego
; odtworzenie oryginalnej zawartoœci wektora nr 8
wyjdz:
mov eax, cs:wektor9
cli
mov ds:[36], eax ; przes³anie wartoœci oryginalnej
; do wektora 8 w tablicy wektorów
; przerwañ
sti
; zakoñczenie programu
mov al, 0
mov ah, 4CH
int 21H
rozkazy ENDS
nasz_stos SEGMENT stack
db 128 dup (?)
nasz_stos ENDS
END zacznij