#pragma OPENCL EXTENSION cl_amd_printf : enable

__kernel void color(
        __global uchar * const output,
        const double left,
        const double right,
        const double upper,
        const double lower,
        const uint cycles
        )
{
        uint x_pos = get_global_id(0);
        uint y_pos = get_global_id(1);
        uint first_color_pos = 3*(x_pos + y_pos * get_global_size(0)); 
        const double x = left  + x_pos*(right - left)/get_global_size(0);
        const double y = upper - y_pos*(upper - lower)/get_global_size(1);
        double real = x;
        double imag = y;


        uint counter = 0;
        double qu;
        double qua = real * real;
        double qub = imag * imag;
        do {
                imag = 2 * real * imag + y;
                real = qua - qub +  x;
                qua = real * real;
                qub = imag * imag;
                qu = qua + qub;
        } while (qu < 1.e23  &&
                 qu > 1.e-23 &&
                 counter++ < cycles);

        
        if (counter >= cycles) {
                // I want the Mandelbrot set to be colored black
                output[first_color_pos]= 0;
                output[first_color_pos+1]= 0;
                output[first_color_pos+2]= 0;
        } else {
                /* Idea behind this: Since we have 32bit color depth, we
                   have 2**32 color values. We devide the whole color set
                   into as many subsets as $counter can have values. Now
                   $counter tells us which subset to take and from this
                   subset we always use the middle element. */
                uint size_part    = 16777216 / cycles;
                uint choosen_part = ((counter * size_part + (counter - 1) * size_part) / 2) ;
//                output[y_pos + x_pos * get_global_size(0)] = choosen_part;
                output[first_color_pos]= choosen_part & 0xff;
                output[first_color_pos+1]= (choosen_part & 0xff00) >> 8;
                output[first_color_pos+2]= (choosen_part & 0xff0000) >> 16;

        }
}
