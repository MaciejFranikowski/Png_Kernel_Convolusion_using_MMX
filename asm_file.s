.data

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

current_index:
.space 4

number_storage:
.space 8

and_number:
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
pushl %esi

# Preprare the number used for and later in the algoryithm. 1111 1111
movl $255, and_number
# Get the given arguments and assign them to symbols.
# unsigned char * M, unsigned char * W, int width, int height.
# 4B, 4B, 4B, 4B
# Width
movl 16(%ebp), %eax
incl %eax
movl %eax, width_incl
decl %eax
movl %eax, width
decl %eax
movl %eax, width_decl
# Height
movl 20(%ebp), %eax
movl %eax, height
decl %eax
movl %eax, height_decl

xorl %ecx ,%ecx
xorl %edi ,%edi

# Loop eqivalent to:   for(edi = 0; edi < height; edi ++)
height_loop:

  cmpl %edi, height
  je height_loop_end

  xorl %ecx, %ecx
  # Loop eqivalent to:   for(ecx = 0; ecx < width; ecx ++)
  width_loop:

    cmpl %ecx, width
    je width_loop_end

    # Making sure we're skipping outer rows and columns.
    # (edi == 0 || edi == height - 1 || ecx == 0 || ecx == width - 1)
    # If any of these conditions is true, don't covolute.
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

    # Calcuating current index- the middle cell of the 3x3 matrix.
    # The index is calculated: width * height_counter(edi) + width_counter(ecx)
    # This is because of the nature of the M array, which is row ordered.
    movl width, %eax
    mull  %edi
    addl %ecx, %eax
    movl %eax, current_index

    # Get the M adress, save it ebx.
    movl 8(%ebp), %ebx

    # Calculate the index of the cell under the middle cell.
    addl width, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    # Send the cell's contents to number_storage.
    movb %dl, number_storage

    # Do the same for the remaining numbers, sending them to number_storage
    # on neighbooring
    incl %esi
    movl current_index, %eax
    addl width_incl, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    incl %esi
    movl current_index, %eax
    addl $1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)


    movq number_storage, %mm1

    # Liczba 2
    movl current_index, %eax
    movl width_incl, %edx
    imul $-1, %edx
    addl %edx, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage


    incl %esi
    movl current_index, %eax
    movl width, %edx
    imul $-1, %edx
    addl %edx, %eax
    # addl - width, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    incl %esi
    movl current_index, %eax
    addl $-1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)


    movq number_storage, %mm2

    # Odejmowanie mm1 = mm1 - mm2, czyli {[indeks + 801], [indeks + 800], [indeks + 1]} - {[indeks - 800][indeks - 1][indeks - 801]}
    psubusb %mm2,%mm1

    movq %mm1, %mm2
    psrlq $16, %mm2
    paddusb %mm2,%mm1
    pand and_number, %mm1
    movq %mm1, %mm2
    psrlq $8, %mm2
    paddusb %mm2,%mm1

    # Wynik ostateczny do edx
    movd %mm1, %edx
    # Macierz W
    movl 12(%ebp), %ebx
    movl current_index, %eax
    movb %dl, (%ebx, %eax, 1)


    convolution_skip:
    incl %ecx

    jmp width_loop
  width_loop_end:



  incl %edi

  jmp height_loop
height_loop_end:

# Restore register values and the frame pointer, according to ABI.
popl %esi
popl %ebx
popl %edi
movl %ebp, %esp
popl %ebp
ret
