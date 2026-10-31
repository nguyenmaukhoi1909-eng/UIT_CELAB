.data
  scores: .word 4, 2, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1 #mang diem dua vao MSSV
  n:      .word 12
  grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
  hist:   .word 0,0,0,0
  min:    .asciiz "min="
  max:    .asciiz " max="
  newline:.asciiz "\n"
  g0:     .asciiz "g0="
  g1:     .asciiz " g1="
  g2:     .asciiz " g2="
  g3:     .asciiz " g3="

.text
.globl main

# ====================================================================
# Thu tuc: stats
# Chuc nang: Tim gia tri min va max trong mang
# Tham so:
#   $a0: Dia chi co so cua mang scores 
#   $a1: So luong phan tu n cua mang 
# Gia tri tra ve:
#   $v0: Gia tri nho nhat 
#   $v1: Gia tri lon nhat 
# Thanh ghi su dung:
#   $t0: Bien dem i
#   $t1: Offset de tinh dia chi 
#   $t2: Dia chi cua scores[i] 
#   $t3: Gia tri scores[i] 
# ====================================================================
stats:
 # lay phan tu dau tien lam gia tri min va max
 lw $v0, 0($a0)        # min = scores[0] 
 move $v1, $v0         # max = scores[0] 
 li $t0, 1             # i = 1 
stats_loop:
 beq $t0, $a1, stats_done # neu i == n thi den done
 sll $t1, $t0, 2       # nhan 4 de lay offset 
 add $t2, $a0, $t1     # lay ra dia chi cua scores[i] 
 lw  $t3, 0($t2)       # $t3 = scores[i] 
 bge $t3, $v0, check_max
 move $v0, $t3         # cap nhat min
check_max:
 ble $t3, $v1, stats_next
 move $v1, $t3         # cap nhat max
stats_next:
 addi $t0, $t0, 1      # i++
 j stats_loop
stats_done:
 jr $ra

# ====================================================================
# Thu tuc: histogram
# Chuc nang: Tinh tan suat cac nhom diem (hist)
# Tham so:
#   $a0: Dia chi mang scores 
#   $a1: So luong phan tu n 
#   $a2: Dia chi mang grade_tab 
#   $a3: Dia chi mang hist 
# Gia tri tra ve: Khong co
# Thanh ghi su dung:
#   $t0: Bien dem i 
#   $t1, $t2, $t3: offset, dia chi va gia tri cua scores[i]
#   $t4, $t5: dia chi va gia tri cua grade_tab[s] 
#   $t6, $t7, $t8: offset, dia chi va gia tri cua hist[g] 
# ====================================================================
histogram:
 li $t0, 0             # i = 0 
hist_loop:
 beq  $t0, $a1, hist_done
 sll $t1, $t0, 2       # tinh offset 
 add $t2, $a0, $t1     # tinh dia chi scores[i]
 lw  $t3, 0($t2)       # load diem hien tai s 
 add $t4, $a2, $t3     # dia chi grade_tab[s] 
 lbu $t5, 0($t4)       # $t5 = nhom g
 # tang hist[g] them 1
 # Dia chi hist[g] la ($a3 + g * 4) 
 sll $t6, $t5, 2       # g * 4 
 add $t7, $a3, $t6     # dia chi hist[g]
 lw $t8, 0($t7)        # load gia tri hist[g] hien tai 
 addi $t8, $t8, 1      # hist[g]++
 sw   $t8, 0($t7)      # luu lai vao hist[g]
 addi $t0, $t0, 1      # i++
 j hist_loop
hist_done:
 jr $ra 

# ====================================================================
# Thu tuc: draw_hist
# Chuc nang: Ve bieu do tan suat ra man hinh
# Tham so:
#   $a0: Dia chi mang hist 
#   $a1: So luong nhom 
# Gia tri tra ve: Khong co
# Thanh ghi su dung:
#   $t0: Luu tam dia chi mang hist 
#   $t1: Luu so luong nhom 
#   $t2: Bien dem nhom hien tai 
#   $t3, $t4, $t5: Tinh toan dia chi va lay gia tri hist[g] 
#   $t6: Bien dem cho vong lap in ky tu '|' 
#   $v0, $a0: Dung cho syscall
# ====================================================================
draw_hist:
 move $t0, $a0         # luu tam dia chi mang hist
 move $t1, $a1         # luu tam so nhom
 li $t2, 0             # i = 0 
draw_loop:
 beq $t2, $t1, draw_done
 li $a0, 103           # in ky tu 'g' 
 li $v0, 11            # $v0: 11 = in ky tu
 syscall
 # In so thu tu nhom (0, 1, 2, 3)
 move $a0, $t2
 li   $v0, 1           # $v0: so hieu syscall 
 syscall
 li   $a0, 58          # ASCII ':'
 li   $v0, 11
 syscall
 li   $a0, 32          # ASCII ' ' 
 li   $v0, 11
 syscall
 sll $t3, $t2, 2       # tinh offset
 add $t4, $t3, $t0     # tinh dia chi hist[i]
 lw  $t5, 0($t4)       # load so luong ky tu can in 
 
 move $t6, $t5         # bien dem cho vong lap in '|' 
in_loop:
 beq $t6, $zero, in_done
 li $a0, 124           # ASCII '|'
 li $v0, 11            # $v0: 11=in ky tu
 syscall
 addi $t6, $t6, -1
 j in_loop
in_done:
 li $v0, 4             # $v0: so hieu syscall 
 la $a0, newline
 syscall 
 
 addi $t2, $t2, 1      # chuyen sang nhom tiep theo
 j draw_loop
draw_done:
 jr $ra

# ====================================================================
# main
# ====================================================================
main:
 la $a0, scores        #$a0 dia chi cua mang scores
 lw $a1, n             # $a1 chua n
 jal stats

 move $s0, $v0         # $s0: luu min 
 move $s1, $v1         # $s1: luu max 
 
 # nap cac thong so can cho thu tuc histogram
 la $a0, scores        
 lw $a1, n             
 la $a2, grade_tab     
 la $a3, hist         
 jal histogram
 
 # goi ham draw_hist
 la $a0, hist         
 li $a1, 4            
 jal draw_hist
 
 # In ket qua
 li $v0, 4             # $v0:4 = in chuoi
 la $a0, min
 syscall
 
 li $v0, 1             # $v0 :1 = in so nguyen
 move $a0, $s0
 syscall
 
 li $v0, 4
 la $a0, max
 syscall
 
 li $v0, 1
 move $a0, $s1
 syscall
 
 li $v0, 4
 la $a0, newline
 syscall
 
 la $t0, hist          # luu dia chi mang hist vao $t0 de in
 
 li $v0, 4
 la $a0, g0
 syscall
 
 li $v0, 1
 lw $a0, 0($t0)        # hist[0]
 syscall

 li $v0, 4
 la $a0, g1
 syscall

 li $v0, 1
 lw $a0, 4($t0)        # hist[1]
 syscall

 li $v0, 4
 la $a0, g2
 syscall

 li $v0, 1
 lw $a0, 8($t0)        # hist[2]
 syscall

 li $v0, 4
 la $a0, g3
 syscall

 li $v0, 1
 lw $a0, 12($t0)       # hist[3]
 syscall

 # Ket thuc chuong trinh
 li $v0, 10           
 syscall
