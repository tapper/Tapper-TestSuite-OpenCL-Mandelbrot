#!/usr/bin/env perl

use common::sense;

use SDLx::App;
use constant { 
        ZYKLEN           => 8000,
        DIVERGENZGRENZE  => 1.e23,
        KONVERGENZGRENZE => 1.e-23,
};


sub farbe
{
        my ($x, $y) = @_;
        my ($a, $b);
        my ($qua, $qub);
        my $qu;
        my $zaehler;

        $a = $x; $b = $y;
        $zaehler = 0;
        $qua = $a * $a; $qub = $b * $b;
        do {
                $b = 2 * $a * $b - $y;
                $a = $qua - $qub - $x;
                $qu = ($qua = $a * $a) + ($qub = $b * $b);
        } while ($qu < DIVERGENZGRENZE  and
                 $qu > KONVERGENZGRENZE and
                 $zaehler++ < ZYKLEN);
        return($zaehler & 0xff);
}

my $app = SDLx::App->new( h => 80,
                          w => 120,
                        );

for (my $x=0; $x<=$app->width; $x++) {
        my $real = -2.0+$x*(4.0/$app->width);
        for (my $y=0; $y<=$app->height; $y++ ) {
                my $imag = -1.0+$y*(2.0/$app->height);
                my $farbe = farbe($real, $imag);
                $app->[$x][$y] = [ $farbe, $farbe, $farbe, 255];
        }
        
}
$app->update;

my $line = <>;
