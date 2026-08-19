; AY-3-8912 IC emulator version 26.0 for LGT8F328P
;
; Sources for Atmel AVRStudio 7
;
; visit our site for more information
; These source codes are distributed under the GPL v3 license
; If you share these sources you should put the link to web site www.avray.ru
;
; ORIGIN: http://www.avray.ru

; CONFIGURATION VALUES ===================================================
#define CHANNELS 2 		; choose 2 or 3 channel version
#define VOLUME_TABLE 0	; 0 - AY, 1 - YM, 2 - ALTERNATE volume table
; ========================================================================
; bit numbers:
.equ	b0	= 0x00
.equ	b1	= 0x01
.equ	b2	= 0x02
.equ	b3	= 0x03
.equ	b4	= 0x04
.equ	b5	= 0x05
.equ	b6	= 0x06
.equ	b7	= 0x07
.equ	CHIP_SELECTED = GPIOR0	


.def OutA  = r0
.def OutC  = r1
.def C1F   = r2
.def CntN  = r3
.def OutB  = r4
.def BusOut1  = r5
.def NoiseAddon = r6
.def C00   = r7
.def CC0   = r8
.def TabE  = r9
.def C04   = r10
.def TMP   = r11
.def EVal  = r12
.def SREGSave = r13
.def RNGL  = r14
.def RNGH  = r15
.def BusData  = r16
.def BusOut2  = r17
.def TabP  = r18
.def TNLevel  = r19
.def CntAL  = r20
.def CntAH  = r21
.def CntBL  = r22
.def CntBH  = r23
.def CntCL  = r24
.def CntCH  = r25
.def CntEL  = r26
.def CntEH  = r27
.def ADDR  = r30

; ==============================================
; LGT8F328P REGISTER DEFINITIONS
; ==============================================
; Memory-mapped I/O addresses for LGT8F328P
.equ CCP     = 0x34      ; Configuration Change Protection
.equ CLKMSR  = 0x105     ; Clock Main Settings Register
.equ BCR     = 0x107     ; Boot Control Register
.equ BOOTEND = 0x108     ; Boot End Address
.equ BODCR   = 0x104     ; BOD Control Register

; AC0 (Analog Comparator 0) Register Definition
.equ C0SR   = 0x50
.equ C0D    = 7
.equ C0BG   = 6
.equ C0O    = 5
.equ C0I    = 4
.equ C0IE   = 3
.equ C0IC   = 2
.equ C0IS1  = 1
.equ C0IS0  = 0

.equ C0XR   = 0x51
.equ C0OE   = 6
.equ C0HSYE = 5
.equ C0PS0  = 4
.equ C0WKE  = 3
.equ C0FEN  = 2
.equ C0FS1  = 1
.equ C0FS0  = 0

.equ C0TR   = 0x52

; AC1 (Analog Comparator 1) Register Definition
.equ C1SR   = 0x2F
.equ C1D    = 7
.equ C1BG   = 6
.equ C1O    = 5
.equ C1I    = 4
.equ C1IE   = 3
.equ C1IC   = 2
.equ C1IS1  = 1
.equ C1IS0  = 0

.equ C1XR   = 0x3A
.equ C1OE   = 6
.equ C1HSYE = 5
.equ C1PS0  = 4
.equ C1WKE  = 3
.equ C1FEN  = 2
.equ C1FS1  = 1
.equ C1FS0  = 0

.equ C1TR   = 0x5B

; LGT8F328P FAST GPIO REGISTERS
.equ FGPIOE  = 0x10A       ; Fast GPIO Enable Register
.equ FGPIO   = 0x10B       ; Fast GPIO Control Register

	.cseg
;------------------------------------------------------
; INTERRUPT VECTORS TABLE
;------------------------------------------------------
	.org	0x0000
	rjmp	_LGT_INIT

	.org	INT0addr
	rjmp	_INT0_Handler

	.org	INT1addr
 	rjmp	_INT1_Handler

