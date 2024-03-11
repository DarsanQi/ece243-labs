#include <stdbool.h>
#include <stdlib.h>

int pixel_buffer_start; // global variable

void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void swap(int *a, int *b);


int main(void)
{
    volatile int * pixel_ctrl_ptr = (volatile int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    //draw a green line at the top of the screen
    const int x0 = 0, x1 = 319;
    int y = 0;
    draw_line(x0, y, x1, y, 0x07E0); // this line is green
    bool moving_down = true;

    while (true)
    {
        //write a 1 to the buffer address register to enable the swap
        *(pixel_ctrl_ptr) = 1;
        
        //wait for a swap to occur (0 written to the last bit of the status register)
        while (*(pixel_ctrl_ptr + 3) & 0x1);

        //clear the screen
        clear_screen();
        //move the line
        if (moving_down)
        {
            y++;
            if (y == 239)
                moving_down = false;
        }
        else
        {
            y--;
            if (y == 0)
                moving_down = true;
        }
        

        //draw the line
        draw_line(x0, y, x1, y, 0x07E0); // this line is green
    }
}

// code not shown for clear_screen() and draw_line() subroutines

void clear_screen()
{
    int x, y;
    for (x = 0; x < 320; x++)
        for (y = 0; y < 240; y++)
            plot_pixel(x, y, 0x0000); // black
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

    one_pixel_address = (short int*) (pixel_buffer_start + (y << 10) + (x << 1));

    *one_pixel_address = line_color;
}

//implement Bresenham's line drawing algorithm
void draw_line(int x0, int y0, int x1, int y1, short int line_color)
{
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);
    if (is_steep)
    {
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1)
    {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }

    int dx = x1 - x0;
    int dy = abs(y1 - y0);
    int error = - (dx / 2);
    int y = y0;
    int y_step;
    if (y0 < y1)
        y_step = 1;
    else
        y_step = -1;

    for (int x = x0; x <= x1; x++)
    {
        if (is_steep)
            plot_pixel(y, x, line_color);
        else
            plot_pixel(x, y, line_color);
        error = error + dy;
        if (error > 0)
        {
            y = y + y_step;
            error = error - dx;
        }
    }
}

void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

