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
#define VOLUME_TABLE 0	; 1 - AY, 1 - YM, 2 - ALTERNATE volume table
#define INT_32MHz 0
#define INT_37MHz 1
#define EXT_40MHz 0
#define EXT_48MHz 0
#define EXT_50MHz 0
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

.def OutA0			= r0
.def OutC0			= r1
.def OutA1			= r2
.def CntN			= r3
.def OutB			= r4
.def BusOut1		= r5
.def NoiseAddon		= r6
.def C00			= r7
.def CC0			= r8
.def TabE_AY0		= r9
.def OutC1			= r10
.def EVal_AY1		= r11
.def EVal_AY0		= r12
.def C21			= r13
.def RNGL			= r14
.def RNGH			= r15
.def TNLevel_AY1	= r16
.def BusOut2		= r17
.def TabP_AY0		= r18
.def TNLevel_AY0	= r19
.def BusData		= r20
.def TMP			= r21
.def TabE_AY1		= r22
.def TabP_AY1		= r23
.def CntEL_AY0		= r24
.def CntEH_AY0		= r25
.def CntEL_AY1		= r26
.def CntEH_AY1		= r27
.def ADDR			= r30

; ==============================================
; LGT8F328P REGISTER DEFINITIONS
; ==============================================
; Memory-mapped I/O addresses for LGT8F328P
.equ CCP     = 0x34      ; Configuration Change Protection
.equ CLKMSR  = 0x105     ; Clock Main Settings Register
.equ BCR     = 0x107     ; Boot Control Register
.equ BOOTEND = 0x108     ; Boot End Address
.equ BODCR   = 0x104     ; BOD Control Register

.equ PMCR   = 0xF2
.equ PMCE   = 7
.equ CLKFS  = 6
.equ CLKSS  = 5
.equ WCLKS  = 4
.equ WCES   = 4
.equ OSCKEN = 3
.equ OSCMEN = 2
.equ RCKEN  = 1
.equ RCMEN  = 0

.equ PMX2   = 0xF0
.equ IOCR   = 0xF0
.equ IOCE   = 7
.equ STSC1  = 6
.equ STSC0  = 5
.equ XIEN   = 2
.equ E6EN   = 1
.equ REFIOEN = 1
.equ C6EN   = 0
.equ RSTIOEN = 0

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

;----------------------------------------------------------------
; DSU (Digital Signal Co-processor) Register Definition
;----------------------------------------------------------------
.equ DSCR   = 0x20
.equ DSUEN  = 7
.equ DSMM   = 6
.equ DSD1   = 5
.equ DSD0   = 4
.equ DSZ    = 2 ;С этим флагом не ясно. Ошибка в описании
.equ DSN    = 1
.equ DSC    = 0

.equ DSIR   = 0x21

.equ DSSD   = 0x22
.equ DSDX   = 0x30
.equ DSDY   = 0x31
.equ DSAL   = 0x58
.equ DSAH   = 0x59

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
	ldi		ZH, 0x01
	ldi		r20, 0x02
	out		EIFR, r20			; 1 - clear flags
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
	ldi		ZH,high(AY1_REG00)
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
	in		C00, SREG			; 1

	and		BusOut1, CC0
	or		BusData, BusOut1	; 1
	mov		BusOut1, BusData	; 1
	com		BusOut1				; 1
	ldi		ZH, 0x01
	ld		BusOut2, Z			; 2 - load mask

	sbic	CHIP_SELECTED, b0
	ldi		ZH, high(AY1_REG00)

	std		Z+0x20, BusOut1		; 2 - save inverted
	and		BusData, BusOut2	; 1 - apply mask
	mov		BusOut2, BusOut1	; 1
	and		BusOut2, CC0		; 1 - extract bits 6-7

	std		Z+0x30, BusOut2		; 2 - save high bits
	std		Z+0x10, BusData		; 2 - save value

	; Проверка регистра 13 через прямое сравнение
	cpi		ADDR, 0x0D			; 1
	brne	NO_ENVELOPE_CHANGED_P; 1/2

	sbis	CHIP_SELECTED, b0
	ori		TNLevel_AY0, 0x80
	sbic	CHIP_SELECTED, b0
	ori		TNLevel_AY1, 0x80

