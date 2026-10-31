.data
    string1: .asciiz "Nhap so kWh(0..9999): "
    err:     .asciiz " gia tri khong hop le ,nhap lai\n"
    res:     .asciiz " Tien dien: "
    don_vi:  .asciiz " dong" 
    limits:  .word 50, 100, 200, 300, 400, 9999
    rates:   .word 1780, 1840, 2130, 2680, 3030, 3180

.text
.globl main
main:
input_loop:
    # 1. In thong bao nhap
    li $v0, 4               # $v0=4 (in chuoi)
    la $a0, string1         
    syscall

    # 2. Doc so nguyen kWh tu ban phim
    li $v0, 5               # $v0 =5 (doc so nguyen)
    syscall
    move $s0, $v0           # $s0 =so kWh dau vao

    # 3. Kiem tra dieu kien nhap (0 <= x <= 9999)
    li $t0, 9999            # $t0=9999 de so sanh
    sltu $t0, $t0, $s0      # Neu 9999 < $s0 thi $t0 = 1 
    bne $t0, $zero, invalid # Bao loi neu nhap vuot qua 9999

    j calculate

invalid:
    # In thong bao loi va yeu cau nhap lai
    li $v0, 4               # $v0=4)( in chuoi)
    la $a0, err         
    syscall
    j input_loop

calculate:
    # Khoi tao cac gia tri ban dau
    li $s1, 0               # $s1: total_price = 0
    move $s3, $s0           # $s3: remaining_kwh = kWh ban dau
    la $s4, limits          # $s4:con tro toi mang limits
    la $s5, rates           # $s5: con tro toi mang rates
    li $t1, 0               # $t1: nac duoi ban dau = 0

calc_loop:
    # Dieu kien dung: Neu so kWh con lai == 0 thi chuyen sang in ket qua
    beq $s3, $zero, display_result

    # DOAN TOI UU HOA 
    # Doc truc tiep du lieu tu con tro $s4 va $s5 
    lw $t4, 0($s4)          # $t4: upper_bound - moc tren cua bac hien tai
    lw $t5, 0($s5)          # $t5: don gia cua bac hien tai

    sub $t6, $t4, $t1       # $t6:dung luong kWh toi da cua bac nay

    # Kiem tra xem kWh con lai co nam gon trong bac hien tai hay khong
    ble $s3, $t6, use_remaining
    move $t7, $t6           # $t7:neu tran bac: kWh tinh tien = suc chua cua bac
    j tinh_tien

use_remaining:
    move $t7, $s3           # $t7:neu khong tran bac: kWh tinh tien = remaining_kwh

tinh_tien:
    # Tong tien += kWh tinh tien * don gia
    mul $t8, $t7, $t5       # $t8: so tien cua rieng bac nay
    add $s1, $s1, $t8       # $s1: cong don tong tien

    # Cap nhat so kWh con lai va nac duoi cho bac sau
    sub $s3, $s3, $t7       # $s3: remaining_kwh -= kWh vua tinh
    move $t1, $t4           # $t1: lower_bound = upper_bound hien tai

    # Tang truc tiep con tro mang them 4 bytes cho lan lap ke tiep
    addi $s4, $s4, 4        # $s4: di sang phan tu ke tiep mang limits
    addi $s5, $s5, 4        # $s5: di sang phan tu ke tiep mang rates

    j calc_loop

display_result:
    # 1. In chuoi " Tien dien: "
    li $v0, 4               # $v0: 4 = in chuoi
    la $a0, res             
    syscall

    # 2. In so tien tong
    li $v0, 1               # $v0: 1 = in so nguyen
    move $a0, $s1           # $a0: chuyen total_price vao a0 de in
    syscall

    # 3. In chuoi " dong"
    li $v0, 4               # $v0:4 = in chuoi
    la $a0, don_vi         
    syscall

    # 4. Thoat chuong trinh
    li $v0, 10              # $v0: 10 = exit thoat chuong trinh
    syscall                 
