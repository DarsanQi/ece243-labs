#include "address_map_nios2.h"


int main() 
{
    volatile unsigned int* LEDR_ptr = (unsigned int*)LEDR_BASE;
    volatile unsigned int* KEY_ptr = (unsigned int*)KEY_BASE;
    //turn off all LEDs

    *LEDR_ptr = 0x0;


    while (1) 
    {
        //poll for edge capture KEY[0]
        if ((1 & *(KEY_ptr + 3)) > 0) 
        {
            //turn on all LEDs
            *LEDR_ptr = 0x3FF;
            //reset the edge capture register
            *(KEY_ptr + 3) = 0x1;
        }

        //poll for edge captuire KEY[1]
        if ((2 & *(KEY_ptr + 3)) > 0) 
        {
            //turn off all LEDs
            *LEDR_ptr = 0x0;
            //reset the edge capture register
            *(KEY_ptr + 3) = 0x2;
        }

    }
}