NO_ENVELOPE_CHANGED_P:
	out		SREG, C00		; 1
	clr		C00
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
	ldi		ZH,high(AY1_REG00)
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
	cli
    ;Отключаем watchdog
    ldi     r16, 0x00
    sts     WDTCSR, r16


#if INT_32MHz == 1 || INT_37MHz == 1
	;Unlock protected registers (LGT specific)
    ldi     r16, 0xD8
    sts     CCP, r16          ; Enable configuration changes
    ;Configure clock: 32MHz internal, divisor = 1
    ldi     r16, 0x80
    sts     CLKPR, r16        ; Enable CLKPR changes

    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, 0x00
    sts     CLKPR, r16        ; Divisor = 1 (32MHz)

    ;Select internal 32MHz oscillator
    ldi     r16, 0xD8
    sts     CCP, r16
    ldi     r16, 0x04
    sts     CLKMSR, r16       ; Internal 32MHz oscillator

	#if INT_37MHz == 1
		;Разгоняем внутренний генератор
		ldi r16, 0xE0
		sts OSCCAL, r16
	#endif

#elif EXT_40MHz == 1 || EXT_48MHz == 1 || EXT_50MHz == 1
	;Переходим на внешний генератор
    ldi     r16, (1<<PMCE)
	sts		PMCR,r16		;разрешить выбор источника тактирования
	ldi     r16, (1<<2) | (1<<5)
	sts		PMCR,r16		;External high frequency crystal
	ldi     r16, (1<<WCES)
	sts		PMX2,r16		;разрешить изменения
	ldi     r16, (1<<XIEN)
	sts		PMX2,r16		;разрешить вход тактовой частоты от кварц. генератора
	ldi     r16, (1<<PMCE)
	sts		CLKPR,r16		;разрешить изменение
	ldi     r16, (1<<5)
	sts		CLKPR,r16		;делитель =1 и вывод clk
#endif

	ldi	r16, 0xFF
wait:
	dec r16
    brne wait

    ;Отключаем загрузчик
    ldi     r16, 0x03         ; BOOTSZ=11, BOOTRST=0
    sts     BCR, r16

    ;Устанавливаем границу загрузчика (опционально)
    ldi     r16, 0x7F
    sts     BOOTEND, r16

    ;Включаем uDSU в режиме быстрого доступа
    ldi     r16, 0x80
    sts     DSCR, r16

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
	ldi		r16,0x21
	mov		C21,r16
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

	// clear register values in SRAM 0x310-0x33F
	ldi		r18,0x10
	ldi		ZL,low (AY1_REG00)
	ldi		ZH,high(AY1_REG00)
LOOP1:
	std		Z+0x20,CC0
	std		Z+0x10,r16
	st		Z+,C00
	dec		r18
	brne	LOOP1

	// clear counter values in SRAM 0x400-0x416
	ldi		r18,0x10
	ldi		ZL,low (AY0_CntAL)
	ldi		ZH,high(AY0_CntAL)
LOOP2:
	st		Z+,C00
	dec		r18
	brne	LOOP2

	ldi		ZH,0x01		; set high byte of register Z for fast acces to register values
	clr		ZL

	mov		NoiseAddon,ZH	; load default value = 1 to high bit of noise generator

	// init Timer1
	sts		OCR1AH,C00		; clear OCR values
	sts		OCR1AL,C00
	sts		OCR1BH,C00
	sts		OCR1BL,C00
	sbi		DDRB,b1			; set port B pin 1 to output for PWM (AY channel A)
	sbi		DDRB,b2			; set port B pin 2 to output for PWM (AY channel B)

	; ===== АВТОКАЛИБРОВКА ЧАСТОТЫ ЯДРА ПО ВНЕШНЕМУ ЭТАЛОНУ 1.75МГц НА T1 (PD5) =====
	; Считаем число фронтов эталона (N_ref) за точно известное число тактов
	; ядра (N_cpu = 2000*256 = 512000), затем ICR1 = 4096000/N_ref - 1, где
	; 4096000 = 1750000 * 512000 / 218750 (218750 = 2*109375 - целевая частота
	; тиков главного цикла). Если эталон не подключён (N_ref=0) или результат
	; не влезает в байт - используется штатное значение ICR1 из блока #if ниже.
	; флаг успеха калибровки (0 = неудача/эталон не подключен)
	clr		r0				

	; Timer1 - внешний счётчик фронтов эталона по ноге T1 (PD5)
	clr		r16
	sts		TCCR1A, r16
	clr		r16
	sts		TCNT1H, r16
	sts		TCNT1L, r16
	ldi		r16, (1<<CS12)|(1<<CS11)|(1<<CS10)	; внешний клок на T1, по фронту
	sts		TCCR1B, r16

	; Timer0 - внутренние "ворота", предделитель = 1
	clr		r16
	out		TCCR0A, r16
	clr		r16
	out		TCNT0, r16
	ldi		r16, (1<<TOV0)
	out		TIFR0, r16				; сброс флага переполнения
	ldi		r16, (1<<CS00)			; внутренний клок, без предделителя
	out		TCCR0B, r16

	; ждём ровно 2000 переполнений Timer0 => 2000*256 = 512000 тактов ядра
	ldi		r26, low(2000)
	ldi		r27, high(2000)
