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

base_index:
.space 4
number_storage:
.space 8
and_number:
.space 8

scaling:
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
movl $65535, and_number
movl $765, scaling
# Get the given arguments and assign them to symbols.
# unsigned char * M, unsigned char * W, int width, int height
# 4B, 4B, 4B, 4B

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
    movl %eax, base_index

    # Get the M adress, save it ebx.
    movl 8(%ebp), %ebx

    # Calculate the index of the cell under the middle cell.
    addl width, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    # Send the cell's contents to number_storage.
    movb %dl, number_storage


    incl %esi
    incl %esi
    movl base_index, %eax
    addl width_incl, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    # Do the same for the remaining numbers, sending them to number_storage
    # on neighbouring word (leave a bit of space between).
    incl %esi
    incl %esi
    movl base_index, %eax
    addl $1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    # Load the first "number" we created into mm1
    movq number_storage, %mm1

    # Upper numbers that should get multiplied *-1
    movl base_index, %eax
    movl width_incl, %edx
    imul $-1, %edx
    addl %edx, %eax
    xorl %esi, %esi
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage


    incl %esi
    incl %esi
    movl base_index, %eax
    movl width, %edx
    imul $-1, %edx
    addl %edx, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    incl %esi
    incl %esi
    movl base_index, %eax
    addl $-1, %eax
    movb (%ebx, %eax, 1), %dl
    movb %dl, number_storage(%esi)

    # Load the second "number" we created into mm2
    movq number_storage, %mm2



    # Subraction mm1 = mm1 - mm2  which is essentialy:
    # {[index + width], [index + width + 1], [index + 1]} MINUS
    # {[index - width][index - 1][index - width - 1]}
    #
    # This way we avoid any multiplication and make the number of
    # calculations smaller.
    psubsw %mm2,%mm1

    # Copy the result of the subtraction.
    movq %mm1, %mm2
    # Shift the result 32 bits to the right, to get the third result.
    psrlq $32, %mm2
    # Add the numbers, now we've got just 2 operands left.
    paddsw %mm2,%mm1
    # Make sure the third operand is gone.
    pand and_number, %mm1
    # Copy the operand to mm1
    movq %mm1, %mm2
    # Shift right by 16 bits.
    psrlq $16, %mm2
    # Add, now we've got the result.
    paddsw %mm2,%mm1

    # Move the number we're scaling by to mm2
    movl scaling, %edx
    movd %edx, %mm2
    # Add the number.
    paddsw %mm2,%mm1
    # Divide by 8.
    psrlq $3, %mm1

    # Final result moved to %edx.
    movd %mm1, %edx
    # Move the result to W array.
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

popl %esi
popl %ebx
popl %edi
movl %ebp, %esp
popl %ebp
ret
