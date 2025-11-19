section .text
global check_palindrome
global composite_palindrome
extern malloc
extern strlen
extern strcpy
extern strcat
extern free
extern strcmp

check_palindrome:
    ; create a new stack frame
    enter 0, 0

    push esi
    push edi
    push ebx

    xor eax, eax

    ;pointer la string
    mov esi, [ebp+8]
    ;len
    mov edi, [ebp+12]

    ;verific daca stringul are un singur caracter
    cmp edi, 1
    je .is_palindrome

    xor ecx, ecx
    mov ebx, edi
    ;ebx = len/2
    shr ebx, 1

.loop:
    cmp ecx, ebx
    jge .is_palindrome

    ; str[i] in al
    movzx eax, byte [esi + ecx]


    mov edx, edi
    dec edx
    ; edx = len - 1 - i
    sub edx, ecx

    ; str[len - 1 - i] in dl
    movzx edx, byte [esi + edx]

    cmp eax, edx
    jne .not_palindrome

    inc ecx
    jmp .loop

.is_palindrome:
    ;eax ia valoarea 1
    mov eax, 1
    jmp .end

.not_palindrome:
    xor eax, eax
.end:

    pop ebx
    pop edi
    pop esi
    leave
    ret

generare_combinatii:
    ; create a new stack frame
    enter 0, 0
    ;spatiu pentru variabilele locale
    sub esp, 16
    push esi
    push edi
    push ebx

    ; [ebp+8]  = sir
    ; [ebp+12] = len
    ; [ebp+16] = freq_vector
    ; [ebp+20] = curr_pos
    ; [ebp+24] = best_length_ptr
    ; [ebp+28] = best_palindrome_ptr



    ;pozitia curenta
    mov eax, [ebp+20]
    ;daca pozitia curenta este mai mare decat lungimea sirului, se termina backtracking-ul
    cmp eax, [ebp+12]
    jl .continue_backtrack

    ; daca pozitia curenta este egala cu lungimea sirului, s-a format o combinatie care
    ; a trecut prin toate elementele si a decis daca le include sau nu
    ; caluclez spatiul care trebuie alocat pt cuvintele selectate
    xor edi, edi
    xor esi, esi
    ;vectorul de frecventa
    mov ebx, [ebp+16]

    ;se caluleaza lungimea combinatiilor

.calc_length:

    ;daca contorul ajunge la lungimea vectorului, s-a trecut prin toate elementele
    cmp esi, [ebp+12]
    jge .length_done

    ;daca frecventa este 0, nu se include in combinatia curenta
    cmp byte [ebx + esi], 0
    jz .skip_string


    ;daca frecventa este 1, se include in combinatia curenta
    push esi
    ;sirul de cuvinte
    mov eax, [ebp+8]
    ; vector[i]
    push dword [eax + esi*4]
    call strlen
    ; curata stack-ul dupa apel
    add esp, 4
    ; total_length += strlen(vector[i])
    add edi, eax
    pop esi

.skip_string:
    inc esi
    jmp .calc_length

.length_done:

    ;daca lungimea este 0, nu se poate forma un palindrom
    cmp edi, 0
    jz .backtrack_return

    ;aloca spatiu pentru palindrom si pt terminatorul null
    inc edi
    push edi
    call malloc
    ;curata stack-ul dupa apel
    add esp, 4

    ;salvez la adresa locala [ebp-4] adresa alocata
    mov [ebp-4], eax
    ;intializez cu NULL
    mov byte [eax], 0


    xor esi, esi
    ;vectorul de frecventa
    mov ebx, [ebp+16]


.concatenare_cuvinte:

    ;daca contorul ajunge la lungimea vectorului, s-a trecut prin toate elementele
    cmp esi, [ebp+12]
    jge .concat_done

    ;verifica frecventa  si daca este 0, nu se include in combinatia curenta
    cmp byte [ebx + esi], 0
    jz .skip_concat

    ;daca este 1, se include in sirul alocat
    ;push pozitie_curenta
    push esi
    ;sirul de cuvinte
    mov eax, [ebp+8]
    ;push vector[i]
    push dword [eax + esi*4]
    ;push adresa locala unde este pointerul alocarii
    push dword [ebp-4]
    call strcat
    ;curata stack-ul dupa apel
    add esp, 8
    pop esi

.skip_concat:
    inc esi
    jmp .concatenare_cuvinte