CALIB_WAIT:
	in		r16, TIFR0
	sbrs	r16, TOV0
	rjmp	CALIB_WAIT
	ldi		r16, (1<<TOV0)
	out		TIFR0, r16
	sbiw	r26, 1
	brne	CALIB_WAIT

	; останов таймеров, N_ref = TCNT1
	clr		r16
	sts		TCCR0B, r16
	sts		TCCR1B, r16
	lds		r20, TCNT1L			; N_ref low
	lds		r21, TCNT1H			; N_ref high
	clr		r16
	sts		TCNT1H, r16
	sts		TCNT1L, r16

	; N_ref == 0 -> эталон не подключен, калибровку пропускаем
	tst		r20
	brne	CALIB_DO
	tst		r21
	breq	CALIB_END

CALIB_DO:
	; целочисленное деление 4096000 / N_ref методом повторного вычитания,
	; с округлением к ближайшему (не отбрасыванием остатка вниз) - иначе
	; систематическая ошибка ICR1 на ~0.5% (при ICR1~200 одна ступенька
	; отбрасывания - это и есть примерно такая доля)
	ldi		r22, 0x00		; numL
	ldi		r23, 0x80		; numM
	ldi		r18, 0x3E		; numH   (numH:numM:numL = 4096000)

	; прибавляем N_ref/2 к делимому - округление до ближайшего вместо
	; отбрасывания остатка
	mov		r26, r20
	mov		r27, r21
	lsr		r27
	ror		r26
	add		r22, r26
	adc		r23, r27
	adc		r18, C00

	clr		r24				; quotL
	clr		r25				; quotH

CALIB_DIV_LOOP:
	tst		r18						; numH == 0 ?
	brne	CALIB_DIV_SUB			; num >= 65536 > N_ref - точно вычитаем
	cp		r22, r20				; сравнение (numM:numL) с (denH:denL)
	cpc		r23, r21
	brlo	CALIB_DIV_DONE

CALIB_DIV_SUB:
	sub		r22, r20
	sbc		r23, r21
	sbc		r18, C00
	inc		r24
	brne	CALIB_DIV_LOOP
	inc		r25
	rjmp	CALIB_DIV_LOOP

CALIB_DIV_DONE:
	subi	r24, 1					; ICR1 = quotient - 1
	sbci	r25, 0

	tst		r25						; результат должен помещаться в 1 байт
	brne	CALIB_END				; иначе - недостоверно, используем штатное значение

	mov		r28, r24				; сохранить вычисленный ICR1
	com		r0					; выставить флаг успеха (r0 был 0 -> станет 0xFF)

CALIB_END:
	; ===== КОНЕЦ АВТОКАЛИБРОВКИ =====

	ldi		r16,0xA2
	sts		TCCR1A,r16
	ldi		r16,0x19
	sts		TCCR1B,r16

#if INT_32MHz == 1
	ldi		r18, 0x91
#elif INT_37MHz == 1
	ldi		r18, 0xAD
#elif EXT_40MHz == 1
	ldi		r18, 0xB6
#elif EXT_48MHz == 1
	ldi		r18, 0xDA
#elif EXT_50MHz == 1
	ldi		r18, 0xE5
#endif
	tst		r0				; если автокалибровка успешна - используем её результат
	breq	NO_CALIBRATION
	mov		r18, r28
