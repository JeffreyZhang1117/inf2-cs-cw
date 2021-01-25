
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
dictionary_idx:		.space 1000
space:                  .asciiz " "
count0:                 .asciiz "-1\n"
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
                               
   
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

  


     li $t0,0 #idx = 0
     li $t1,0 #dict_idx = 0
     li $t2,0 #start_idx = 0
     li $t3,0 #c_input
     li $t4,0 #dict_num_words
     
     
     
   
   do: 
     lb   $t3,dictionary($t0)   # c_input = dictionary[idx]
     beq $t3,$0, BREAK            # c_input == '\0
     bne  $t3, 10, ADD        # c_input == '\n'
     sb   $t2,dictionary_idx($t1)
     addi $t1,$t1,1
     addi $t2,$t0,1
   

  ADD:
   addi $t0,$t0,1      #idx ++
   j do
   
   BREAK:
   

   
     
   
   STRFIND:
   li $t5,0  #grid_idx
   li $t9,0  #count = 0
   li $t0,0  #idx = 0
   
  
   while_loop:
   lb   $t6, grid($t5)               #$t6 = grid[grid_idx]   
   beq  $t6,$0, END_WHILE           #while (grid[grid_idx] != '\0')
    
   for_loop:
   beq $t0,$t1, LEFTFOR            #idx < dict_num_words
   lb  $t7,dictionary_idx($t0)     #$t7 = dictionary_idx[idx]
   la  $s0,dictionary              
   add $s0,$s0,$t7                  #s0 word= dictionary + dictionary_idx[idx]
   la  $s1,grid
   add $s1,$s1,$t5                #string  grid + grid[idx]
   addi $s2,$s0,0                  #word(contain)
   jal CONTAIN
   beqz $s4, lable2
   li $v0 , 1
   move $a0,$t5
   syscall
   li $v0,4
   la $a0, space
   syscall
   jal PRINT_WORD
   li $v0,4
   la $a0,newline
   syscall
   addi $t9,$t9,1
   lable2:
   addi $t0,$t0,1   #idx ++
   j for_loop
   
   
   
  LEFTFOR:
   addi $t5,$t5,1
   li $t0,0
   j while_loop
   
  END_WHILE:
    beqz $t9, COUNT0
    j main_end
   
  
   
  CONTAIN:
   lb $s5,0($s1) #char string
   lb $s3,0($s2) #char word
   beq $s5, $s3 , lable
   seq $s4, $s3, 10
   jr $ra
   
   lable:
   addi $s2,$s2,1
   addi $s1,$s1,1
   j CONTAIN
   

   PRINT_WORD:
   addi $s6 ,$s0 ,0
  PRINT:
   lb $s7,0($s6)
   beq $s7,10,skip
   beq $s7,$0,skip
   li $v0,11
   move $a0,$s7
   syscall
   add $s6,$s6,1
   j PRINT
 
   skip:
    jr $ra
  END:
   beqz $t9, COUNT0
   j main_end
  
  COUNT0:
   li $v0,4
   la $a0, count0
   syscall
   j main_end  
  
   
 
    
   
   
   
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