.concat_done:

    ;edi=lungimea presupusului palindrom
    push dword [ebp-4]
    call strlen
    ;curata stack-ul dupa apel
    add esp, 4
    mov edi, eax

    ;verific daca este palindrom
    push edi
    ;adresa presupusului palindrom
    push dword [ebp-4]
    call check_palindrome
    ;curata stack-ul dupa apel
    add esp, 8

    ;verific daca este palindrom
    cmp eax, 0
    jz .not_palindrome

    ;daca este palindrom, verific daca este mai bun decat cel curent


    ; best_length_ptr
    mov esi, [ebp+24]
    cmp edi, [esi]
    jl .not_better
    jg .is_better

    ;daca este egal, verific lexicografic
    ; best_palindrome_ptr
    mov esi, [ebp+28]
    ;daca nu exista un palindrom anterior, il consideram mai bun
    cmp dword [esi], 0
    jz .is_better

    ;comparam lexicografic cu cel mai bun palindrom gasit pana acum
    ;stringul curent este in [ebp-4]
    mov eax, [ebp-4]
    ;best_palindrome
    mov edx, [esi]


    push edx
    push eax
    call strcmp
    mov ecx, eax
    pop edx
    pop eax
    ;verific reuzltatul comparatiei
    cmp ecx, 0
    jl .is_better
    jmp .not_better

.is_better:
    ;dau free la best_palindrome daca exista
    mov esi, [ebp+28]
    ;verific daca exista un palindrom anterior
    cmp dword [esi], 0
    jz .no_old_best
    push dword [esi]
    call free
    ;curata stack-ul dupa apel
    add esp, 4

.no_old_best:
    ;salvez noul palindrom si lungimea lui
    ; best_length_ptr
    mov esi, [ebp+24]
    mov [esi], edi
    ; best_palindrome_ptr
    mov esi, [ebp+28]
    ;pun in adresa de memorie a palindromului
    mov eax, [ebp-4]
    ; update best palindrome
    mov [esi], eax
    jmp .backtrack_return

.not_better:
.not_palindrome:
    ;dau free la palindromul presupus curent
    push dword [ebp-4]
    call free
    ;curata stack-ul dupa apel
    add esp, 4

.backtrack_return:
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret

.continue_backtrack:
    ; nu se include elementul curent ,pozitia din vectorul de frecventa ramane 0
    ; best_palindrome_ptr
    push dword [ebp+28]
    ; best_length_ptr
    push dword [ebp+24]
    ; curr_pos + 1
    mov eax, [ebp+20]
    inc eax
    push eax
    ; freq_vector
    push dword [ebp+16]
    ; len
    push dword [ebp+12]
    ; vector
    push dword [ebp+8]
    call generare_combinatii
    ;curata stack-ul dupa apel
    add esp, 24

    ;se include elementul curent, pozitia din vectorul de frecventa devine 1
    ; freq_vector
    mov eax, [ebp+16]
    ; current_pos
    mov ebx, [ebp+20]
    ; curr string
    mov byte [eax + ebx], 1

    ; best_palindrome_ptr
    push dword [ebp+28]
    ; best_length_ptr
    push dword [ebp+24]
    ; curr_pos + 1
    mov eax, [ebp+20]
    inc eax
    push eax
    ; freq_vector
    push dword [ebp+16]
    ; len
    push dword [ebp+12]
    ; vector
    push dword [ebp+8]
    call generare_combinatii
    ;curata stack-ul dupa apel
    add esp, 24

    ;se restaureaza frecventa elementului curent la 0 pt backtracking
    ; freq_vector
    mov eax, [ebp+16]
    ; current_pos
    mov ebx, [ebp+20]
    ; se seteaza frecventa la 0
    mov byte [eax + ebx], 0
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret

composite_palindrome:
    ; create a new stack frame
    enter 0, 0

    ;spatiu pentru variabilele locale
    sub esp, 24
    push esi
    push edi
    push ebx

    ; [ebp-4]  = best_length
    ; [ebp-8]  = best_palindrome
    ; [ebp-12] = freq_vector

    ; sirul
    mov eax, [ebp+8]
    ;lungimea sirului
    mov ebx, [ebp+12]

    ;best_length = 0
    mov dword [ebp-4], 0
    ;best_palindrome = NULL
    mov dword [ebp-8], 0

    ;alocare vector de frecventa
    push ebx
    call malloc
    ;curata stack-ul dupa apel
    add esp, 4


    ;in [ebp-12] se va salva adresa vectorului de frecventa
    mov [ebp-12], eax


    mov esi, eax
    xor ecx, ecx

.initializare_vector:
    cmp ecx, ebx
    jge .vector_initializat
    ;vectorul de frecventa se initializeaza cu 0
    mov byte [esi + ecx], 0
    inc ecx
    jmp .initializare_vector

.vector_initializat:
    ; Start backtracking
    ; adresa best_palindrome
    lea eax, [ebp-8]
    push eax
    ; adresa best_length
    lea eax, [ebp-4]
    push eax
    ; poz_curent = 0
    push 0
    ; freq_vector
    push dword [ebp-12]
    push ebx
    ; sirul de cuvinte
    push dword [ebp+8]
    call generare_combinatii
    ; curata stack-ul dupa apel
    add esp, 24

    ; dezalocare vector de frecventa
    push dword [ebp-12]
    call free
    ; curata stack-ul dupa apel
    add esp, 4

    ;adresa palindromului gasit
    mov eax, [ebp-8]



    pop ebx
    pop edi
    pop esi
    leave
    ret
