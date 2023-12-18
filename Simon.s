.data

promptA: .string "Want to play again? '1' for yes, '0' for no! \n"

promptB: .string "Invalid input \n"

promptC: .string "Level: "

promptD: .string "You can start entering your answer. \n"

promptE: .string "You Won! \n"

promptF: .string "You Lost :( \n"

newline: .string "\n"

count:     .word 3

level: .word 0

sequence: .byte 0,0,0,0

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    
    lw s2, count #s2 always stores the length of the sequence
    lw s7, level #s7 always stores the current level
    
    InitExit:
        
    addi s2, s2, 1 #length of the sequence
    
    li s4, 8 #There are 8 different speed levels, the fastest speed is 150ms between delays
    beq s7, s4, maxLevel #There is a cap at 8, because if the delay is not long enough
    #the buttons don't appear.
    
    addi s7, s7, 1 #the level starts from 1, increases by 1 in each successful round
 
    
    maxLevel:
        
    li s0, 1 #This value is set to 1 at the beginning, if the user fails the game, the value of s0
    #is changed to 0 so that the difficulty doesn't increase, the game is just started from maxLevel
    
    la a0, promptC 
    li a7, 4 #System command to print Level:
    ecall
    
    
    mv a0, s2
    addi a0, a0, -3
    li a7, 1 	# system call code for printing integer
	ecall 	# print the level

    li a7, 4 	# system call code for print_string
	la a0, newline 	# address of string to print
	ecall 	# print the string

    
    la t6, sequence # t6 holds the address of the sequence
    mv a6, s2 #loop guard for generating as many randomized numbers. 
    lw a0, count #a0 is set to 4 because there are only 4 LED lights
    WHILE:
    beq a6, x0, DONE 
    addi a6, a6, -1
    jal rand
    #li a7, 1	# system call code for print         DEBUGGER
	#ecall 	# print                                   DEBUGGER
    sb a0, 0(t6) #Randomized numbers are stored in the sequence
    addi t6, t6, 1 #the location in the array is changed
    lw a0, count #a0 is updated before each function call
    j WHILE     
    DONE:
     
    #This part of the code is to point at the beginning of the sequence    
    sub t6, t6, s2
 
    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    
    #lw s5, level    # s5 refers to the current level of the game
    #lw s6, speed    # s6 refers to the speed of the game
    #beq s5, zero, skip # If the level is zero, skip the speed reduction

    # Calculate the new speed based on the current level
    #li t0, 50       # Load the initial speed reduction (50)
    #mul t0, t0, s5  # Multiply the initial reduction by the current level
    #sub s6, s6, t0  # Subtract the speed reduction from the current speed
    
    #Each successful game, the delay decreases by 50ms
    li s6, 50       # Load the initial speed reduction (50)
    mul s6, s6, s7  # Multiply the initial reduction by the current level
 
 
    li s8, 1 #To check the randomized numbers
    li s9, 2
    li s10, 3
    
    li s11, -1

    mv a5, s2 #a5 is set as the loopguard, which is the length of the sequence. In other words,
    #If there are n elements in the sequence, the LEDs have to light up for n times in total.
    
    li a0, 2000 #If the program starts so fast, the user shouldn't miss the first light
    jal delay
    
    loop:
    beq a5, x0, done
    addi a5, a5, -1
    lb a0, 0(t6)
    addi t6, t6, 1
    #li a7, 1                            DEBUGGER
    #ecall                                DEBUGGER
    beq a0, x0, case0
    beq a0, s8, case1
    beq a0, s9, case2
    beq a0, s10, case3
    j case_other #Just to check if an issue happens with the random generator
    case0:
        # If a0 equals 0
        li a0, 0xFF0000 # Red color
        li a1, 0
        li a2, 0
        
        jal setLED
              
        li a0, 550
        sub a0, a0, s6
        
        jal delay
        
        li a0, 0x000000
        li a1, 0
        li a2, 0
        jal setLED
        beq a5, s11, WHILE2 #This is when a5 and s11 are both -1, which is related in line 219-222
        j doneif
    case1:
        # If a0 equals 1
        li a0, 0x00FF00 #Green color
        li a1, 1
        li a2, 0
        jal setLED
        li a0, 550
        sub a0, a0, s6
        jal delay
        li a0, 0x000000
        li a1, 1
        li a2, 0
        jal setLED
        beq a5, s11, WHILE2
        j doneif
    case2:
        # If a0 equals 2
        li a0, 0xFFFF00 # Yellow color
        li a1, 0
        li a2, 1
        jal setLED
        li a0, 550
        sub a0, a0, s6
        jal delay
        li a0, 0x000000
        li a1, 0
        li a2, 1
        jal setLED
        beq a5, s11, WHILE2
        j doneif
    case3:
        # If a0 equals 3
        li a0, 0x0000FF # Blue color
        li a1, 1
        li a2, 1
        jal setLED
        li a0, 550
        sub a0, a0, s6
        jal delay
        li a0, 0x000000
        li a1, 1
        li a2, 1
        jal setLED
        beq a5, s11, WHILE2
        j doneif
    case_other:
        # when a0 does not equal 0, 1, 2, or 3
        j doneif
    doneif:
        li a0, 1000
        sub a0, a0, s6
        sub a0, a0, s6
        jal delay
    j loop
    done:    
    
    sub t6, t6, s2
             
    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    
    #This shows that the user can start entering the inputs    
    la a0, promptD
    li a7, 4 #System command to print Level:
    ecall
   
    
    mv a6, s2
    li a5, -1 #Essentially, this is a boolean variable that assigns the value of -1 to a5. 
    #When a5 is equal to -1 and the code reaches #case0, case1..., the remaining code will not be 
    #executed to prevent any disturbance to the position of the sequence that is currently being referred to. 
   
    WHILE2:
    lb a4, 0(t6)
    jal pollDpad
    bne a4, a0, FAIL
    
    addi t6, t6, 1
    addi a6, a6, -1
    beq a6, x0, SUCCESS
    beq a0, x0, case0 #Each time the user enters an input, that LED is lighten up.
    beq a0, s8, case1
    beq a0, s9, case2
    beq a0, s10, case3
    
    j WHILE2
       
