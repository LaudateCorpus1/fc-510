;----------------------------------------------------------------------------

;Title	: FC-510 prescaler (LMX2324)
;Version: 1.00
;Target	: ATtiny12
;Author	: wubblick@yahoo.com

;AVR Assembler 2.0

;Fuse bits:

;Int RCosc, Startup 4.2ms + 6 CK
;No BOD function

;----------------------------------------------------------------------------

.include "tn12def.inc"

;----------------------------------------------------------------------------

;���������:

.equ N = 256   ;�������� ����������� �������

.equ PRE = 32  ;����������� ������� ����������� ����������
.equ NR = 2    ;����������� ������� Ref (�� ������������)
.equ NB = (N / PRE)
.equ NA = (N - NB * PRE)
.if (NA > NB) || (NB < 3) || (NB > 1023)
.error "������������ ����������� �������!"
.endif

;���� �������� R:

.equ TEST    = (1 << 14) ;����� ������������
.equ RS      = (1 << 13) ;����������������� ���
.equ PD_POL  = (1 << 12) ;����� �������� N
.equ CP_TRI  = (1 << 11) ;� ������ ������������ ������ =1
.equ R_CNTR  = (NR << 1) ;�������� �������� R (2..1023)
.equ R_ADDR  = (1 << 0)  ;����� �������� R

;���� �������� N:

.equ NB_CNTR = (NB << 8) ;�������� �������� NA (0..31, NA <= NB)
.equ NA_CNTR = (NA << 3) ;�������� �������� NB (3..1023)
.equ CNT_RST = (1 << 2)  ;����� ������ ���������
.equ PWDN    = (1 << 1)  ;����� power down
.equ N_ADDR  = (0 << 0)  ;����� �������� N

;��� ��� �������� � ������� R:

.equ REG_R = TEST | PD_POL | CP_TRI | R_CNTR | R_ADDR

;��� ��� �������� � ������� N:

.equ REG_N = NB_CNTR | NA_CNTR | N_ADDR

;----------------------------------------------------------------------------

;Ports definition:

.equ SDATA  = PB0 ;������ SDATA
.equ LE     = PB1 ;������ LE
.equ SCLK   = PB2 ;������ SCLK
.equ NCPB3  = PB3
.equ NCPB4  = PB4

;����������� ����� B:
.equ DIRB   = (1 << SDATA) | (1 << LE) | (1 << SCLK)
;��������� ���������/�������:
.equ PUPB   = 0xFF

;----------------------------------------------------------------------------

;���������� ����������� ����������:

.def tempL = r16
.def tempM = r17
.def tempH = r18
.def Cnt   = r19

;----------------------------------------------------------------------------

.CSEG
.org 0

;�������������:

	ldi	tempL,PUPB
	out	PORTB,tempL
	ldi	tempL,DIRB	
	out	DDRB,tempL

;�������� ���������:

Main:

;�������� �������� N:

	ldi tempL,byte1(REG_N)
	ldi tempM,byte2(REG_N)
	ldi tempH,byte3(REG_N)
	rcall SPI_Load

;�������� �������� R:

	ldi tempL,byte1(REG_R)
	ldi tempM,byte2(REG_R)
	ldi tempH,byte3(REG_R)
	rcall SPI_Load

	sleep
	rjmp Main

;----------------------------------------------------------------------------

;�������� ����� 18 ��� �� tempH:tempM:tempL �� SPI:

SPI_Load:
	cbi	PORTB,LE    ;LE = 0
	ldi Cnt,18
Loop:
	cbi	PORTB,SCLK  ;SCLK = 0
	sbrc tempH,1
	rjmp data1
data0:
	cbi	PORTB,SDATA ;SDATA = 0 ���
	rjmp dataX
data1:
	sbi	PORTB,SDATA ;SDATA = 1
dataX:
    lsl TempL 
	rol TempM
	rol TempH
	sbi	PORTB,SCLK  ;SCLK = 1
	dec	Cnt
	brne Loop

	sbi	PORTB,SDATA ;SDATA = 1
	sbi	PORTB,LE    ;LE = 1
	ret

;----------------------------------------------------------------------------
