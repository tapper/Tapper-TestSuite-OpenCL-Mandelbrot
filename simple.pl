#!/usr/bin/env perl

use common::sense;

use SDLx::App;
use constant {
        ZYKLEN           => 100,
        DIVERGENZGRENZE  => 1.e23,
        KONVERGENZGRENZE => 1.e-23,
};

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


my $app = SDLx::App->new( h => 4*100,
                          w => 6*100,
                        );

sub mandelbrot
{
        my ($left, $right, $upper, $lower, $app) = @_;
        my $x_size = $right*1.0 - $left;
        my $y_size = $upper*1.0 - $lower;


        for (my $x=0; $x<=$app->width; $x++) {
                my $real = $left+$x*($x_size/$app->width);
                for (my $y=0; $y<=$app->height; $y++ ) {
                        my $imag = $lower+$y*($y_size/$app->height);
                        my $color = color($real, $imag);
                        $app->[$x][$y] = $color;
                }
                $app->update;
        }
}

mandelbrot(-0.5, 0.5, 1, 0.5, $app);

say "done";
my $line = <>;
