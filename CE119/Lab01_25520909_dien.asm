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
    # 1. In thông báo nhập
    li $v0, 4
    la $a0, string1
    syscall

    # 2. Đọc số nguyên kWh từ bàn phím
    li $v0, 5
    syscall
    move $s0, $v0

    # 3. Kiểm tra điều kiện nhập (0 <= x <= 9999)
    li $t0, 9999
    sltu $t0, $t0, $s0      # Nếu 9999 < $s0 thì $t0 = 1
    bne $t0, $zero, invalid  # Báo lỗi nếu nhập vượt quá 9999

    j calculate

invalid:
    # In thông báo lỗi và yêu cầu nhập lại
    li $v0, 4
    la $a0, err
    syscall
    j input_loop

calculate:
    # Khởi tạo các giá trị ban đầu
    li $s1, 0               # total_price = 0
    move $s3, $s0           # remaining_kwh = x
    la $s4, limits          # Con trỏ $s4 chỉ tới đầu mảng limits
    la $s5, rates           # Con trỏ $s5 chỉ tới đầu mảng rates
    li $t1, 0               # Nấc dưới ban đầu = 0

calc_loop:
    # Điều kiện dừng: Nếu số kWh còn lại == 0 thì chuyển sang in kết quả
    beq $s3, $zero, display_result

    # --- ĐOẠN TỐI ƯU HÓA ---
    # Đọc trực tiếp dữ liệu từ con trỏ $s4 và $s5 (không tốn sll và add địa chỉ)
    lw $t4, 0($s4)          # $t4 = upper_bound (mốc trên của bậc hiện tại)
    lw $t5, 0($s5)          # $t5 = đơn giá của bậc hiện tại

    sub $t6, $t4, $t1       # $t6 = Dung lượng kWh tối đa của bậc này (capacity)

    # Kiểm tra xem kWh còn lại có nằm gọn trong bậc hiện tại hay không
    ble $s3, $t6, use_remaining
    move $t7, $t6           # Nếu tràn bậc: kWh tính tiền = capacity
    j tinh_tien

use_remaining:
    move $t7, $s3           # Nếu không tràn bậc: kWh tính tiền = remaining_kwh

tinh_tien:
    # Tổng tiền += kWh tính tiền * đơn giá
    mul $t8, $t7, $t5
    add $s1, $s1, $t8

    # Cập nhật số kWh còn lại và nấc dưới cho bậc sau
    sub $s3, $s3, $t7       # remaining_kwh -= kWh vừa tính
    move $t1, $t4           # lower_bound = upper_bound hiện tại

    # Tăng trực tiếp con trỏ mảng thêm 4 bytes cho lần lặp kế tiếp
    addi $s4, $s4, 4
    addi $s5, $s5, 4

    j calc_loop

display_result:
    # 1. In chuỗi " Tien dien: "
    li $v0, 4
    la $a0, res
    syscall

    # 2. In số tiền tổng ($s1)
    li $v0, 1
    move $a0, $s1
    syscall

    # 3. In chuỗi " dong"
    li $v0, 4
    la $a0, don_vi
    syscall

    # 4. Thoát chương trình
    li $v0, 10
    syscall