NO_CALIBRATION:
	sts		ICR1H,C00
	sts		ICR1L,r18		; set PWM speed
	; ICR1L value formula (32000000/109375/2 - 1) where 32000000 = 32MHz - AVR oscillator frequency
	; 109375 is for 1.75 MHz version, formula is (PSG frequency / 16) e.g. for 2MHz it is 2000000/16 = 125000

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
	clr		TNLevel_AY0
	clr		TNLevel_AY1
	clr		OutA0
	clr		OutB
	clr		OutC0
	clr		OutA1
	clr		OutC1
	mov		TabP_AY0,CC0		; set envelope generator disablet by default
	mov		TabP_AY1,CC0
	clr		TabE_AY0
	clr		TabE_AY1
	clr		CntN
	clr		CntEL_AY1
	clr		CntEH_AY1
	clr		CntEL_AY0
	clr		CntEH_AY0
	clr		EVal_AY0
	clr		EVal_AY1
	; Инициализация DY = 0x0001
	ldi		YH, 0x04
	ldi		YL, low(ConstL)
	ldi		r16, 0x02
	st		Y,  r16
	ldi		r16, 0x00
	std		Y+1, r16
	ldi		YH, 0x24
	ld		r1, Y
	ldi		YH,0x02			; set high byte of register Y for fast acces to volume table

	sei						; enable global interrupts

_MAIN_LOOP:
	in		YL, TIFR1		; check timer1 overflow flag TOV1
	sbrs	YL, TOV1
	rjmp	_MAIN_LOOP		; jump if not set
	out		TIFR1, YL		; clear timer overflow flag

; === NOISE GENERATOR (общий для обоих AY) ===
	dec		CntN				; decrease noise period counter
	brpl	NOISE_GENERATOR_END ; skip if noise period is not finished (CntN>=0)
	lds		CntN,AY0_REG06		; init noise period counter with value in AY register 6
	lds		TMP,AY1_REG06
	cp		CntN, TMP
	brge	LESS
	mov		CntN, TMP
LESS:
	dec		CntN
	lsr		NoiseAddon
	mov		NoiseAddon,RNGL
	ror		RNGH
	ror		RNGL
	ori		TNLevel_AY0,0x38	; set noise bitsP
	ori		TNLevel_AY1,0x38	; set noise bitsP
	sbrs	RNGL,b0
	andi	TNLevel_AY0,0xC7	; reset noise bits
	sbrs	RNGL,b0
	andi	TNLevel_AY1,0xC7	; reset noise bits
	lsl		NoiseAddon
	eor		NoiseAddon,RNGL
	lsr		NoiseAddon
NOISE_GENERATOR_END:

;============================================
;=======ENVELOPE_GENERATOR_AY0===============
;============================================
	sbrs	TNLevel_AY0, b7
	rjmp	NO_ENVELOPE_CHANGED_AY0

	; initialize envelope generator
	lds		YL, AY0_REG13
	ldd		TabE_AY0, Y+0x10
	ldi		TabP_AY0, 0x1F
	andi	TNLevel_AY0, 0x7F
	rjmp	E_NEXT_STEP_AY0

NO_ENVELOPE_CHANGED_AY0:
	sbrc	TabE_AY0, b7
	rjmp	ENVELOPE_GENERATOR_END_AY0
	sbiw	CntEL_AY0, 0x01
	brlt	E_NEXT_PERIOD_AY0
	brne	ENVELOPE_GENERATOR_END_AY0

E_NEXT_PERIOD_AY0:
	dec		TabP_AY0
	brpl	E_NEXT_STEP_AY0
	ldi		TabP_AY0, 0x1F
	sbrc	TabE_AY0, b1
	eor		TabE_AY0, ZH
	sbrc	TabE_AY0, b2
	or		TabE_AY0, CC0

E_NEXT_STEP_AY0:
	lds		CntEL_AY0, AY0_REG11
	lds		CntEH_AY0, AY0_REG12
	mov		YL, TabP_AY0
	ldi		TMP, 0x1F
	sbrs	TabE_AY0, b0
	eor		YL, TMP
	ldd		EVal_AY0, Y+0x30

ENVELOPE_GENERATOR_END_AY0:

