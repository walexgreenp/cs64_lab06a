.data
# DO NOT CHANGE
buffer: .word 0:100
array: .word 9 1 2 1 17 19 10 9 11 10
newline: .asciiz "\n"
comma: .asciiz ", "
convention: .asciiz "Convention Check\n"
depth: .asciiz "depth "
colon: .asciiz ":"

.text
    main:
        la $a0 array # the input array
        li $a1 2 # depth: number of times you need to split an array
        la $a2 buffer # the buffer array address
        li $a3 10 # array length        
        move $s0, $a0
        move $s1, $a1
        move $s2, $a2
        move $s3, $a3
        ori $s4, $0, 0
        ori $s5, $0, 0

        jal disaggregate

        j exit
    
    disaggregate:
        addiu $sp, $sp, -28 # ?? = the negative of how many values we store in (stack * 4)
        
        # store all required values that need to be preserved across function calls

        sw $s0 0($sp)   # store array address on stack
        sw $s1 4($sp)   # store n on stack (DEPTH)
        sw $s2 8($sp)   # store buffer pointer on stack
        sw $s3 12($sp)  # store length of array on stack

        # Since our array_len parameter becomes small/big array len
        # We need them to be what they were before the next recursive call!

        sw $s4 16($sp)  # store small array length on stack
        sw $s5 20($sp)  # store big array length on stack
        
        # multiple function calls overwrite ra, therefore must be preserved
        sw $ra 24($sp)  # store return address

        # print depth value, according to expected format
        la $a0, depth    
        li $v0, 4
        syscall
        li $v0, 1
        move $a0, $s1
        syscall
        la $a0, colon    
        li $v0, 4
        syscall
        
        # Don't forget to define your variables!

        # It's dangerous to go alone, take this one loop for free
        # please enjoy and use carefully
        # this code makes no assumptions on your code
        # fix this code to work with yours or vice versa
        # don't have to use this loop either can make your own too

        move $t0 $s0    # Moving array into $t0
        li $t2 0    # Setting $t2 to be sum of variables
        li $t7 1    # Setting $t7 to be 'i' variable

        loop:
            # find sum
            bgt $t7, $s3, func_check # this is the loop exit condition
            lw $t6, 0($t0)
            
            # print array entry
            li $v0, 1
            move $a0, $t6
            syscall
            li $v0, 4
            la $a0, comma
            syscall
            
            addi $t0, $t0, 4
            addi $t7, $t7, 1
            add $t2, $t2, $t6
            j loop

        func_check:
            # Add the recursive function end condition
            # Needs to exist so that we don't end up recursing to infinity!
            # This is the recursive equivalent to our iteration condition
            # for example the i < 10 in a for/while loop
            # We have two recursive conditions: depth == 0, arr_len == 1
            # They are OR'd in the C/C++ template
            # Do you need to OR them in MIPs too? 
            
            beq $s1 $zero function_end # $s1 = depth
            li $t4 1    # t4 = 1
            beq $s3 $t4 function_end    # $s3 = arr_len

        # calculate the average 
        div $t2, $s3 # what register do we divide by? 
        mflo $t3 # avg 




        # This is the main loop, not for free :/
        move $t0 $s0    # Putting array into $t0

        li $t4 0    # $t4 = j
        li $t5 0    # $t5 = k

        li $t7 0    # Setting $t7 to be 'i' variable
        li $s4 0    # Setting actual array lenth small
        li $s5 0    # Setting actual array lenth small

        move $t2 $s2    # Smaller array $t2
        addiu $t6 $t2 40    # Bigger array $t6

        loop2:
            # find big and small array
            # Remember the conditions for splitting
            bge $t7 $s3 closing

            lw $t1 0($t0)

            ble $t1 $t3 ltaverage

            j gtaverage

            # entry <= average put in small array
            ltaverage:
                sw $t1 0($t2)
                addiu $t2 $t2 4
                addi $s4 $s4 1

                j increment

            # entry > average put in big array
            gtaverage:
                sw $t1 0($t6)
                addiu $t6 $t6 4
                addi $s5 $s5 1

                j increment

            increment:
                addiu $t0 $t0 4
                addi $t7, $t7, 1
                j loop2

        closing:
        # This is the section where we prepare to call the function recursively.
        
            # move $s4, $t6 # save the small array length value 
            # move $s5, $t2 # save the big array length value

            jal ConventionCheck # DO NOT REMOVE 

            # Make sure your $s registers have the correct values before calling
            # Remember we recursively call with small array first
            # So load small array arguments in $s registers
            addi $s1 $s1 -1
            # addi $t0 $t0 -40

            move $s0 $s2

            # This is updating the buffer so that we don't overwrite our old values
            addi $s2, $s2, 80
            move $s3, $s4   # s4 is length of smaller
            
            jal disaggregate

            jal ConventionCheck # DO NOT REMOVE
            




            # Similarly for big array, we mirror the call structure of small array as above
            # But with the values appropriate for big array. 
            addiu $s0 $s0 40

            addi $s2, $s2, 80
            move $s3, $s5 # s5 is length of bigger
            
            jal disaggregate

            j function_end
        
        function_end:
        # Here we reset our values from previous iterations
        # Be careful on which values you load before and after the $sp update if you have to 
        # We can accidentally end up loading values of current calls instead of previous calls
        # Manually drawing out the stack changes helps figure this step out
            
            lw $s0 0($sp)
            lw $s1 4($sp)
            lw $s2 8($sp)
            lw $s3 12($sp)
            lw $s4 16($sp)
            lw $s5 20($sp)
            lw $ra 24($sp)  # Load values before update if you have to
            addiu $sp, $sp, 28 # ?? = the positive of how many values we store in (stack * 4)
            jr $ra
    
    exit:
        li $v0, 10
        syscall

ConventionCheck:  
# DO NOT CHANGE AUTOGRADER USES THIS  
    # reset all temporary values
    addi    $t0, $0, -1
    addi    $t1, $0, -1
    addi    $t2, $0, -1
    addi    $t3, $0, -1
    addi    $t4, $0, -1
    addi    $t5, $0, -1
    addi    $t6, $0, -1
    addi    $t7, $0, -1
    ori     $v0, $0, 4
    la      $a0, convention
    syscall
    addi    $v0, $zero, -1
    addi    $v1, $zero, -1
    addi    $a0, $zero, -1
    addi    $a1, $zero, -1
    addi    $a2, $zero, -1
    addi    $a3, $zero, -1
    addi    $k0, $zero, -1
    addi    $k1, $zero, -1
    jr      $ra
