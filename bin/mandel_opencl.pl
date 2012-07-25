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

use SDL::Image;
use SDL::RWOps;

my $app = SDLx::App->new( h => 1200,
                          w => 1920,
                          exit_on_quit => 1,
                        );
my $options = {width => $app->w, height => $app->h, device => $ARGV[0]};
my $region = {left => -2.0, right =>  0, top => 1.0, bottom => -1.0};
my $multiplier;
my ($mouse_x, $mouse_y) = ($app->w / 2, $app->h / 2);

$app->add_show_handler(
                      sub {
                              my $time1 = Time::HiRes::time();
                              if ($multiplier) {
                                      # new rectangle is 90% the size of the old one and centered around the mouse click
                                      my $x_width = $region->{right} - $region->{left};
                                      my $y_width = $region->{top} - $region->{bottom};

                                      my $x_pos   = $region->{left} + ($x_width / $app->w) * $mouse_x;
                                      my $y_pos   = $region->{bottom}  + ($y_width / $app->h) * $mouse_y;

                                      $region->{left}   = $x_pos - ($x_width/2)*$multiplier;
                                      $region->{right}  = $x_pos + ($x_width/2)*$multiplier;
                                      $region->{top}    = $y_pos + ($y_width/2)*$multiplier;
                                      $region->{bottom} = $y_pos - ($y_width/2)*$multiplier;
                              }


                              my $field = Mandelbrot::mandelbrot_cl(
                                                                    $region->{left},
                                                                    $region->{right},
                                                                    $region->{bottom},
                                                                    $region->{top},
                                                                    $options);


                              my $image_data = "P6\n".$app->w."\n".$app->h."\n255\n".$field;
                              open my $fh, ">", "/tmp/file.pnm" or die "Can not open file:$!";
                              print $fh $image_data;
                              close $fh;
                              my $surface = SDL::Image::load( "/tmp/file.pnm" );
                              $app->blit_by($surface);
                              $app->update;

                      });

$app->add_event_handler(
                        sub {
                                my $event = shift;
                                $mouse_x = $event->button_x;
                                $mouse_y = $event->button_y;
                                if ($event->type == SDL_MOUSEBUTTONDOWN and $event->button_button == SDL_BUTTON_LEFT) {
                                        $multiplier = 0.9;
#                                        SDL::Mouse::warp_mouse($app->w/2, $app->h/2);
                                } elsif ($event->type == SDL_MOUSEBUTTONDOWN and $event->button_button == SDL_BUTTON_RIGHT) {
                                        $multiplier = 1.1;
                                } elsif ($event->type == SDL_MOUSEBUTTONUP) {
                                        $multiplier = undef;
                                }
                        }
                );

$app->run;
