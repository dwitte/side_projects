#include <stdint-gcc.h>

void kmain(void)
{
	extern uint32_t magic;

	if ( magic != 0x2BADB002 )
	{
		
	}

	volatile unsigned char *videoram = (unsigned char *)0xB8000;
	videoram[0] = 65;
	videoram[1] = 0x07;
}
