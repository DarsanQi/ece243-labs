#include <stdbool.h>
#include <stdlib.h>

volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void swap(int *a, int *b);
void wait_for_vsync();


int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    int x_box[8], y_box[8], dx[8], dy[8];
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    short int box_color[8] = { 0xF81F, 0x07E0, 0x001F, 0xF800, 0xFFFF, 0x07FF, 0xF81F, 0x07E0 };

    for (int i = 0; i < 8; i++)
    {
        x_box[i] = rand() % 238;
        y_box[i] = rand() % 318;
        dx[i] = (rand() % 2) ? 1 : -1;
        dy[i] = (rand() % 2) ? 1 : -1;
    }

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        clear_screen();
        // code for drawing the boxes and lines 
        for (int i = 0; i < 8; i++)
        {
            plot_pixel(x_box[i], y_box[i], box_color[i]);
            plot_pixel(x_box[i] + 1, y_box[i], box_color[i]);
            plot_pixel(x_box[i], y_box[i] + 1, box_color[i]);
            plot_pixel(x_box[i] + 1, y_box[i] + 1, box_color[i]);
        }

        //draw line neon green
        for (int i = 0; i < 7; i++)
        {
            draw_line(x_box[i], y_box[i], x_box[i + 1], y_box[i + 1], 0x07E0);
        }
    

        // code for updating the locations of boxes 
        for (int i = 0; i < 8; i++)
        {
            x_box[i] = x_box[i] + dx[i];
            y_box[i] = y_box[i] + dy[i];

            //check out of range y
            if (y_box[i] == -1)
            {
                y_box[i] = 0;
                dy[i] = -dy[i];
            }
            else if (y_box[i] + 1 == 240)
            {
                y_box[i] = 238;
                dy[i] = -dy[i];
            }

            //check out of range x
            if (x_box[i] == -1)
            {
                x_box[i] = 0;
                dx[i] = -dx[i];
            }
            else if (x_box[i] + 1 == 320)
            {
                x_box[i] = 318;
                dx[i] = -dx[i];
            }
        }

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

void wait_for_vsync()
{
    volatile int * pixel_ctrl_ptr = (volatile int*) 0xFF203020; // pixel controller
    int status;

    *pixel_ctrl_ptr = 1; // start the synchronization process

    while (*(pixel_ctrl_ptr + 3) & 0x1); // wait for the sychronization process to complete
}

// code for subroutines (not shown)

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;
        
        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
        
        *one_pixel_address = line_color;
}

void clear_screen()
{
    int x, y;
    for (x = 0; x < 320; x++)
        for (y = 0; y < 240; y++)
            plot_pixel(x, y, 0x0000); // black
}


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

