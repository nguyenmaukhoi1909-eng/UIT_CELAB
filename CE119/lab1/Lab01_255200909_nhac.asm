.data 
 cao_do: .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
 time: .word 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  1,  4
 length: .word 15 
 SYSCALL_MIDI: .word 33 # doi theo nhu cau tai day
  
 a: .word 9
 b:  .word 0
 ins: .word 0
 volume: .word 100
 str_dukien: .asciiz "\nTong du kien (ms): "
 str_doduoc: .asciiz "\nThoi gian do duoc (ms): "
 space: .asciiz " "
 newline:    .asciiz "\n"

.text
.globl main
main:
 li $v0,30 # lay thoi gian bat dau
 syscall
 move $s0,$a0
 
 li $s1,0 #bien luu index
 lw $s2,length
 li $s3,0 #thoi gian du kien
 # tinh thanh phan (150 +10*b)
 lw $t0,b
 mul $t0,$t0,10
 addi $t0,$t0,150
 
 lw $s4,a
loop:
 beq $s1,$s2,end_loop
 
 sll $t1,$s1,2 # offest=i*4
 # tinh cao do thuc
 la $t2,cao_do #dia chi nen
 add $t2,$t2,$t1
 lw $t3,0($t2)
 add $t3,$t3,$s4 #cao do thuc
 # tinh duration
 la $t2,time
 add $t2,$t2,$t1
 lw $t4,0($t2)
 mul $t4,$t4,$t0
 #cong don thoi gian
 add $s3,$s3,$t4
 # In ra dòng thông tin: <cao_do> <ms>
 li $v0,1
 move $a0,$t3 # in ra cao do 
 syscall
 
 li $v0,4
 la $a0, space
 syscall
 
 li $v0,1
 move $a0,$t4 # in ra ms
 syscall
 
 li $v0, 4
 la $a0, newline
 syscall               # In xuống dòng
    
 lw $v0,SYSCALL_MIDI
 move $a0,$t3
 move $a1, $t4
 lw $a2, ins    # $a2 = nhạc cụ
 lw $a3, volume
 syscall
 # tang bien dem i
 addi $s1,$s1,1
 j loop
end_loop:
 li $v0,30
 syscall
 move $s5,$a0
 
 sub $s6, $s5, $s0     # $s6 = Thoi gian do duoc = Ket thuc - Bat dau
 
 # IN KET QUA
 # in thoi gian du kien
 li $v0, 4
 la $a0, str_dukien
 syscall
 
 li $v0, 1
 move $a0, $s3
 syscall
 
 # in thoi do duoc
 li $v0, 4
 la $a0, str_doduoc
 syscall

 li $v0, 1
 move $a0, $s6
 syscall
 
 # Kết thúc chương trình
 li $v0, 10
 syscall
 
 