;------------------------------------------------------

#if VOLUME_TABLE == 0
	Volumes: ; volume table for amplitude
		.db 0,1,1,1,2,2,3,5,6,9,13,17,22,29,36,45 // AY_TABLE
	EVolumes: ; volume table for envelopes
		.db 0,0,1,1,1,1,1,1,2,2,2,2,3,3,5,5,6,6,7,9,11,13,15,17,19,22,25,29,32,36,40,45 // AY_TABLE
#elif VOLUME_TABLE == 1
	Volumes: ; volume table for amplitude
		.db 0,1,1,1,2,2,3,4,5,7,10,13,18,24,34,45 // YM_TABLE
	EVolumes: ; volume table for envelopes
		.db 0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,4,4,5,6,7,8,10,11,13,15,18,21,24,29,34,40,45 // YM_TABLE
#elif VOLUME_TABLE == 2
	Volumes: ; volume table for amplitude
		.db 0,1,2,3,4,5,6,7,9,11,13,16,22,31,42,58 // ALT_TABLE
	EVolumes: ; volume table for envelopes
		.db 0,1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,22,24,26,28,30,33,36,40,45,51,58 // ALT_TABLE
#endif

; envelope codes, bit0 - attack, bit1 - invert on next cycle, bit2 - stop generator on next cycle
Envelopes:
	.db 7,7,7,7,4,4,4,4,1,7,3,5,0,6,2,4

; mask applied to registers values after receiving
RegsMask:
	.db 0xFF,0x0F,0xFF,0x0F,0xFF,0x0F,0x1F,0xFF,0x1F,0x1F,0x1F,0xFF,0xFF,0x0F,0xFF,0xFF

;==========================================================
_INT0_Handler:					; 4 cycles to enter
	sbic	PinD,b3				; check BDIR (1)
	rjmp	LATCH_REG_ADDR0		; (2) if BDIR=1

	out		DDRD,BusOut2		; 1 - set data bus
	out		DDRC,BusOut1		; 1
	
LOOP_NOT_INACTIVE:
	sbic	PinD,b2				; 1 - wait for BC1=0
	rjmp	LOOP_NOT_INACTIVE	; 2
	out		DDRC, C00			; 1
	out		DDRD, C00			; 1

exit_int0:
	out		EIFR, YH			; 1 - clear flags
	reti						; 4

LATCH_REG_ADDR0:
	in		ADDR, PinC			; 1
	andi	ADDR, 0x3F			; 1
	sbic	PinD,b7		
	rjmp    SELECT_CHIP_ADDR0
	sbic	CHIP_SELECTED,b0	
	rjmp	READ_CHIP0
	; Чип 0
	ldi		ZH,0x01
	ldd		BusOut1, Z+0x20
	ldd		BusOut2, Z+0x30
	rjmp	exit_int0

READ_CHIP0:
	; Чип 1
	ldi		ZH,0x08		
	ldd		BusOut1, Z+0x20
	ldd		BusOut2, Z+0x30
	rjmp	exit_int0

SELECT_CHIP_ADDR0:
	cpi		ADDR, 0x3F			; 1
	breq	SELECT_CHIP0_ADDR0	; 1/2
	cpi		ADDR, 0x3E
	breq	SELECT_CHIP1_ADDR0	; 2
	rjmp	exit_int0

SELECT_CHIP0_ADDR0:
	cbi CHIP_SELECTED, b0
	rjmp	exit_int0

SELECT_CHIP1_ADDR0:
	sbi CHIP_SELECTED, b0
	rjmp	exit_int0

