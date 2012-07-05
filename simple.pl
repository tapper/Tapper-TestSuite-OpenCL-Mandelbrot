#!/usr/bin/env perl

use common::sense;

use SDLx::App;
use constant { 
        ZYKLEN           => 1200,
};


sub color
{
        my ($x, $y) = @_;
        my ($real, $imag, $c);
        my $counter;

        $real = $x; $imag = $y;
        $counter = 0;
        my $counter;
        for (1..ZYKLEN) {
                $counter=$_;
                $imag = 2 * $real * $imag - $y;
                $real = $real**2 - $imag**2 - $x;
                $c = sqrt($real**2 + $imag**2);
                last if $c > 2;
        }
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

for (my $x=0; $x<=$app->width; $x++) {
        my $real = -2.0+$x*(3.0/$app->width);
        for (my $y=0; $y<=$app->height; $y++ ) {
                my $imag = -1.0+$y*(2.0/$app->height);
                my $color = color($real, $imag);
                $app->[$x][$y] = $color;
        }
        $app->update;
}
say "done";
my $line = <>;
