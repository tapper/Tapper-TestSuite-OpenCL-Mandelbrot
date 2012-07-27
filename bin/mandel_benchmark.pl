#!/usr/bin/env perl

use common::sense;
use lib "lib";
use Mandelbrot;

use Benchmark qw(timeit) ;
use Test::TAPv13 ':all';
use Sys::Hostname;
use Test::More;

my $t_gpu = timeit(10, q|Mandelbrot::mandelbrot_cl(-2.0, 2.0, -1, 1, {width => 4800, height => 4800, device => 'GPU'})|);
my $t_cpu = timeit(10, q|Mandelbrot::mandelbrot_cl(-2.0, 2.0, -1, 1, {width => 4800, height => 4800, device => 'CPU'})|);
my @time = localtime;
my $now = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
                  1900+$time[5],
                  1+$time[4],
                  reverse(@time[0..3]),
                 );
my $hostname = Sys::Hostname::hostname;
my $reportgroup = $ENV{TAPPER_REPORT_GROUP};
my $testrun     = $ENV{TAPPER_TESTRUN};


diag "Tapper-suite-name: Benchmark-OpenCL-Mandelbrot";
diag "Tapper-machine-name: $hostname";
diag "Tapper-section: results";
diag "Tapper-wiki-url: https://osrc.amd.com/wiki/Tapper/TestSuite/APU-Benchmark";
diag "Tapper-reportgroup-arbitrary: "       if $reportgroup;
diag "Tapper-reportgroup-testrun: $testrun" if $testrun;
my $codespeed_data = {
                      codespeed => [
                                    {
                                     benchmark    => "mandelbrot_gpu",
                                     date         => $now,
                                     environment  => $hostname,
                                     executable   => $0,
                                     project      => 'APU-Benchmarking',
                                     result_value => $t_gpu->[0],
                                    },
                                    {
                                     benchmark    => "mandelbrot_gpu",
                                     date         => $now,
                                     environment  => $hostname,
                                     executable   => $0,
                                     project      => 'APU-Benchmarking',
                                     result_value => $t_cpu->[0],
                                    },
                                   ],
                     };
ok(1, 'benchmarks');
tap13_yaml($codespeed_data);

done_testing;