;==========================================================
_INT1_Handler:					; 4 cycles to enter
	in		BusData, PinC		; 1
	andi	BusData, 0x3F		; 1

	sbic	PinD, b2			; 1
	rjmp	LATCH_REG_ADDR1		; 2

	in		BusOut1, PinD		; 1
	in		SREGSave, SREG		; 1
	and		BusOut1, CC0		
	or		BusData, BusOut1	; 1
	mov		BusOut1, BusData	; 1
	com		BusOut1				; 1
	sbic	CHIP_SELECTED, b0
	rjmp	WRITE_TO_CHIP1

	; Устанавливаем Z на AY0
	ldi		ZH, 0x01
	rjmp	WRITE_COMMON

WRITE_TO_CHIP1:
	; Устанавливаем Z на AY1
	ldi		ZH, 0x08

WRITE_COMMON:
	ld		BusOut2, Z			; 2 - load mask
	std		Z+0x20, BusOut1		; 2 - save inverted
	and		BusData, BusOut2	; 1 - apply mask
	mov		BusOut2, BusOut1	; 1
	andi	BusOut2, 0xC0		; 1 - extract bits 6-7

	std		Z+0x30, BusOut2		; 2 - save high bits
	std		Z+0x10, BusData		; 2 - save value
	
	; Проверка регистра 13 через прямое сравнение
	cpi		ADDR, 0x0D			; 1
	brne	NO_ENVELOPE_CHANGED_P; 1/2
	ori		TNLevel, 0x80		; 1
NO_ENVELOPE_CHANGED_P:
	out		SREG, SREGSave		; 1
exit_int1:
	ldi		ZH, 0x01
	out		EIFR, ZH			; 1
	reti

LATCH_REG_ADDR1:
	mov		ADDR, BusData		; 1
	sbic	PinD,b6		
	rjmp    SELECT_CHIP_ADDR1
	sbic	CHIP_SELECTED,b0
	rjmp	READ_CHIP1
	; Чип 0
	ldi		ZH,0x01		
	ldd		BusOut1, Z+0x20		; 2
	ldd		BusOut2, Z+0x30		; 2
	rjmp	exit_int1

READ_CHIP1:
	; Чип 1
	ldi		ZH,0x08	
	ldd		BusOut1, Z+0x20
	ldd		BusOut2, Z+0x30
	rjmp	exit_int1			; 2

SELECT_CHIP_ADDR1:
	cpi		ADDR, 0x3F			; 1
	breq	SELECT_CHIP0_ADDR1	; 1/2
	cpi		ADDR, 0x3E
	breq	SELECT_CHIP1_ADDR1	; 2
	rjmp	exit_int1

SELECT_CHIP0_ADDR1:
	cbi CHIP_SELECTED, b0
	rjmp	exit_int1

SELECT_CHIP1_ADDR1:
	sbi CHIP_SELECTED, b0
	rjmp	exit_int1

; ==============================================
; LGT8F328P INITIALIZATION - NO BOOTLOADER
; ==============================================
_LGT_INIT:
    ; 1. Disable watchdog immediately
    ldi     r16, 0x00
    sts     WDTCSR, r16
    
    ; 2. Unlock protected registers (LGT specific)
    ldi     r16, 0xD8
    sts     CCP, r16          ; Enable configuration changes
    
    ; 3. Configure clock: 32MHz internal, divisor = 1
    ldi     r16, 0x80
    sts     CLKPR, r16        ; Enable CLKPR changes
    
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, 0x00
    sts     CLKPR, r16        ; Divisor = 1 (32MHz)
    
    ; 4. Select internal 32MHz oscillator
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, 0x04
    sts     CLKMSR, r16       ; Internal 32MHz oscillator
  
    ; 5. ENABLE FAST GPIO FOR PORTS B, C, D
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, (1<<2) | (1<<1) | (1<<0)
    sts     FGPIOE, r16
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, (0<<4) | (0<<2) | (0<<0)  ; No delay for all ports
    sts     FGPIO, r16
    
    ; 6. Configure Fast GPIO timing (optional, default is usually OK)
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, 0x00         ; Default timing (no delay)
    sts     FGPIO, r16        ; Set Fast GPIO Control register
    
    ; 7. DISABLE BOOTLOADER - BOOTRST=0, start from 0x0000
    ldi     r16, 0x03         ; BOOTSZ=11, BOOTRST=0
    sts     BCR, r16
    
    ; 8. Set BOOTEND (optional, defines flash boundary)
    ldi     r16, 0x7F         ; 0x7F00 for 32KB flash
    sts     BOOTEND, r16
    
    ; 9. Continue to original reset code
    rjmp    _RESET

