#!/usr/bin/env perl

use common::sense;

use lib "lib";

use SDLx::App;
use Mandelbrot;
use Time::HiRes;

my $app = SDLx::App->new( h => 480,
                          w => 480,
                          exit_on_quit => 1,
                        );
my $options = {width => $app->w, height => $app->h, device => $ARGV[0]};
my $field = Mandelbrot::mandelbrot_cl(-2.0, 2.0, -1, 1, $options);
for (my $x=0; $x<$app->w; $x++) {
        for (my $y=0; $y<$app->h; $y++ ) {
                my $color = unpack "L*", substr($field, ($y*$app->w+$x)*OpenCL::SIZEOF_UINT, OpenCL::SIZEOF_UINT);
                $app->[$x][$y] = $color;
        }
}
$app->run;
