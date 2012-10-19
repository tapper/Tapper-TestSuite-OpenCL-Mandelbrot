#pragma OPENCL EXTENSION cl_amd_printf : enable

typedef double2 cdouble;
inline cdouble  cmult(cdouble a, cdouble b){
    return (cdouble)( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

__kernel void color(
        __global uint * const output,
        const double left,
        const double right,
        const double upper,
        const double lower,
        const uint cycles
        )
{

        uint x_pos = get_global_id(0);
        uint y_pos = get_global_id(1);
        const double x = left  + x_pos*(right - left)/get_global_size(0);
        const double y = upper - y_pos*(upper - lower)/get_global_size(1);
        cdouble c = (cdouble) (x, y) ;
        cdouble z = 0 ;
        
        uint counter = 0;

        do {
                z = cmult(z,z) + c;
        } while ( length (z) < 2 && counter++ < cycles);


        if (counter >= cycles) {
                // I want the Mandelbrot set to be colored black
                output[y_pos + x_pos * get_global_size(0)]= 0;
        } else {
                /* Idea behind this: Since we have 32bit color depth, we
                   have 2**32 color values. We devide the whole color set
                   into as many subsets as $counter can have values. Now
                   $counter tells us which subset to take and from this
                   subset we always use the middle element. */
                uint size_part    = 16777216 / cycles;
                uint choosen_part = ((counter * size_part + (counter - 1) * size_part) / 2) << 8;
                choosen_part = choosen_part | 0xff;
                output[y_pos + x_pos * get_global_size(0)] = choosen_part;
        }
}