;==========================================================
_RESET: // Emulator start
	in		r16,MCUCR			; 1-> PUD for
	sbr		r16,PUD
	out		MCUCR,r16

	// init stack pointer at end of RAM
	ldi		r16,low(RAMEND)
	out		SPL,r16
	ldi		r16,high(RAMEND)
	out		SPH,r16

	; ИНИЦИАЛИЗАЦИЯ ПОРТОВ C и D В HI-Z ===================
	; Порт C: PC0-PC5 - данные, должны быть в HI-Z
	; Порт D: PD6,PD7 - данные, должны быть в HI-Z
	ldi		r16,0x00
	out		DDRC,r16		; все пины порта C как входы
	out		PORTC,r16		; отключить подтяжки
	out		DDRD,r16		; все пины порта D как входы
	out		PORTD,r16		; отключить подтяжки
	; =====================================================

	; disable Analog Comparator ==============================
	ldi		r16, (1<<C0D) 
	sts		C0SR, r16
	ldi		r16, (1<<C1D) 
	out	    C1SR, r16
	;=========================================================

	// init constants
	cbi		CHIP_SELECTED, b0 ; Сначала всегда выбран AY 0
	cbi		CHIP_SELECTED, b1 

	clr		C00
	ldi		r16,0xC0
	mov		CC0,r16
	ldi		r16,0x04
	mov		C04,r16
	ldi		r16,0x1F
	mov		C1F,r16
	ldi		r16,0xFF
	mov		BusOut1,r16
	mov		BusOut2,CC0
	clr		RNGH
	ldi		YH,0xFF
	// clear register values in SRAM 0x110-0x13F
	ldi		r18,0x10
	ldi		ZL,0x10
	ldi		ZH,0x01
LOOP0:
	std		Z+0x20,CC0
	std		Z+0x10,r16
	st		Z+,C00
	dec		r18
	brne	LOOP0

	; load envelope codes to SRAM 0x210, 16 bytes
	ldi		xh,0x02
	ldi		xl,0x10
	ldi 	zl, low(2*Envelopes)
	ldi 	zh, high(2*Envelopes)
	ldi		r18,0x10
	rcall	_COPY

	; load volume table for amplitude to SRAM 0x220, 16 bytes
	ldi		xl,0x20
	ldi 	zl, low(2*Volumes)
	ldi 	zh, high(2*Volumes)
	ldi		r18,0x10
	rcall	_COPY

	; load volume table for envelopes to SRAM 0x230, 32 bytes
	ldi		xl,0x30
	ldi 	zl, low(2*EVolumes)
	ldi 	zh, high(2*EVolumes)
	ldi		r18,0x20
	rcall	_COPY

	; load register masks to SRAM 0x100, 16 bytes
	clr		xl
	ldi		xh,0x01
	ldi 	zl, low(2*RegsMask)
	ldi 	zh, high(2*RegsMask)
	ldi		r18,0x10
	rcall	_COPY

	// clear register values in SRAM 0x300-0x310
	ldi		r18,0x10
	ldi		ZL,0x00
	ldi		ZH,0x08
