###############################################################
#            MCOM-Labor: assembly language template 2
#      Lab exercize 4 (PWM, Interrupts) - Sample Solution!
#
# HAVE CARE:
# Because exception handler will be located at the beginning of
# sdram memory (address 0x800020), .text section is not allowed
# to use this memory area. Therefore we have to specify an 
# offset of 0x200 for the .text section. Therefore exception
# handler size should not exceed 0x200 bytes!!!
#
# Edition History:
# 28-04-2009: Getting Started                            - ms
# 12-03-2014: Stack organization changed                 - ms
# 2016-05-25: Code cosmetics                             - ms
# 2017-04-29: Adapted to DE1-SoC board                   - ms
# 2017-05-01: Template extraction                        - ms
###############################################################

###############################################
# Definition von symbolen Konstanten
###############################################
	.equ STACK_SIZE, 0x400		# stack size
	.equ	LEDS, 	 0xFF200000	# base address of port LEDS
	.equ	BUTTONS, 0xFF200050	# base address of port Buttons
	
	.equ	BUTTONS_IRQ, 0x02	# Buttons PIO IRQ Level
	.equ	KEY3, 		0x8		# KEY3 BITMASK  
	.equ	KEY0, 		0x1		# KEY0 BITMASK 
	.equ	PIE, 		0x1		# CPU's interrupt enable bit
	
###############################################################
# DATA SECTION
# Assumption: 12 kByte data section (0 - 0x2fff) stack is 
# located in data section and starts directly behind used data
# items at address STACK_END.
# Stack is growing downwards. Stack size is given by STACK_SIZE.
# A full descending stack is used, accordingly first stack item
# is stored at address STACK_END+(STACKSIZE).
###############################################################
	.data
TST_PAK1:
	.word 0x11112222	# test data
tp_adr:
	.word 10			# LED on time in 0.1 ms steps

STACK_END:
	.skip STACK_SIZE	# stack area filled with 0

###############################################################
# EXCEPTIONS SECTION
# Note: By using keyword ".exceptions" this section will
# automatically be placed at the correct position, which 
# normally is address 0x20.
###############################################################
.section .exceptions, "ax"
interrupt_handler:	#does this handler executes without being called?
	# Save used registers on stacks, r31 must be saved because
	# subroutines are used
	subi sp, sp, 4
	stw r2, (sp)
	subi sp, sp, 4
	stw r31, (sp)

	# Check if an Buttons PIO interrupt has occured	
	rdctl et, ctl4				# read interrupt pending reg.
	andi r2, et, BUTTONS_IRQ	# check Buttons interrupt
	beq r2, zero, end_ir		# if no Buttons interrupt
								# exit exception handler

	# Check if KEY0 is the source for Buttons interrupt
	movia et, BUTTONS		#(BUTTONS=0xFF200050)	# base address of port Buttons
	ldw r2, 0xC(et)				# (edgecapture=0xFF20005C) read Buttons PIO edgecapture register
	andi r2, r2, KEY0			# (KEY0=0b0001)mask KEY0 related bit
	beq r2, zero, btn3_isr
	call KEY0_ISR				# KEY0 has been pressed, do the
								# corresponding interuupt handling

	# clear KEY0 related interrupt
	movi r2, KEY0				# by setting the corresponding bit
	stw r2, 0xC(et)				# in edgecapture register
	br end_ir

	# Check if KEY3 is the source for Buttons interrupt
btn3_isr:
	movia et, BUTTONS		#(BUTTONS=0xFF200050)	# base address of port Buttons
	ldw r2, 0xc(et)				# (edgecapture=0xFF20005C) read Buttons PIO edgecapture reg.
	andi r2, r2, KEY3			# mask KEY3 related bit
	beq r2, zero, end_ir
	call KEY3_ISR				# KEY3 has been pressed, do the
								# corresponding interrupt handling
	
	# clear KEY3 related interrupt
	movi r2, KEY3				# by setting the corresponding bit
	stw r2, 0xC(et)				# in edgecapture register

end_ir:
	# restore used registers from stack
	ldw r31, (sp)
	addi sp, sp, 4
	ldw r2, (sp)
	addi sp, sp, 4

	# Leave exception handler
	subi ea, ea, 4
	eret
	
###############################################################
# KEY0_ISR: KEY0 related interrupt handler.
# PWM period time is 100 x 0.1 ms. If LED on-time value is 
# smaller than 100, which means that the delay is smaller than 
# 10 ms, than this value will be incremented in order to 
# increase LEDs intensity.
###############################################################
KEY0_ISR:	#does this subroutine executes without being called?
	#if (LED on-time<10ms) LED on-time=LED on-time+1ms
	##increment r15 addi r15,r15,1
	ret
	
