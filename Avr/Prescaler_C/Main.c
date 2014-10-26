//----------------------------------------------------------------------------

//Project:         Prescaler (LMX2324)
//Version:         V1.0
//Compiler:        IAR EWAVR 5.30
//Microcontroller: ATtiny25
//E-mail:          wubblick@yahoo.com

//----------------------------------------------------------------------------

//Fuses: 0xD920
//SPI Enable          (SPIEN = 0)
//External clock      (SKSEL3 = 0, SKSEL2 = 0, SKSEL1 = 0, SKSEL0 = 0)  
//Startup 6CK + 65 ms (SUT0 = 0)
//BOD enabled, 4.0V   (BODLEVEL = 0, BODEN = 0)

//----------------------------------------------------------------------------

#include <iotiny25.h>
#include <intrinsics.h>

//----------------------------------------------------------------------------

#define N      256  //�������� ����������� �������

//----------------------------------------------------------------------------

#define PRE     32  //����������� ������� ����������� ����������
#define NB  (N / PRE)
#define NA  (N - NB * PRE)
#if (NA > NB) || (NB < 3) || (NB > 1023)
#error"������������ ����������� �������!"
#endif

#define BITS    18  //����������� ���������

//���� �������� R:

#define TEST     1  //����� ������������
#define RS       0  //����������������� ���
#define PD_POL   1  //����� �������� N
#define CP_TRI   1  //� ������ ������������ ������ =1
#define R_CNTR   2  //�������� �������� R (2..1023)
#define R_ADDR   1  //����� �������� R

//���� �������� N:

#define NB_CNTR  NA //�������� �������� NA (0..31, NA <= NB)
#define NA_CNTR  NB //�������� �������� NB (3..1023)
#define CNT_RST  0  //����� ������ ���������
#define PWDN     0  //����� power down
#define N_ADDR   0  //����� �������� N

//------------------------------- ����� : ------------------------------------

#define SDATA  (1 << PB0)
#define LE     (1 << PB1)
#define SCLK   (1 << PB2)
#define NC     (1 << PB3)
#define LED    (1 << PB4)

//�����������:
#define I_DDRB  (SDATA | LE | SCLK | LED)
//��������� ����������/pull-ups:
#define I_PORTB (SDATA | LE | SCLK | NC | LED)
//�������:
#define Port_SDATA_0 (PORTB &= ~SDATA)
#define Port_SDATA_1 (PORTB |= SDATA)
#define Port_LE_0    (PORTB &= ~LE)
#define Port_LE_1    (PORTB |= LE)
#define Port_SCLK_0  (PORTB &= ~SCLK)
#define Port_SCLK_1  (PORTB |= SCLK)
#define Port_LED_0   (PORTB &= ~SCLOCK)
#define Port_LED_1   (PORTB |= SCLOCK)

//-------------------------- ��������� �������: ------------------------------

void main(void);
void SPI_Load(long n);

//------------------------- �������� ���������: ------------------------------

void main(void)
{
  DDRB  = I_DDRB;
  PORTB = I_PORTB;
  //�������� �������� N:
  SPI_Load((NB_CNTR <<  8) |
           (NA_CNTR <<  3) |
           (CNT_RST <<  2) |
              (PWDN <<  1) |
            (N_ADDR <<  0));
  //�������� �������� R:
  SPI_Load(   (TEST << 14) |
                (RS << 13) |
            (PD_POL << 12) |
            (CP_TRI << 11) |
            (R_CNTR <<  1) |
            (R_ADDR <<  0));
  __sleep();
}

//------------------ ������� �������� BITS ����� �� SPI: ---------------------

void SPI_Load(long n)
{
  Port_LE_0;
  for(char i = 0; i < BITS; i++)
  {
    Port_SCLK_0;
    if(n & (1L << (BITS - 1)))
      Port_SDATA_1;
        else Port_SDATA_0;
    n = n << 1;    
    Port_SCLK_1;
  }
  Port_SDATA_1;
  Port_LE_1;
}

//----------------------------------------------------------------------------
