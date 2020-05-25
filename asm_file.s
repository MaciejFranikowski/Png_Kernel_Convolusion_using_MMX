.data
printf_String:
.string "Index: %d\n"
width:
.space 4
width_decl:
.space 4
width_incl:
.space 4

height:
.space 4
height_decl:
.space 4

storage:
.space 4
index:
.space 4
base_index:
.space 4
liczba1:
.space 8
jeden_and:
.space 8
drugi_and:
.space 8

.text
.global filter_MMX
.type filter_MMX, @function

filter_MMX:
# Create a new frame and store the frame pointer
pushl %ebp
movl %esp, %ebp
pushl %edi
pushl %ebx
# Get the given arguments and assign them to symbols.
# unsigned char * M, unsigned char * W, int width, int height
# 4B, 4B, 4B, 4B
movl $65535, jeden_and
movl $255, drugi_and

# Width
movl 16(%ebp), %eax
incl %eax
movl %eax, width_incl
decl %eax
movl %eax, width
decl %eax
movl %eax, width_decl
# height
movl 20(%ebp), %eax
movl %eax, height
decl %eax
movl %eax, height_decl

xorl %ecx ,%ecx
xorl %edi ,%edi

height_loop:

  cmpl %edi, height
  je height_loop_end

  xorl %ecx, %ecx
  width_loop:

    cmpl %ecx, width
    je width_loop_end

    # (edi == 0 || edi == height - 1 || ecx == 0 || ecx == width - 1)
    # dont convolute
    cmpl $0, %edi
    je convolution_skip
    # height - 1 == edi
    cmpl %edi, height_decl
    je convolution_skip
    cmpl $0, %ecx
    je convolution_skip
    # width - 1 == ecx
    cmpl %ecx, width_decl
    je convolution_skip

    movl width, %eax
    mull  %edi
    addl %ecx, %eax
    movl %eax, base_index


    movl 8(%ebp), %ebx
    addl width, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1


    incl %esi
    movl base_index, %eax
    addl width_incl, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1(%esi)

    incl %esi
    movl base_index, %eax
    addl $1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1(%esi)


    movq liczba1, %mm1

    # Liczba 2
    movl base_index, %eax
    movl width_incl, %edx
    imul $-1, %edx
    addl %edx, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1


    incl %esi
    movl base_index, %eax
    movl width, %edx
    imul $-1, %edx
    addl %edx, %eax
    # addl - width, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1(%esi)

    incl %esi
    movl base_index, %eax
    addl $-1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, liczba1(%esi)


    movq liczba1, %mm2

    # Odejmowanie mm1 = mm1 - mm2, czyli {[indeks + 801], [indeks + 800], [indeks + 1]} - {[indeks - 800][indeks - 1][indeks - 801]}
    psubusb %mm2,%mm1

    movq %mm1, %mm2
    psrlq $16, %mm2
    paddusb %mm2,%mm1
    pand drugi_and, %mm1
    movq %mm1, %mm2
    psrlq $8, %mm2
    paddusb %mm2,%mm1

    # Wynik ostateczny do edx
    movd %mm1, %edx
    # Macierz W
    movl 12(%ebp), %ebx
    movl base_index, %eax
    movb %dl, (%ebx, %eax, 1)


    convolution_skip:
    incl %ecx

    jmp width_loop
  width_loop_end:



  incl %edi

  jmp height_loop
height_loop_end:

popl %ebx
popl %edi
movl %ebp, %esp
popl %ebp
ret