###############################################################
# KEY3_ISR: KEY3 related interrupt handler.
# PWM period time is 100 x 0.1 ms. If LED on-time value is 
# greater or equal to 0, than this value will be incremented 
# in order to decrease LEDs intensity.
###############################################################
KEY3_ISR:	#does this subroutine executes without being called?
	#if (LED on-time>=0ms) LED on-time=LED on-time+1ms
	##decrement r15 subi r15,r15,1 
	ret
	
###############################################################
# TEXT SECTION
# Executable code follows
###############################################################
	.global _start
	.text
_start:
	#######################################
	# stack setup:
	# HAVE Care: By default JNiosEmu sets stack pointer sp = 0x40000.
	# That stack is not used here, because SoPC does not support
	# such an address range. I. e. you should ignore the STACK
	# section in JNiosEmu's memory window.
	
	movia	sp, STACK_END		# load data section's start address
	addi	sp, sp, STACK_SIZE	# stack start position should
								# begin at end of section

	# Enter your code here ...

############################################### code from Lab3_Ass4_target.s
###############################################
# MCOM-Labor: Vorlage fuer Assemblerprogramm
# Edition History:
# 28-04-2009: Getting Started - ms
# 12-03-2014: Stack organization changed - ms
###############################################

###############################################
# Definition von symbolen Konstanten
###############################################
	#.equ PUSH_r9_1, subi sp, sp, 4
	#.equ PUSH_r9_2, stw r9, (sp)
	#.equ POP_r9_1, ldw r9, (sp)
	#.equ POP_r9_2, addi sp, sp, 4
	.equ STACK_SIZE, 0x400	# stack size
	.equ PERIODL_ADDR, 0xFF202008
	.equ PERIODH_ADDR, 0xFF20200C
	.equ CONTROL_ADDR, 0xFF202004
	.equ STATUS_ADDR, 0xFF202000
###############################################
# DATA SECTION
# assumption: 12 kByte data section (0 - 0x2fff)
# stack is located in data section and starts
# directly behind used data items at address
# STACK_END.
# Stack is growing downwards. Stack size
# is given by STACK_SIZE. A full descending
# stack is used, accordingly first stack item
# is stored at address STACK_END+(STACKSIZE).
###############################################	
	.data
TST_PAK1:
	.word 0x11112222	# test data

STACK_END:
	.skip STACK_SIZE	# stack area filled with 0

###############################################
# TEXT SECTION
# Executable code follows
###############################################
	.global _start
	.text
_start:
	#######################################
	# stack setup:
	# HAVE Care: By default JNiosEmu sets stack pointer sp = 0x40000.
	# That stack is not used here, because SoPC does not support
	# such an address range. I. e. you should ignore the STACK
	# section in JNiosEmu's memory window.
	
	movia	sp, STACK_END		# load data section's start address
	addi	sp, sp, STACK_SIZE	# stack start position should
					# begin at end of section
START:
###############################################
main:	#does this subroutine executes without being called?
	movi r7, 0b1111		# write parameter to switch LED0-LED3 on
	call write_LED		# write_LED(r7)
	
	movia r15, 20		# r15 <- 20 = 2ms
	call wait		# wait(r15)
	
	movi r7, 0b0011		# write parameter to switch LED0-LED1 on
	call write_LED		# write_LED(r15)
	
	movia r15, 80		# r15 <- 80 = 8 ms
	call wait		# wait(r15)
	
	beq r0, r0, main	# while(true) goto main
###############################################
wait:
	subi sp, sp, 4		# PUSH_r15_1
	stw r15, (sp)		# PUSH_r15_2
	
	muli r15, r15, 10.000	# modify r15 to make it as int parameter for init_timer() with step 0.1ms 

	subi sp, sp, 4		# PUSH_r31_1 (before calling the 2nd level subrotines)
	stw r31, (sp)		# PUSH_r31_2 (before calling the 2nd level subrotines)

	call init_timer		# call init_timer(r15)
	call wait_timer		# call wait_timer()
	
	ldw r31, (sp)		# POP_r31_1 (after calling the 2nd level subrotines)
	addi sp, sp, 4		# POP_r31_2 (after calling the 2nd level subrotines)	
	
	ldw r15, (sp)		# POP_r15_1
	addi sp, sp, 4		# POP_r15_2	
