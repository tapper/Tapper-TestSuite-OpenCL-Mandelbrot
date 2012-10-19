package Tapper::TestSuite::OpenCL::Mandelbrot::OpenCL;

=head1 NAME

Tapper::TestSuite::OpenCL::Mandelbrot::OpenCL - A Mandelbrot set calculator with OpenCL support

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use common::sense;
use MooseX::Singleton;
use OpenCL;
use File::Slurp;
use File::ShareDir ':ALL';

use constant {
        ZYKLEN           => 1200,
        DIVERGENZGRENZE  => 1.e23,
        KONVERGENZGRENZE => 1.e-23,
};

has opencl      => (is => 'rw', default => sub {{}});
has device_type => (is => 'rw');


sub prepare
{
        my ( $self, $options ) = @_;
        $self->opencl->{output} = undef if $self->device_type and $self->device_type ne $options->{device};

        if (not (defined $self->opencl and defined $self->opencl->{output})) {
                my ($width, $height) = ($options->{width}, $options->{height});

                my @platforms = OpenCL::platforms;
                my $platform = $platforms[0];
                
                my $dev;
                {
                        $self->device_type($options->{device});
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
                my $cl_file;
                
                if ($options->{vector}) {
                        $cl_file = module_file(  'Tapper::TestSuite::OpenCL::Mandelbrot::OpenCL',  'mandel_opencl_vector.cl');
                } else {
                        $cl_file = module_file(  'Tapper::TestSuite::OpenCL::Mandelbrot::OpenCL',  'mandel_opencl.cl');
                }
                
                my $src = File::Slurp::read_file($cl_file);
                my $prog = $ctx->program_with_source ($src);
                
                # build croaks on compile errors, so catch it and print the compile errors
                eval { $prog->build ($device, "");1 }
                  or die $prog->build_log($device);
                my $kernel = $prog->kernel ("color");

                my $output = $ctx->buffer (0, $width * $height * 3 );
                
                $self->opencl->{kernel} = $kernel;
                $self->opencl->{queue}  = $queue;
                $self->opencl->{output} = $output;
        } 

        return ($self->opencl->{kernel}, 
                $self->opencl->{queue},
                $self->opencl->{output});
}

1;
