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
	.equ	KEY0, 		0x1		# BITMASK for KEY0
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
interrupt_handler:
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
	movia et, BUTTONS
	ldw r2, 0xC(et)				# read Buttons PIO edgecapture register
	andi r2, r2, KEY0			# mask KEY0 related bit
	beq r2, zero, btn3_isr
	call KEY0_ISR				# KEY0 has been pressed, do the
								# corresponding interuupt handling

	# clear KEY0 related interrupt
	movi r2, KEY0				# by setting the corresponding bit
	stw r2, 0xC(et)				# in edgecapture register
	br end_ir

	# Check if KEY3 is the source for Buttons interrupt
btn3_isr:
	movia et, BUTTONS
	ldw r2, 0xc(et)				# read Buttons PIO edgecapture reg.
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
KEY0_ISR:
	#increment r15 addi r15,r15,1
	ret
	
###############################################################
# KEY3_ISR: KEY3 related interrupt handler.
# PWM period time is 100 x 0.1 ms. If LED on-time value is 
# greater or equal to 0, than this value will be incremented 
# in order to decrease LEDs intensity.
###############################################################
KEY3_ISR:
	#decrement r15 subi r15,r15,1 
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
	.equ STACK_SIZE, 0x400	# stack size
	.equ PUSH_r9_1, subi sp, sp, 4
	.equ PUSH_r9_2, stw r9, (sp)
	.equ POP_r9_1, ldw r9, (sp)
	.equ POP_r9_2, addi sp, sp, 4
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
	mov r7, r0			# COUNTER init

LOOP:
	call write_LED		# subroutine write_LED is called
	call read_COUNT_BUTTON	# subroutine read_COUNT_BUTTON is called
	call read_CLEAR_BUTTON	# subroutine read_CLEAR_BUTTON is called
	br LOOP			# check for the key pressed again

read_COUNT_BUTTON:
	PUSH_r9_1
	PUSH_r9_2
	movia r9, 0x840		# r9 <- 0x840
	ldw r9, (r9)		# r9 <- (0x840)
	andi r9, r9, 0x1	# r9 <- masked value of (0x840)
	bne r9, r0, RELEASED	# Pressed: if r9!=0 => goto RELEASED
	br return_read_COUNT_BUTTON
RELEASED:
	movia r9, 0x840		# r9 <- 0x840
	ldw r9, (r9)		# r9 <- (0x840)
	andi r9, r9, 0x1	# r9 <- masked value of (0x840)
	bne r9, r0, RELEASED	# Pressed: if r9!=0 => goto RELEASED
	addi r7, r7, 1		# Pressed: COUNTER++ 
return_read_COUNT_BUTTON:
	POP_r9_1
	POP_r9_2
	ret	
	
read_CLEAR_BUTTON:
	PUSH_r9_1
	PUSH_r9_2
	movia r9, 0x840		# r9 <- 0x840
	ldw r9, (r9)		# r9 <- (0x840)
	andi r9, r9, 0x8	# r9 <- masked value of (0x840)
	beq r9, r0, return_CLEAR_BUTTON	# if r9==0 => goto return_COUNT_BUTTON 
	mov r7, r0		# COUNTER=0
return_CLEAR_BUTTON:
	POP_r9_1
	POP_r9_2
	ret			# return

write_LED:
	PUSH_r9_1
	PUSH_r9_2
	movia r9, 0x810		# r9 <- 0x810=output_register_address
	stw r7, (r9)		# r7 -> (r9) COUNTER -> output_register
	POP_r9_1
	POP_r9_2
	ret

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
init_Buttons_PIO:
	# save used registers on stack
	subi sp, sp, 8
	stw r2, 0(sp)
	stw r3, 4(sp)

	# enable KEY0 and KEY3 interrupts in Buttons PIO
	# interrupt mask register
	movia r2, KEY3
	movia r3, KEY0
	or r3, r3, r2
	movia r2, BUTTONS
	stw r3, 8(r2)

	# restore used registers from stack
	ldw r2, 0(sp)
	ldw r3, 4(sp)
	addi sp, sp, 8
	ret

###############################################################
# init_intController
###############################################################
init_intController:
	# save used registers on stack
	subi sp, sp, 8
	stw r2, 0(sp)
	stw r3, 4(sp)

	# enable (unmask) Buttons PIO interupts
	movia r2, BUTTONS_IRQ
	rdctl r3, ctl3
	or r3, r3, r2
	wrctl ctl3, r3

	# enable CPU interrupts
	movia r2, PIE
	rdctl r3, ctl0
	or r3, r3, r2
	wrctl ctl0, r3
 
	# restore used registers from stack
	ldw r2, 0(sp)
	ldw r3, 4(sp)
	addi sp, sp, 8
	ret

###############################################################
	.end
