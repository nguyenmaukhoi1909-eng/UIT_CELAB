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
 li $v0,30 # $v0:30 = lay thoi gian he thong
 syscall
 move $s0,$a0 # $s0:luu thoi gian bat dau vao $s0
 
 li $s1,0 # $s1:bien dem index i = 0
 lw $s2,length # $s2:chieu dai mang 
 li $s3,0 # $s3: tong thoi gian du kien
 
 # tinh thanh phan (150 + 10*b)
 lw $t0,b # $t0:luu bien b
 mul $t0,$t0,10 # $t0:b * 10
 addi $t0,$t0,150 # $t0: 150 + 10*b
 
 lw $s4,a # $s4:luu bien a de tinh cao do
loop:
 beq $s1,$s2,end_loop
 
 sll $t1,$s1,2 # $t1: offset = i * 4
 
 # tinh cao do thuc
 la $t2,cao_do # $t2:dia chi nen mang cao_do
 add $t2,$t2,$t1 # $t2:dia chi cao_do[i]
 lw $t3,0($t2) # $t3:gia tri cao_do[i]
 add $t3,$t3,$s4 # $t3: cao do thuc = cao_do[i] + a
 
 # tinh duration (thoi luong)
 la $t2,time # $t2:dia chi nen mang time
 add $t2,$t2,$t1 # $t2:dia chi time[i]
 lw $t4,0($t2) # $t4:gia tri time[i]
 mul $t4,$t4,$t0 # $t4: duration = time[i] * (150 + 10*b)
 
 # cong don thoi gian
 add $s3,$s3,$t4 # $s3:cong don thoi gian du kien
 
 # In ra dong thong tin: <cao_do> <ms>
 li $v0,1 # $v0: 1 = in so nguyen
 move $a0,$t3 
 syscall
 
 li $v0,4 # $v0: 4 = in chuoi
 la $a0, space 
 syscall
 
 li $v0,1 1 = in so nguyen
 move $a0,$t4 
 syscall
 
 li $v0, 4 # $v0:4 = in chuoi
 la $a0, newline 
 syscall               
    
 lw $v0,SYSCALL_MIDI # $v0: cho phep doi thanh 33 phat nhac
 move $a0,$t3 # $a0:cao do 
 move $a1, $t4 # $a1:duration
 lw $a2, ins # $a2: instrument
 lw $a3, volume # $a3:am luong 
 syscall
 
 # tang bien dem i
 addi $s1,$s1,1 # $s1:i++
 j loop
 
end_loop:
 li $v0,30 # $v0: 30 = lay thoi gian he thong lan 2
 syscall
 move $s5,$a0 # $s5: luu thoi gian ket thuc
 
 sub $s6, $s5, $s0 # $s6:Thoi gian do duoc = thoi gian ket thuc - thoi gian bat dau
 
 # IN KET QUA
 # in thoi gian du kien
 li $v0, 4 # $v0:4 = in chuoi
 la $a0, str_dukien # $a0:in chuoi tong du kien
 syscall
 
 li $v0, 1 # $v0:1 = in so nguyen
 move $a0, $s3 # $a0:in tong thoi gian du kien tinh duoc
 syscall
 
 # in thoi gian do duoc
 li $v0, 4 # $v0: 4 = in chuoi
 la $a0, str_doduoc # $a0: in chuoi thoi gian thuc te
 syscall

 li $v0, 1 # $v0: 1 = in so nguyen
 move $a0, $s6 #in thoi gian do duoc
 syscall
 
 # Ket thuc chuong trinh
 li $v0, 10 # $v0: 10 = ket thuc chuong trinh
 syscall
