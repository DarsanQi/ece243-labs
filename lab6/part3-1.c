#include "address_map_nios2.h"
#define HIGH 0xFFFFFF
#define LOW 0x0

int mapToNumSamples(int switch_value);

const double c_octave[10] = { 261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25, 587.33, 659.25 };

int main()
{   
    struct audio_t {
        volatile unsigned int control;  // The control/status register
        volatile unsigned char rarc;	// the 8 bit RARC register
        volatile unsigned char ralc;	// the 8 bit RALC register
        volatile unsigned char wsrc;	// the 8 bit WSRC register
        volatile unsigned char wslc;	// the 8 bit WSLC register
        volatile unsigned int ldata;	// the 32 bit (really 24) left data register
        volatile unsigned int rdata;	// the 32 bit (really 24) right data register
    };

    struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);   
    volatile unsigned int* SW_ptr = (unsigned int*)SW_BASE;
    volatile unsigned int* LED_ptr = (unsigned int*)LEDR_BASE;

    int writing_value = HIGH, swtich_value;
    int current_count = 0, count_max;

    while (1)
    {   
        //read the switch value
        swtich_value = *SW_ptr;
        //write to leds
        *LED_ptr = swtich_value;

        //map the switch value to a frequency
        count_max = mapToNumSamples(swtich_value) / 2;

        if (current_count > count_max)
        {
            writing_value = writing_value == HIGH ? LOW : HIGH;
            current_count = 0;
        }
        else 
        {
            current_count++;
        }

        //write the sample to the audio output channels
        audiop->ldata = writing_value;
        audiop->rdata = writing_value;
    }
}


//maps the incoming switch value (0-123) to a frequency (100 to 2000) to a period to a number of 8KHz samples that is the period
int mapToNumSamples(int switch_value) 
{
    double freq; 
    if (switch_value > 511) 
    {
        freq = c_octave[9];
    }
    else if (switch_value > 255)
    {
        freq = c_octave[8];
    }
    else if (switch_value > 127)
    {
        freq = c_octave[7];
    }
    else if (switch_value > 63)
    {
        freq = c_octave[6];
    }
    else if (switch_value > 31)
    {
        freq = c_octave[5];
    }
    else if (switch_value > 15)
    {
        freq = c_octave[4];
    }
    else if (switch_value > 7)
    {
        freq = c_octave[3];
    }
    else if (switch_value > 3)
    {
        freq = c_octave[2];
    }
    else if (switch_value > 1)
    {
        freq = c_octave[1];
    }
    else 
    {
        freq = c_octave[0];
    }
    return 8000 / freq;
}