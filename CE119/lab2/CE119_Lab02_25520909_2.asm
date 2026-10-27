.data
    str:    .asciiz "([{([{([{([{}])}])}])}])"  #thay doi day o day
    valid:  .asciiz "Chuoi hop le!\n"
    err1:   .asciiz "Loi 1: Sai loai ngoac tai vi tri: "
    err2:   .asciiz "Loi 2: Thua ngoac dong tai vi tri: "
    err3:   .asciiz "Loi 3: Thieu ngoac dong ("
    newline:.asciiz "\n"
.text
.globl main
check_brackets:
    move    $t0, $a0        #con tro
    li      $t1, 1          # $t1 = vi tri ky tu hien tai( start tu 1)
    li      $t2, 0          # $t2 = so luong ptu trong stack

loop_char:
    lb      $t3, 0($t0)
    beqz    $t3, end_string # gap'\0' -> end_string

    li      $t4, 40         # '('
    beq     $t3, $t4, is_open_bracket
    li      $t4, 91         # '['
    beq     $t3, $t4, is_open_bracket
    li      $t4, 123        # '{'
    beq     $t3, $t4, is_open_bracket

    li      $t4, 41         # ')'
    beq     $t3, $t4, check_close_round
    li      $t4, 93         # ']'
    beq     $t3, $t4, check_close_square
    li      $t4, 125        # '}'
    beq     $t3, $t4, check_close_curly

    #ky tu thuong bo qua
    j       next_char

is_open_bracket:
    addi    $sp, $sp, -4
    sw      $t3, 0($sp)
    addi    $t2, $t2, 1     # tang so ptu trong stack
    j       next_char

check_close_round:
    beqz    $t2, err_type_2 # stack rong ma them vao ')'
    lw      $t5, 0($sp)
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1    # giam so ptu trong stack
    li      $t4, 40         # kiem tra xem co phai '(' khong
    bne     $t5, $t4, err_type_1
    j       next_char

check_close_square:
    beqz    $t2, err_type_2 
    lw      $t5, 0($sp)
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1
    li      $t4, 91         
    bne     $t5, $t4, err_type_1
    j       next_char

check_close_curly:
    beqz    $t2, err_type_2 
    lw      $t5, 0($sp)
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1
    li      $t4, 123       
    bne     $t5, $t4, err_type_1
    j       next_char

next_char:
    addi    $t0, $t0, 1
    addi    $t1, $t1, 1
    j       loop_char

end_string:
    bnez    $t2, err_type_3 # het chuoi nhung stack van con ptu
    li      $v0, 0
    li      $v1, 0
    jr      $ra

err_type_1:                 
    move    $v0, $t1
    li      $v1, 1
    j       re_stack

err_type_2:                 
    move    $v0, $t1
    li      $v1, 2
    j       re_stack

err_type_3:                 
    move    $v0, $t1
    li      $v1, 3
    j       re_stack

re_stack:
    sll     $t6, $t2, 2     #
    add     $sp, $sp, $t6
    jr      $ra
main:
    la      $a0, str
    jal     check_brackets

    move    $s0, $v0        # Vi tri loi
    move    $s1, $v1        # Ma loi

    beqz    $s1, print_valid
    li      $t0, 1
    beq     $s1, $t0, print_err1
    li      $t0, 2
    beq     $s1, $t0, print_err2
    j       print_err3

print_valid:
    li      $v0, 4
    la      $a0,valid
    syscall
    j       exit_main

print_err1:
    li      $v0, 4
    la      $a0, err1
    syscall
    j       print_pos

print_err2:
    li      $v0, 4
    la      $a0, err2
    syscall
    j       print_pos

print_err3:
    li      $v0, 4
    la      $a0,err3
    syscall

print_pos:
    li      $v0, 1
    move    $a0, $s0
    syscall
    
    li      $v0, 4
    la      $a0, newline
    syscall

exit_main:
    li      $v0, 10        
    syscall