;============================================
;=======ENVELOPE_GENERATOR_AY1===============
;============================================
	sbrs	TNLevel_AY1, b7
	rjmp	NO_ENVELOPE_CHANGED_AY1

	;initialize_envelope_generator_AY1:
	lds		YL, AY1_REG13
	ldd		TabE_AY1, Y+0x10
	ldi		TabP_AY1, 0x1F
	andi	TNLevel_AY1, 0x7F
	rjmp	E_NEXT_STEP_AY1

NO_ENVELOPE_CHANGED_AY1:
	sbrc	TabE_AY1, b7
	rjmp	ENVELOPE_GENERATOR_END_AY1
	sbiw	CntEL_AY1, 0x01
	brlt	E_NEXT_PERIOD_AY1
	brne	ENVELOPE_GENERATOR_END_AY1

E_NEXT_PERIOD_AY1:
	dec		TabP_AY1
	brpl	E_NEXT_STEP_AY1
	ldi		TabP_AY1, 0x1F
	sbrc	TabE_AY1, b1
	eor		TabE_AY1, ZH
	sbrc	TabE_AY1, b2
	or		TabE_AY1, CC0

E_NEXT_STEP_AY1:
	lds		CntEL_AY1, AY1_REG11
	lds		CntEH_AY1, AY1_REG12
	mov		YL, TabP_AY1
	ldi		TMP, 0x1F
	sbrs	TabE_AY1, b0
	eor		YL, TMP
	ldd		EVal_AY1, Y+0x30

ENVELOPE_GENERATOR_END_AY1:

	sbis	CHIP_SELECTED, b1
	rjmp	GENERATORS_AY1