LOOP1:
	std		Z+0x20,CC0
	std		Z+0x10,r16
	st		Z+,C00
	dec		r18
	brne	LOOP1
	
	ldi		ZH,0x01		; set high byte of register Z for fast acces to register values
	clr		ZL


	ldi		YH,0x02		; set high byte of register Y for fast acces to volume table
	mov		NoiseAddon,ZH	; load default value = 1 to high bit of noise generator

	// init Timer1
	sts		OCR1AH,C00		; clear OCR values
	sts		OCR1AL,C00
	sts		OCR1BH,C00
	sts		OCR1BL,C00
	sbi		DDRB,b1			; set port B pin 1 to output for PWM (AY channel A)
	sbi		DDRB,b2			; set port B pin 2 to output for PWM (AY channel B)
	ldi		r16,0xA2
	sts		TCCR1A,r16
	ldi		r16,0x19
	sts		TCCR1B,r16
	ldi		r16,0x19
	sts		TCCR1B,r16
	ldi		r18, 0x50
	
	sts		ICR1H,C00
	sts		ICR1L,r18		; set PWM speed 
	; ICR1L value formula (32000000/109375/2 - 1) where 32000000 = 32MHz - AVR oscillator frequency
	; 109375 is for 1.75 MHz version, formula is (PSG frequency / 16) e.g. for 2MHz it is 2000000/16 = 125000
	; Но так как у нас обработка двух AY идет в четном и нечетном тике, то частота таймера должна быть увеличина.

#if CHANNELS == 3
	// init Timer2
	sbi	DDRB,DDB3		; set port B pin 3 to output for PWM (AY channel C)
	ldi	r16,0x83
	sts	TCCR2A,r16
	ldi	r16,0x01
	sts	TCCR2B,r16
#endif

	; set INT0,INT1 ============================================
	ldi		r16, (1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10)	; rising edge
	sts		EICRA, r16
	ldi		r16, (1<<INTF0)|(1<<INTF1)
	out		EIFR, r16		; clear interrupt flags
	ldi		r16, (1<<INT0)|(1<<INT1)
	out		EIMSK, r16		; enable interrupts
	; ==========================================================


	// init constants and variables second part
	ldi		ADDR,0x10
	clr		TNLevel
	clr		OutA
	clr		OutB
	clr		OutC
	mov		TabP,CC0		; set envelope generator disablet by default
	clr		TabE
	clr		BusData
	clr		CntN
	clr		CntAL
	clr		CntAH
	movw	CntBL,CntAL
	movw	CntCL,CntAL
	movw	CntEL,CntAL
	clr		EVal
	sei						; enable global interrupts

_MAIN_LOOP:
	// MAIN LOOP ========================================================================
	in		YL,TIFR1		; check timer1 overflow flag TOV1
	sbrs	YL,TOV1
	rjmp	_MAIN_LOOP		; jump if not set
	out		TIFR1,YL		; clear timer overflow flag


	sbic	CHIP_SELECTED, b1
	rjmp	PROCESS_CHIP1_TICK
	sbi		CHIP_SELECTED, b1
	// sound generation code start (using timer1 overflow flag)
	// MIN cycles: 69
	// MAX cycles: 110

	/////////////////////////////////////////////////////////////////////////////////////
	/// ENVELOPE GENERATOR
	/////////////////////////////////////////////////////////////////////////////////////
	sbrs	TNLevel,b7
	rjmp	NO_ENVELOPE_CHANGED

	// initialize envelope generator after change envelope shape register, only first 1/32 part of the first period!
	lds		YL,AY_REG13		; load envelope shape register value to TabE
	ldd		TabE,Y+0x10		; get envelope code from SRAM
	ldi		TabP,0x1F		; set counter for envelope period
	andi	TNLevel,0x7F	; clear envelope shape change flag
	rjmp	E_NEXT_STEP

NO_ENVELOPE_CHANGED:
	sbrc	TabE,b7			; alternate: cpi	TabE,0x80	; check if envelope generator is disabled
	rjmp	ENVELOPE_GENERATOR_END	; alternate: brcc	ENVELOPE_GENERATOR_END
	sbiw	CntEL,0x01
	brcs	E_NEXT_PERIOD	; jump to init next envelope value if counter overflow (if initial value was 0)
	brne	ENVELOPE_GENERATOR_END	; go to the next step if zero value is not reached
