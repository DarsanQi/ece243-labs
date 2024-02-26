#include "address_map_nios2.h"



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

    int left, right;


    while (1)
    {
        //check if there is a sample ready to be read
        if (audiop->rarc <= 0 && audiop->ralc <= 0) { continue; }
        //check if there are empty slots in the output FIFO
        if (audiop->wsrc <= 0 && audiop->wslc <= 0) { continue; }

        //read the sample from the microphone channels
        left = audiop->ldata; 
        right = audiop->rdata;

        //write the sample to the audio output channels
        audiop->ldata = left;
        audiop->rdata = right;
    }   
}