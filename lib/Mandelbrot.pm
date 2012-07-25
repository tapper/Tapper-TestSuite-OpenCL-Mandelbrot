package Mandelbrot;

our $VERSION=1;

use common::sense;

use OpenCL;
use File::Slurp;
use Mandelbrot::OpenCL;

use constant {
        ZYKLEN           => 1200,
        DIVERGENZGRENZE  => 1.e23,
        KONVERGENZGRENZE => 1.e-23,
};


sub mandelbrot_cl
{
        my ($left, $right, $upper, $lower, $options) = @_;

        my $opencl = Mandelbrot::OpenCL->instance();
        my ($width, $height) = ($options->{width}, $options->{height});
        my ($kernel, $queue, $output) = $opencl->prepare($options);

        # set buffer
        $kernel->set_buffer (0, $output);
        $kernel->set_double  (1, $left);
        $kernel->set_double  (2, $right);
        $kernel->set_double  (3, $upper);
        $kernel->set_double  (4, $lower);
        $kernel->set_uint    (5, $options->{cycles} || 600);

        my $data;
        $queue->enqueue_nd_range_kernel ($kernel, undef, [$width, $height], undef );
        $queue->enqueue_read_buffer ($output, 1, 0, 3 * $width * $height, $data);
        return $data;
}


sub color
{
        my ($x, $y) = @_;
        my ($real, $imag, $c);

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

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2012 OSRC SysInt Team, all rights reserved.

This program is released under the following license: bsd