E_NEXT_PERIOD:
	dec		TabP
	brpl	E_NEXT_STEP		; jump to next step if envelope period >= 0
	;init new envelope period
	ldi		TabP,0x1F
	sbrc	TabE,b1
	eor		TabE,ZH			; invert envelope ATTACK bit
	sbrc	TabE,b2
	or		TabE,CC0		; disable envelope generator until new envelope shape register recived
E_NEXT_STEP:
	lds		CntEL,AY_REG11
	lds		CntEH,AY_REG12
	mov		YL,TabP
	sbrs	TabE,b0
	eor		YL,C1F			; invert envelope value if ATTACK bit is not set
	ldd		EVal,Y+0x30		; translate envelope value to volume, read volume value from SRAM 0x230+YL
ENVELOPE_GENERATOR_END:
	/////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////
	/// NOISE GENERATOR
	/////////////////////////////////////////////////////////////////////////////////////
	dec		CntN			; decrease noise period counter
	brpl	NOISE_GENERATOR_END ; skip if noise period is not finished (CntN>=0)
	//init new cycle
	lds		CntN,AY_REG06	; init noise period counter with value in AY register 6
	dec		CntN

	lsr		NoiseAddon
	mov		NoiseAddon,RNGL
	ror		RNGH
	ror		RNGL

	ori		TNLevel,0x38	; set noise bits
	sbrs	RNGL,b0
	andi	TNLevel,0xC7	; reset noise bits
	// make input bit
	lsl		NoiseAddon
	eor		NoiseAddon,RNGL
	lsr		NoiseAddon
NOISE_GENERATOR_END:
	/////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////
	/// TONE GENERATOR
	/////////////////////////////////////////////////////////////////////////////////////
	; all counters are Int16 values (signed)
	// Channel A -------------
	subi	CntAL,0x01		; CntA - 1
	sbci	CntAH,0x00
	brpl	CH_A_NO_CHANGE	; CntA >= 0
	lds		CntAL,AY_REG00	; update channel A tone period counter
	lds		CntAH,AY_REG01
	subi	CntAL,0x01		; CntA - 1
	sbci	CntAH,0x00
	eor		TNLevel,ZH		; TNLevel xor 1 (change logical level of channel A)
CH_A_NO_CHANGE:

	// Channel B -------------
	subi	CntBL,0x01		; CntB - 1
	sbci	CntBH,0x00
	brpl	CH_B_NO_CHANGE	; CntB >= 0
	lds		CntBL,AY_REG02	; update channel B tone period counter
	lds		CntBH,AY_REG03
	subi	CntBL,0x01		; CntB - 1
	sbci	CntBH,0x00
	eor		TNLevel,YH		; TNLevel xor 2 (change logical level of channel B)
CH_B_NO_CHANGE:

	// Channel C -------------
	sbiw	CntCL,0x01		; CntC - 1
	brpl	CH_C_NO_CHANGE	; CntC >= 0
	lds		CntCL,AY_REG04	; update channel C tone period counter
	lds		CntCH,AY_REG05
	sbiw	CntCL,0x01		; CntC - 1
	eor		TNLevel,C04		; TNLevel xor 4 (change logical level of channel C)
