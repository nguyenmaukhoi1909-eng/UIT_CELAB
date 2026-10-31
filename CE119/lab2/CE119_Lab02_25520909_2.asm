.data
    str:    .asciiz "([{([{([{([{}])}])}])}])"  # chuoi can kiem tra
    valid:  .asciiz "Chuoi hop le!\n"
    err1:   .asciiz "Loi 1: Sai loai ngoac tai vi tri: "
    err2:   .asciiz "Loi 2: Thua ngoac dong tai vi tri: "
    err3:   .asciiz "Loi 3: Thieu ngoac dong tai vi tri cuoi: "
    newline:.asciiz "\n"

.text
.globl main

# ====================================================================
# Thu tuc: check_brackets
# Chuc nang: Kiem tra tinh hop le cua chuoi ky tu ngoac su dung stack
# Tham so:
#   $a0: Dia chi chuoi str 
# Gia tri tra ve:
#   $v0: Vi tri loi (0 neu khong co loi)
#   $v1: Ma loi (0: Hop le, 1: Loi 1, 2: Loi 2, 3: Loi 3)
# Thanh ghi su dung:
#   $t0: Con tro duyet chuoi 
#   $t1: Vi tri ky tu hien tai bat dau tu 1 
#   $t2: So luong phan tu hien co trong stack 
#   $t3: Ky tu dang xet 
#   $t4: Hang so ma ASCII de so sanh 
#   $t5: Ky tu lay ra tu stack de kiem tra 
#   $t6: Gia tri tam dung de khoi phuc stack
# ====================================================================
check_brackets:
    move    $t0, $a0        # $t0 = dia chi con tro
    li      $t1, 1          # $t1 = vi tri ky tu hien tai (start tu 1)
    li      $t2, 0          # $t2 = so luong phan tu trong stack ban dau la 0

loop_char:
    lb      $t3, 0($t0)     # doc 1 byte (ky tu)
    beqz    $t3, end_string # neu gap '\0' -> ket thuc chuoi

    li      $t4, 40         # ma ASCII '('
    beq     $t3, $t4, is_open_bracket
    li      $t4, 91         # ma ASCII '['
    beq     $t3, $t4, is_open_bracket
    li      $t4, 123        # ma ASCII '{'
    beq     $t3, $t4, is_open_bracket

    li      $t4, 41         # ma ASCII ')'
    beq     $t3, $t4, check_close_round
    li      $t4, 93         # ma ASCII ']'
    beq     $t3, $t4, check_close_square
    li      $t4, 125        # ma ASCII '}'
    beq     $t3, $t4, check_close_curly

    # ky tu khong phai ngoac bo qua
    j       next_char

is_open_bracket:
    addi    $sp, $sp, -4    # day ky tu ngoac mo vao stack
    sw      $t3, 0($sp)
    addi    $t2, $t2, 1     # tang so phan tu trong stack len 1
    j       next_char

check_close_round:
    beqz    $t2, err_type_2 # neu stack rong ma lai co ngoac dong -> Loi 2
    lw      $t5, 0($sp)     # lay ngoac mo tu stack ra
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1    # giam so luong phan tu stack di 1
    li      $t4, 40         # kiem tra xem co phai '(' khong
    bne     $t5, $t4, err_type_1 # sai loai ngoac -> Loi 1
    j       next_char

check_close_square:
    beqz    $t2, err_type_2 
    lw      $t5, 0($sp)
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1
    li      $t4, 91         # kiem tra '['
    bne     $t5, $t4, err_type_1
    j       next_char

check_close_curly:
    beqz    $t2, err_type_2 
    lw      $t5, 0($sp)
    addi    $sp, $sp, 4
    addi    $t2, $t2, -1
    li      $t4, 123        # kiem tra '{'
    bne     $t5, $t4, err_type_1
    j       next_char

next_char:
    addi    $t0, $t0, 1     # tro sang ky tu tiep theo
    addi    $t1, $t1, 1     # tang vi tri len 1
    j       loop_char

end_string:
    bnez    $t2, err_type_3 # het chuoi nhung stack van con phan tu -> Loi 3
    li      $v0, 0          # tra ve v0 = 0 (khong loi)
    li      $v1, 0          # tra ve v1 = 0 (hop le)
    jr      $ra

err_type_1:                 
    move    $v0, $t1        # tra ve vi tri loi
    li      $v1, 1          # tra ve ma loi 1
    j       re_stack

err_type_2:                 
    move    $v0, $t1        # tra ve vi tri loi
    li      $v1, 2          # tra ve ma loi 2
    j       re_stack

err_type_3:                 
    move    $v0, $t1        # tra ve vi tri loi (ngay sau chuoi)
    li      $v1, 3          # tra ve ma loi 3
    j       re_stack

re_stack:
    # Don dep lai stack ve trang thai cu truoc khi thoat 
    sll     $t6, $t2, 2     # $t6 = so luong phan tu con lai * 4
    add     $sp, $sp, $t6   # cong lai vao $sp
    jr      $ra

# ====================================================================
# main
# ====================================================================
main:
    la      $a0, str        # $a0 = doi so (dia chi chuoi)
    jal     check_brackets

    # Luu ket qua tra ve vao cac thanh ghi $s* de giu qua syscall
    move    $s0, $v0        # $s0: luu vi tri loi 
    move    $s1, $v1        # $s1: luu ma loi 

    beqz    $s1, print_valid # neu ma loi = 0 thi chuoi hop le
    li      $t0, 1           # dung $t0 (tam) de kiem tra tung loai loi
    beq     $s1, $t0, print_err1
    li      $t0, 2
    beq     $s1, $t0, print_err2
    j       print_err3

print_valid:
    li      $v0, 4          # $v0 = 4 (syscall in chuoi)
    la      $a0, valid
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
    la      $a0, err3
    syscall

print_pos:
    li      $v0, 1          # $v0 = 1 (syscall in so nguyen vi tri)
    move    $a0, $s0        # load vi tri loi tu $s0
    syscall
    
    li      $v0, 4
    la      $a0, newline
    syscall

exit_main:
    li      $v0, 10         # $v0 = 10 (syscall thoat chuong trinh)
    syscall
