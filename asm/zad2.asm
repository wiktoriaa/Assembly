.386
rozkazy SEGMENT use16
ASSUME CS : rozkazy
obsluga_klawiatury PROC
push ax
push bx
push es

in al, 60H
cmp al, 45
jne koniec_procedury

mov al, 1
mov byte PTR cs:klawisz_wyjscia, al

koniec_procedury:
pop es
pop bx
pop ax

jmp dword PTR cs:wektor9

klawisz_wyjscia db 0
wektor9 dd ?
obsluga_klawiatury ENDP
;============================================================
; procedura obs³ugi przerwania zegarowego
obsluga_zegara PROC
; przechowanie u¿ywanych rejestrów
push ax
push bx
push es

mov al, cs:licznik_przerwan
cmp al, 120
je nie_inkrementuj

inc al
mov byte PTR cs:licznik_przerwan, al

nie_inkrementuj:

; wpisanie adresu pamiêci ekranu do rejestru ES - pamiêæ
; ekranu dla trybu tekstowego zaczyna siê od adresu B8000H,
; jednak do rejestru ES wpisujemy wartoœæ B800H,
; bo w trakcie obliczenia adresu procesor ka¿dorazowo mno¿y
; zawartoœæ rejestru ES przez 16
mov ax, 0B800h ;adres pamiêci ekranu
mov es, ax
; zmienna 'licznik' zawiera adres bie¿¹cy w pamiêci ekranu
mov bx, cs:licznik
; przes³anie do pamiêci ekranu kodu ASCII wyœwietlanego znaku
; i kodu koloru: bia³y na czarnym tle (do nastêpnego bajtu)
mov byte PTR es:[bx], '*' ; kod ASCII
mov byte PTR es:[bx+1], 00000111B ; kolor
; zwiêkszenie o 2 adresu bie¿¹cego w pamiêci ekranu
add bx,2
; sprawdzenie czy adres bie¿¹cy osi¹gn¹³ koniec pamiêci ekranu
cmp bx,4000
jb wysw_dalej ; skok gdy nie koniec ekranu
; wyzerowanie adresu bie¿¹cego, gdy ca³y ekran zapisany
mov bx, 0
;zapisanie adresu bie¿¹cego do zmiennej 'licznik'
wysw_dalej:
mov cs:licznik,bx
; odtworzenie rejestrów
pop es
pop bx
pop ax
; skok do oryginalnej procedury obs³ugi przerwania zegarowego
jmp dword PTR cs:wektor8
; dane programu ze wzglêdu na specyfikê obs³ugi przerwañ
; umieszczone s¹ w segmencie kodu
licznik dw 320 ; wyœwietlanie pocz¹wszy od 2. wiersza
wektor8 dd ?
licznik_przerwan db 0
obsluga_zegara ENDP
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
mov eax,ds:[32] ; adres fizyczny 0*16 + 32 = 32
mov cs:wektor8, eax

mov eax,ds:[36] 
mov cs:wektor9, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG obsluga_zegara ; czêœæ segmentowa adresu
mov bx, OFFSET obsluga_zegara ; offset adresu
cli ; zablokowanie przerwañ
; zapisanie adresu procedury do wektora nr 8
mov ds:[32], bx ; OFFSET
mov ds:[34], ax ; cz. segmentowa
sti ;odblokowanie przerwañ

mov ax, SEG obsluga_klawiatury ; czêœæ segmentowa adresu
mov bx, OFFSET obsluga_klawiatury ; offset adresu
cli ; zablokowanie przerwañ
; zapisanie adresu procedury do wektora nr 8
mov ds:[36], bx ; OFFSET
mov ds:[38], ax ; cz. segmentowa
sti ;odblokowanie przerwañ

; oczekiwanie na naciœniêcie klawisza 'x'
aktywne_oczekiwanie:
;mov ah,1
;int 16H
; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jeœli
; naciœniêto jakiœ klawisz
;jz aktywne_oczekiwanie
; odczytanie kodu ASCII naciœniêtego klawisza (INT 16H, AH=0)
; do rejestru AL
;mov ah, 0
;int 16H
;cmp al, 'x' 
mov al, cs:klawisz_wyjscia
cmp al, 1
je zakoncz

mov al, cs:licznik_przerwan
cmp al, 120
jb aktywne_oczekiwanie 

zakoncz:
mov eax, cs:wektor8
cli
mov ds:[32], eax ; przes³anie wartoœci oryginalnej
sti

mov eax, cs:wektor9
cli
mov ds:[36], eax ; przes³anie wartoœci oryginalnej
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