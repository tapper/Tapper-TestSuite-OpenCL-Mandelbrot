package Mandelbrot;


use common::sense;

use OpenCL;
use File::Slurp;

use constant {
        ZYKLEN           => 1200,
        DIVERGENZGRENZE  => 1.e23,
        KONVERGENZGRENZE => 1.e-23,
};


sub mandelbrot_cl
{
        my ($left, $right, $upper, $lower, $options) = @_;

        
        
        my @platforms = OpenCL::platforms;
        my $platform = $platforms[0];
        my ($width, $height) = ($options->{width}, $options->{height});
        
        my $dev;
        {
                no warnings 'uninitialized';
                if ($options->{device} eq 'CPU') {
                        $dev = OpenCL::DEVICE_TYPE_CPU;
                } elsif ($options->{device} eq 'GPU') {
                        $dev = OpenCL::DEVICE_TYPE_GPU;
                } else {
                        die "Choose GPU or CPU to run on\n";
                }
        }
        my $device=($platform->devices($dev))[0];
        my $ctx = $platform->context(undef, [$device], undef);
        my $queue = $ctx->queue ($device);
        my $data;

        my $src = File::Slurp::read_file('./mandel_opencl.cl');
        my $prog = $ctx->program_with_source ($src);

        # build croaks on compile errors, so catch it and print the compile errors
        eval { $prog->build ($device, "");1 }
          or die $prog->build_log($device);
        my $kernel = $prog->kernel ("color");

        my $output = $ctx->buffer (0, OpenCL::SIZEOF_UINT * $width * $height );


        # set buffer
        $kernel->set_buffer (0, $output);
        $kernel->set_double  (1, $left);
        $kernel->set_double  (2, $right);
        $kernel->set_double  (3, $upper);
        $kernel->set_double  (4, $lower);

        $queue->enqueue_nd_range_kernel ($kernel, undef, [$width, $height], undef );
        $queue->enqueue_read_buffer ($output, 1, 0, OpenCL::SIZEOF_UINT * $width * $height, $data);
        return $data;
}


sub color
{
        my ($x, $y) = @_;
        my ($real, $imag, $c);
        my $counter;

        # $real = $x; $imag = $y;
        # $counter = 0;
        # my $counter;

        my ($a, $b);
        my ($qua, $qub);
        my $qu;
        my $counter;

        $a = $x; $b = $y;
        $counter = 0;
        $qua = $a * $a; $qub = $b * $b;
        do {
                $b = 2 * $a * $b - $y;
                $a = $qua - $qub - $x;
                $qu = ($qua = $a * $a) + ($qub = $b * $b);
        } while ($qu < DIVERGENZGRENZE  and
                 $qu > KONVERGENZGRENZE and
                 $counter++ < ZYKLEN);

        # for (1..ZYKLEN) {
        #         $counter=$_;
        #         $imag = 2 * $real * $imag - $y;
        #         $real = $real**2 - $imag**2 - $x;
        #         $c = $real**2 + $imag**2;
        #         last if $c > 2;
        # }
        if ($counter >= ZYKLEN) {
                # I want the Mandelbrot set to be colored black
                return 0;
        } else {
                # Idea behind this: Since we have 32bit color depth, we
                # have 2**32 color values. We devide the whole color set
                # into as many subsets as $counter can have values. Now
                # $counter tells us which subset to take and from this
                # subset we always use the middle element.
                my $size_part    = 2**32 / ZYKLEN;
                my $choosen_part = ($counter * $size_part + ($counter - 1) * $size_part) / 2;
                return int $choosen_part;
        }
}



sub mandelbrot_perl
{
        my ($left, $right, $upper, $lower, $config) = @_;
        my $x_size = $right*1.0 - $left;
        my $y_size = $upper*1.0 - $lower;

        my $width  = $config->{width};
        my $height = $config->{height};

        my $data;
        for (my $x=0; $x<$width; $x++) {
                my $real = $left+$x*($x_size/$width);
                for (my $y=0; $y<$height; $y++ ) {
                        my $imag = $lower+$y*($y_size/$height);
                        my $color = color($real, $imag);
                        $data->[$x][$y] = $color;
                }
        }
        return $data;
}


1;