SUCCESS:
     
        li a0, 500
        jal delay
        
        li a0, 0x00FF00 #Green color
        li a1, 0
        li a2, 0
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0x00FF00 #Green color
        li a1, 0
        li a2, 1
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0x00FF00 #Green color
        li a1, 1
        li a2, 0
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0x00FF00 #Green color
        li a1, 1
        li a2, 1
        jal setLED
        
        li a0, 500
        jal delay
        
        la a0, promptE
        li a7, 4
        ecall
        
        j reset
     
FAIL:   
        li s0, 0 #This is the indicator that the user failed the game, so that if they want to restart
        #the game, the difficulty stays the same  
        
        
        li a0, 500
        jal delay
        li a0, 0xFF0000 # Red color
        li a1, 0
        li a2, 0
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0xFF0000 # Red color
        li a1, 0
        li a2, 1
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0xFF0000 # Red color
        li a1, 1
        li a2, 0
        jal setLED
        
        li a0, 500
        jal delay
        
        li a0, 0xFF0000 # Red color
        li a1, 1
        li a2, 1
        jal setLED 
        
        li a0, 500
        jal delay
        
        la a0, promptF
        li a7, 4
        ecall
        
        j reset
        
    reset:
        li a0, 0x000000
        li a1, 0
        li a2, 0
        jal setLED
        
        li a0, 0x000000
        li a1, 0
        li a2, 1
        jal setLED
        
        li a0, 0x000000
        li a1, 1
        li a2, 0
        jal setLED
        
        li a0, 0x000000
        li a1, 1
        li a2, 1
        jal setLED
        j end2
        
 end2:
    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
    la a0, promptA 
    li a7, 4
    ecall
    
    call readInt
	mv t0, a0
 
    li s8, 1 #s8 is assigned to 1 to check if the user wants to play again
    
    beq t0, s8, DifficultySettings  # If the user wants to play again
    #However if they are stuck on one difficulty, the pattern size and the speed stays the same
    beq t0, x0, exit  # If the game ends
    
    #If invalid input is given
    la a0, promptB
    li a7, 4
    ecall
    j end2
    
DifficultySettings:
    beq s0, x0, maxLevel #This happens if the user failed the game
    beq s0, s8, InitExit #If the user has passed the level, the difficulty increases
    
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall
    
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra
