#include "address_map_nios2.h"


const double DAMPING_FACTOR = 0.5;
const double N = 8000*0.4;

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
const int bufferSize = 3200;
int main() 
{

    int out, input, bufferIndex = 0;
    int buffer[bufferSize];

    //clear the buffer array
    for (int i = 0; i < bufferSize; i++) 
    {
        buffer[i] = 0;
    }


    while (1)
    {
        //check if there is a sample ready to be read
        if (audiop->rarc <= 0 && audiop->ralc <= 0) { continue; }
        //check if there are empty slots in the output FIFO
        if (audiop->wsrc <= 0 && audiop->wslc <= 0) { continue; }

        //get input (same across both channels)
        input = audiop->ldata;
        //caclulate the echoed output = input + damping factor * previous output with a delay of N samples
        out = input + DAMPING_FACTOR * buffer[bufferIndex];
        buffer[bufferIndex] = out;
        bufferIndex = bufferIndex == bufferSize - 1 ? 0 : bufferIndex + 1;
        //write the echoed output to the output FIFO
        audiop->ldata = out;
        audiop->rdata = out;
    }   
}