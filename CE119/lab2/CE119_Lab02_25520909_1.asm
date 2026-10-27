.data
  scores: .word 4, 2, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1# cho bat ky
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
stats:
 # lay phan tu dau tien lam gia tri min va max
 lw $v0,0($a0) # min = scores[0]
 move $v1,$v0  # max = scores[0]
 li $t0,1      # i = 1
stats_loop:
 beq $t0,$a1,stats_done # neu i==n thi den done
 sll $t1,$t0,2 #nhan 4
 add $t2,$a0,$t1 # lay ra dia chi cua scores[i]
 lw    $t3, 0($t2)
 bge $t3,$v0,check_max
 move $v0,$t3
check_max:
 ble $t3,$v1,stats_next
 move $v1,$t3
stats_next:
 addi $t0,$t0,1 #i++
 j stats_loop
stats_done:
  jr    $ra
histogram:
 li $t0,0 # i=0
hist_loop:
 beq   $t0, $a1, hist_done
 sll $t1,$t0,2
 add $t2,$a0,$t1
 lw  $t3,0($t2) # load diem hien tai s
 add $t4,$a2, $t3 # dia chi grade_tab[s]
 lbu $t5,0($t4)# $t5= nhom g
 #tang hist[g] them 1
 # Địa chỉ hist[g] là ($a3 + g * 4) 
 sll $t6,$t5,2 # g*4
 add $t7,$a3,$t6
 lw $t8,0($t7)
 addi $t8,$t8,1 #hist[g]++
 sw    $t8, 0($t7)     
 addi $t0,$t0,1
 j hist_loop
hist_done:
 jr $ra 
draw_hist:
 move $t0,$a0 #luu dia chi mang hist
 move $t1,$a1 # luu so nhom
 li $t2,0
draw_loop:
 beq $t2,$t1,draw_done
 li $a0,103 #in nhom g
 li $v0,11
 syscall
 #In so thu tu nhom (0, 1, 2, 3)
 move $a0, $t2
 li   $v0, 1
 syscall
 li   $a0, 58         # ASCII ':'
 li   $v0, 11
 syscall
 li   $a0, 32         # ASCII ' ' (khoang trang)
 li   $v0, 11
 syscall
 sll $t3,$t2,2
 add $t4,$t3,$t0
 lw  $t5,0($t4)
 
 move $t6,$t5 #bien dem cho vong lap in '|'
in_loop:
 beq $t6,$zero,in_done
 li $a0,124
 li $v0,11
 syscall
 addi $t6,$t6,-1
 j in_loop
in_done:
 li $v0,4
 la $a0, newline
 syscall 
 
 addi $t2,$t2,1
 j draw_loop
draw_done:
 jr $ra
main:
 la $a0,scores
 lw $a1,n
 jal stats
  # luu lai gia tri $v0,$v1
 move  $s0, $v0           
 move  $s1, $v1
 # nap cac thong so can cho thu tuc histogram
 la $a0,scores
 lw $a1,n
 la $a2, grade_tab       
 la  $a3, hist            
 jal   histogram
 # nop theo yeu cau cua de
 la   $a0, hist
 li   $a1, 4
 jal   draw_hist
 li $v0,4
 la $a0,min
 syscall
 
 li $v0,1
 move $a0,$s0
 syscall
 
 li $v0,4
 la $a0,max
 syscall
 
 li $v0,1
 move $a0,$s1
 syscall
 
 li    $v0, 4
 la    $a0, newline
 syscall
 
 la    $t0, hist #luu dia chi mang hist
 
 li $v0,4
 la $a0,g0
 syscall
 
 li    $v0, 1
 lw    $a0, 0($t0)          # hist[0]
 syscall

 li    $v0, 4
 la    $a0, g1
 syscall

 li    $v0, 1
 lw    $a0, 4($t0)          # hist[1]
 syscall

 li    $v0, 4
 la    $a0, g2
 syscall

 li    $v0, 1
 lw    $a0, 8($t0)          # hist[2]
 syscall

 li    $v0, 4
 la    $a0,g3
 syscall

 li    $v0, 1
 lw    $a0, 12($t0)         # hist[3]
 syscall

 li    $v0, 10
 syscall
 