;============================================
;=======TONE_GENERATOR_AY0===============
;============================================
	; Channel A
	ldi     YH, 0x21
	ldi     YL, low(AY0_CntAL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_A_NO_CHANGE_AY0
	ldi     YL, low(AY0_REG00)
	ld      r0, Y
	sts     0x21, C21
	eor     TNLevel_AY0, ZH
CH_A_NO_CHANGE_AY0:
	ldi     YL, low(AY0_CntAL)
	st      Y, r2

	; Channel B
	ldi     YL, low(AY0_CntBL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_B_NO_CHANGE_AY0
	ldi     YL, low(AY0_REG02)
	ld      r0, Y
	sts     0x21, C21
	ldi		TMP, 0x02
	eor     TNLevel_AY0, TMP
CH_B_NO_CHANGE_AY0:
	ldi     YL, low(AY0_CntBL)
	st      Y, r2

	; Channel C
	ldi     YL, low(AY0_CntCL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_C_NO_CHANGE_AY0
	ldi     YL, low(AY0_REG04)
	ld      r0, Y
	sts     0x21, C21
	ldi		TMP, 0x04
	eor     TNLevel_AY0, TMP
CH_C_NO_CHANGE_AY0:
	ldi     YL, low(AY0_CntCL)
	st      Y, r2
	cbi		CHIP_SELECTED, b1
	rjmp	GENERATORS_END

GENERATORS_AY1:

;============================================
;=======TONE_GENERATOR_AY1===============
;============================================
	ldi     YH, 0x21

	; Channel A
	ldi     YL, low(AY1_CntAL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_A_NO_CHANGE_AY1
	ldi     YH, 0x23
	ldi     YL, low(AY1_REG00)
	ld      r0, Y
	sts     0x21, C21
	eor     TNLevel_AY1, ZH
	ldi     YH, 0x21
CH_A_NO_CHANGE_AY1:
	ldi     YL, low(AY1_CntAL)
	st      Y, r2

	; Channel B
	ldi     YL, low(AY1_CntBL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_B_NO_CHANGE_AY1
	ldi     YH, 0x23
	ldi     YL, low(AY1_REG02)
	ld      r0, Y
	sts     0x21, C21
	ldi		TMP, 0x02
	eor     TNLevel_AY1, TMP
	ldi     YH, 0x21
CH_B_NO_CHANGE_AY1:
	ldi     YL, low(AY1_CntBL)
	st      Y, r2

	; Channel C
	ldi     YL, low(AY1_CntCL)
	ld      r0, Y
	sts     0x21, C21
	sbis    0x00, 1
	rjmp    CH_C_NO_CHANGE_AY1
	ldi     YH, 0x23
	ldi     YL, low(AY1_REG04)
	ld      r0, Y
	sts     0x21, C21
	ldi		TMP, 0x04
	eor     TNLevel_AY1,TMP
	ldi     YH, 0x21
CH_C_NO_CHANGE_AY1:
	ldi     YL, low(AY1_CntCL)
	st      Y, r2
	sbi		CHIP_SELECTED, b1

GENERATORS_END:

	; === MIXER AY 0===
	lds		TMP, AY0_REG07
	or		TMP, TNLevel_AY0
	mov		YL, TMP
	lsl		YL
	swap	YL
	and		TMP, YL

	; === AMPLITUDE CONTROL AY0===
	ldi     YH, 0x02

	; Channel A
	lds		YL, AY0_REG08
	mov		OutA0, EVal_AY0
	sbrs	YL, b4
	ldd		OutA0, Y+0x20
	sbrs	TMP, b0
	clr		OutA0

	; Channel B
	lds		YL, AY0_REG09
	mov		OutB, EVal_AY0
	sbrs	YL, b4
	ldd		OutB, Y+0x20
	sbrs	TMP, b1
	clr		OutB

	; Channel C
	lds		YL, AY0_REG10
	mov		OutC0, EVal_AY0
	sbrs	YL, b4
	ldd		OutC0, Y+0x20
	sbrs	TMP, b2
	clr		OutC0

	; Mix channels
	mov		YL, OutB
	lsr		OutB
	lsr		OutB
	sub		YL, OutB
	lsr		OutB
	sub		YL, OutB
	add		OutA0, YL
	add		OutC0, YL

	; === MIXER AY 1===
	lds		TMP, AY1_REG07
	or		TMP, TNLevel_AY1
	mov		YL, TMP
	lsl		YL
	swap	YL
	and		TMP, YL

	; === AMPLITUDE CONTROL AY1===

	; Channel A
	lds		YL, AY1_REG08
	mov		OutA1, EVal_AY1
	sbrs	YL, b4
	ldd		OutA1, Y+0x20
	sbrs	TMP, b0
	clr		OutA1

	; Channel B
	lds		YL, AY1_REG09
	mov		OutB, EVal_AY1
	sbrs	YL, b4
	ldd		OutB, Y+0x20
	sbrs	TMP, b1
	clr		OutB

	; Channel C
	lds		YL, AY1_REG10
	mov		OutC1, EVal_AY1
	sbrs	YL, b4
	ldd		OutC1, Y+0x20
	sbrs	TMP, b2
	clr		OutC1

	; Mix channels
	mov		YL, OutB
	lsr		OutB
	lsr		OutB
	sub		YL, OutB
	lsr		OutB
	sub		YL, OutB
	add		OutA1, YL
	add		OutC1, YL

	; === СМЕШИВАНИЕ ВЫХОДОВ AY0 и AY1 ===
	add     OutA0, OutA1
	add     OutC0, OutC1

	sts		OCR1AL, OutA0
	sts		OCR1BL, OutC0
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
AY0_REG00:
	.byte	1
AY0_REG01:
	.byte	1
AY0_REG02:
	.byte	1
AY0_REG03:
	.byte	1
AY0_REG04:
	.byte	1
AY0_REG05:
	.byte	1
AY0_REG06:
	.byte	1
AY0_REG07:
	.byte	1
AY0_REG08:
	.byte	1
AY0_REG09:
	.byte	1
AY0_REG10:
	.byte	1
AY0_REG11:
	.byte	1
AY0_REG12:
	.byte	1
AY0_REG13:
	.byte	1
AY0_REG14:
	.byte	1
AY0_REG15:
	.byte	1

.org	0x0260
;Состояния генераторов для AY0
AY0_CntAL:		.byte	1
AY0_CntAH:		.byte	1
AY0_CntBL:		.byte	1
AY0_CntBH:		.byte	1
AY0_CntCL:		.byte	1
AY0_CntCH:		.byte	1

;Состояния генераторов для AY1
AY1_CntAL:		.byte	1
AY1_CntAH:		.byte	1
AY1_CntBL:		.byte	1
AY1_CntBH:		.byte	1
AY1_CntCL:		.byte	1
AY1_CntCH:		.byte	1

ConstL:			.byte	1
ConstH:			.byte	1

;Регистры для второго AY чипа
	.org	0x0310
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
