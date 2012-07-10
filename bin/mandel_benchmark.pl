#!/usr/bin/env perl

use common::sense;
use lib "lib";
use Mandelbrot;

use Benchmark qw(:all) ;


timethese(10, {
    'OpenCL_GPU' => q|Mandelbrot::mandelbrot_cl(-2.0, 2.0, -1, 1, {width => 4800, height => 4800, device => 'GPU'})|,
    'OpenCL_CPU' => q|Mandelbrot::mandelbrot_cl(-2.0, 2.0, -1, 1, {width => 4800, height => 4800, device => 'CPU'})|,
#    'Perl' => q|Mandelbrot::mandelbrot_perl(-2.0, 2.0, -1, 1, {width => 4800, height => 4800, device => 'GPU'})|,
});
