#include "address_map_nios2.h"
#define HIGH 0xFFFFFF
#define LOW 0x0

int mapToNumSamples(int switch_value);


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

    int writing_value = HIGH, switch_value;
    int current_count = 0, count_max;

    while (1)
    {   
        //read the switch value
        switch_value = *SW_ptr;
        //write to leds
        *LED_ptr = switch_value;

        //map the switch value to a frequency
        count_max = mapToNumSamples(switch_value) / 2;

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
    //map the incoming switch value (0-123) to a frequency (100 to 2000)
    int freq = 100 + (switch_value * 15);
    //map the frequency to number of 8KHz samples that is the period
    int num_samples = 8000 / freq;
    return num_samples;
}