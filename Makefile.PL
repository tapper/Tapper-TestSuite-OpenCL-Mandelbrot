use strict;
use warnings;

use inc::Module::Install;

name     'Mandelbrot';
all_from 'lib/Mandelbrot.pm';
author   'OSRC SysInt Team <osrc-sysint@elbe.amd.com>';

requires 'OpenCL'                    => 0;
requires 'File::Slurp'               => 0;
requires 'common::sense';
requires 'MooseX::Singleton';
requires 'OpenCL';
requires 'File::Slurp';
requires 'File::ShareDir';



WriteAll;