ret
###############################################
init_timer:
	subi sp, sp, 4		# PUSH_r2_1
	stw r2, (sp)		# PUSH_r2_2
	
	subi sp, sp, 4		# PUSH_r15_1
	stw r15, (sp)		# PUSH_r15_2
	
	movia r2, PERIODL_ADDR	# PERIODL_ADDR -> r2
	sth r15, (r2)		# r15L -> periodl 
	movia r2, PERIODH_ADDR	# PERIODH_ADDR -> r2
	srli r15, r15, 16	# shift right by 16 bits TODO: ?Or by 15 bits?
	sth r15, (r2)		# r15H -> periodh
	
	ldw r15, (sp)		# POP_r15_1
	addi sp, sp, 4		# POP_r15_2
	
	ldw r2, (sp)		# POP_r2_1
	addi sp, sp, 4		# POP_r2_2 
ret
###############################################
wait_timer:
	subi sp, sp, 4		# PUSH_r2_1
	stw r2, (sp)		# PUSH_r2_2
	
	subi sp, sp, 4		# PUSH_r15_1
	stw r15, (sp)		# PUSH_r15_2
	
	movia r2, CONTROL_ADDR	# CONTROL_ADDR -> r2
	ldw r15, (r2)		# content of control -> r15
	ori r15, r15, 0b0100	# mask 2nd bit of the content of control (r15||0b0100 -> r15)
	stw r15, (r2)		# start timer(masked content of control -> control)
	movia r2, STATUS_ADDR	# STATUS_ADDR -> r2
	stw r0, (r2)		# control <- 0 for explicit clear the timeout-bit
WHILE:
	movia r2, STATUS_ADDR	# STATUS_ADDR -> r2
	ldw r15, (r2)		# status -> r15
	andi r15, r15, 0b0001	# mask the content of the status
	beq r15, r0, WHILE	# if timer is not expired(masked status == 0), check again
				# the timer has expired(masked status != 0)
				
	ldw r15, (sp)		# POP_r15_1
	addi sp, sp, 4		# POP_r15_2				
				
	ldw r2, (sp)		# POP_r2_1
	addi sp, sp, 4		# POP_r2_2
ret
###############################################
write_LED:
	subi sp, sp, 4		# PUSH_r9_1
	stw r9, (sp)		# PUSH_r9_2
	
	movia r9, 0xFF200000	# r9 <- 0xFF200000=output_register_address
	stw r7, (r9)		# r7 -> (r9) COUNTER -> output_register
	
	ldw r9, (sp)		# POP_r9_1
	addi sp, sp, 4		# POP_r9_2
ret
###############################################
endloop:
	br endloop		# that's it
###############################################
	.end


###############################################




endloop:
	br endloop		# that's it

	
###############################################################
# init_Buttons_PIO
# Initialize Buttons PIO for interrupt
# generation. KEY0 and KEY3 related interrupts
# will be enabled.
###############################################################
init_Buttons_PIO:	#after init_intController
	# save used registers on stack
	subi sp, sp, 8
	stw r2, 0(sp)
	stw r3, 4(sp)

	# enable KEY0 and KEY3 interrupts in Buttons PIO
	# interrupt mask register
	movia r2, KEY3	#Enabling interrupts for KEY0, KEY3 (0b1001->(0xFF200058))
	movia r3, KEY0	#what is the KEY0=0b0001, KEY3=0b1000, BUTTONS addresses?
	or r3, r3, r2	#why we do (0b0001 or 0b1000=some mask 0b1001)
	movia r2, BUTTONS	#what is the starting address(BUTTONS=0xFF200050=data=Status of buttons KEY0, KEY1, KEY2 and KEY3)?	# base address of port Buttons	
	stw r3, 8(r2)	# interruptmaskAddress=0xFF200058	

	# restore used registers from stack
	ldw r2, 0(sp)
	ldw r3, 4(sp)
	addi sp, sp, 8
	ret

###############################################################
# init_intController
###############################################################
init_intController:	#very start
	# save used registers on stack
	subi sp, sp, 8
	stw r2, 0(sp)
	stw r3, 4(sp)

	# what is the difference between (interruptmaskAddress=0xFF200058) and	(ctl3=Interrupt Enable Register)?

	# enable (unmask) Buttons PIO interupts
	movia r2, BUTTONS_IRQ	#why BUTTONS_IRQ=0b0010?	# Buttons(mask) PIO IRQ Level
	rdctl r3, ctl3
	or r3, r3, r2	#mask ctl3 or 0b0010 for IRQ1 (did we choose IRQ1 arbitrarily?)
	wrctl ctl3, r3	#mask ctl3 value. why Prof. name it unmask? How to implement unmasking?

	# enable CPU interrupts
	movia r2, PIE	#0b0001		# CPU's interrupt enable bit
	rdctl r3, ctl0
	or r3, r3, r2
	wrctl ctl0, r3	#masking LSB of ctl0(SR)
 
	# restore used registers from stack
	ldw r2, 0(sp)
	ldw r3, 4(sp)
	addi sp, sp, 8
	ret

###############################################################
	.end