CH_C_NO_CHANGE:
	/////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////
	/// MIXER
	/////////////////////////////////////////////////////////////////////////////////////
	lds		TMP,AY_REG07	; Load Mixer AY Register from SRAM
	or		TMP,TNLevel		; Mixer formula = (Mixer Register Tone | TNLevel Tone) & (Mixer Register Noise | TNLevel Noise)
	mov		YL,TMP
	lsl		YL
	swap	YL
	and		TMP,YL
	/////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////
	/// AMPLITUDE CONTROL
	/////////////////////////////////////////////////////////////////////////////////////

	// Channel A
	lds		YL,AY_REG08		; Load Channel A Amplitude register
	mov		OutA,EVal		; set envelope volume as default value
	sbrs	YL,b4			; if bit 4 is not set in amplitude register then translate it to volume
	ldd		OutA,Y+0x20		; load volume value from SRAM 0x220 + YL
	sbrs	TMP,b0			; if channel is disabled in mixer - set volume to zero
	clr		OutA
	
	// Channel B
	lds		YL,AY_REG09		; Load Channel B Amplitude register
	mov		OutB,EVal		; set envelope volume as default value
	sbrs	YL,b4			; if bit 4 is not set in amplitude register then translate it to volume
	ldd		OutB,Y+0x20		; load volume value from SRAM 0x220 + YL
	sbrs	TMP,b1			; if channel is disabled in mixer - set volume to zero
	clr		OutB

	// Channel C
	lds		YL,AY_REG10		; Load Channel C Amplitude register
	mov		OutC,EVal		; set envelope volume as default value
	sbrs	YL,b4			; if bit 4 is not set in amplitude register then translate it to volume
	ldd		OutC,Y+0x20		; load volume value from SRAM 0x220 + YL
	sbrs	TMP,b2			; if channel is disabled in mixer - set volume to zero
	clr		OutC
	rjmp ENDING_MAIN_LOOP

PROCESS_CHIP1_TICK:
	cbi		CHIP_SELECTED, b1




ENDING_MAIN_LOOP:
	// Channel B
#if CHANNELS == 2
// two channel version ----------------------------------------
	mov		YL,OutB
	lsr		OutB			; TMP = TMP - (TMP/4 + TMP/8);
	lsr		OutB
	sub		YL,OutB
	lsr		OutB
	sub		YL,OutB
	add		OutA,YL			; add channel B volume to channels A and C
	add		OutC,YL
// --------------------------------------------------------------
#elif CHANNELS == 3
// three channel version ----------------------------------------
	sts	OCR2A,OutB
// --------------------------------------------------------------
#endif

// --------------------------------------------------------------

	sts		OCR1AL,OutA		; update PWM counters
	sts		OCR1BL,OutC
	rjmp	_MAIN_LOOP
// MAIN LOOP END ====================================================================


// copy routine from flash to SRAM
_COPY:
	lpm		r16,Z+
	st		X+,r16
	dec		r18
	brne	_COPY
	ret

/////////////////////////////////////////////////////////////////
/// AY REGISTERS IN SRAM
/////////////////////////////////////////////////////////////////
	.dseg
	.org	0x0110
;Регистры для первого AY чипа
AY_REG00:
	.byte	1
AY_REG01:
	.byte	1
AY_REG02:
	.byte	1
AY_REG03:
	.byte	1
AY_REG04:
	.byte	1
AY_REG05:
	.byte	1
AY_REG06:
	.byte	1
AY_REG07:
	.byte	1
AY_REG08:
	.byte	1
AY_REG09:
	.byte	1
AY_REG10:
	.byte	1
AY_REG11:
	.byte	1
AY_REG12:
	.byte	1
AY_REG13:
	.byte	1
AY_REG14:
	.byte	1
AY_REG15:
	.byte	1

;Регистры для второго AY чипа
.org	0x0810
AY1_REG00:
	.byte	1
AY1_REG01:
	.byte	1
AY1_REG02:
	.byte	1
AY1_REG03:
	.byte	1
AY1_REG04:
	.byte	1
AY1_REG05:
	.byte	1
AY1_REG06:
	.byte	1
AY1_REG07:
	.byte	1
AY1_REG08:
	.byte	1
AY1_REG09:
	.byte	1
AY1_REG10:
	.byte	1
AY1_REG11:
	.byte	1
AY1_REG12:
	.byte	1
AY1_REG13:
	.byte	1
AY1_REG14:
	.byte	1
AY1_REG15:
	.byte	1