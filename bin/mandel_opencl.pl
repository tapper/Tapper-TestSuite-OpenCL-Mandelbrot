#!/usr/bin/env perl

use common::sense;

use lib "lib";

use SDL;
use SDLx::App;
use SDL::Event;
use SDL::Events;
use Mandelbrot;
use OpenCL;
use Time::HiRes;

my $app = SDLx::App->new( h => 480,
                          w => 480,
                          d => 16,
                          exit_on_quit => 1,
                        );
my $options = {width => $app->w, height => $app->h, device => $ARGV[0]};
my $region = {left => -2.0, right =>  0, top => 1.0, bottom => -1.0};

$app->add_show_handler(
                      sub {
                              my $field = Mandelbrot::mandelbrot_cl(
                                                                    $region->{left},
                                                                    $region->{right},
                                                                    $region->{bottom},
                                                                    $region->{top},
                                                                    $options);
                              for (my $x=0; $x<$app->w; $x++) {
                                      for (my $y=0; $y<$app->h; $y++ ) {
                                              my $color = unpack "L*", substr($field, ($x*$app->w+$y)*OpenCL::SIZEOF_UINT, OpenCL::SIZEOF_UINT);
                                              $app->[$x][$y] = $color;
                                      }
                                      $app->update;

                              }
                      });

$app->add_event_handler(
                        sub {
                                my $event = shift;
                                if ($event->type == SDL_MOUSEBUTTONDOWN and $event->button_button == SDL_BUTTON_LEFT) {

                                        # new rectangle is 90% the size of the old one and centered around the mouse click
                                        my $x_width = $region->{right} - $region->{left};
                                        my $y_width = $region->{top} - $region->{bottom};

                                        my $x_pos   = $region->{left} + ($x_width / $app->w) * $event->button_x;
                                        my $y_pos   = $region->{bottom}  + ($y_width / $app->h) * $event->button_y;

                                        $region->{left}   = $x_pos - ($x_width/2)*0.5;
                                        $region->{right}  = $x_pos + ($x_width/2)*0.5;
                                        $region->{top}    = $y_pos + ($y_width/2)*0.5;
                                        $region->{bottom} = $y_pos - ($y_width/2)*0.5;
                                }
                        });

$app->run;
