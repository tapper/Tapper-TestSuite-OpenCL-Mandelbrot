#!/usr/bin/env perl

use common::sense;

use OpenCL;
use SDLx::App;
use File::Slurp;

my $dev;
{
        no warnings 'uninitialized';
        if ($ARGV[0] =~ /CPU/i) {
                $dev = OpenCL::DEVICE_TYPE_CPU;
        } elsif ($ARGV[0] =~ /GPU/i) {
                $dev = OpenCL::DEVICE_TYPE_GPU;
        } else {
                die "Choose GPU or CPU to run on\n";
        }
}



sub mandelbrot_cl
{
        my ($left, $right, $upper, $lower, $app) = @_;

        my @platforms = OpenCL::platforms;
        my $platform = $platforms[0];
        my ($width, $height) = ($app->w, $app->h);

        for my $device ($platform->devices($dev)) {
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
}



my $app = SDLx::App->new( h => 480,
                          w => 640,
                          exit_on_quit => 1,
                        );
my $field = mandelbrot_cl(-2.0, 2.0, -1, 1, $app);
for (my $x=0; $x<$app->w; $x++) {
        for (my $y=0; $y<$app->h; $y++ ) {
                my $color = unpack "L*", substr($field, ($y*$app->w+$x)*OpenCL::SIZEOF_UINT, OpenCL::SIZEOF_UINT);
                $app->[$x][$y] = $color;
        }
}
$app->run;
