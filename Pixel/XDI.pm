package Pixel::XDI;
# file: Pixel/XDI.pm
#
# This file is part of the Pixel Policy Expression Languagge
# Copyright Kynetx, Inc. 2013

use strict;
use warnings;
use lib qw(..);

use Log::Log4perl qw(get_logger :levels);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub gen_policy {
  my($ast) = @_;

  my $logger = get_logger();

  my $o = {};

  $o->{"!($do)/$do$signal"=> ["+channel{}+event{}"]};

  return JSON::XS::->new->convert_blessed(1)->pretty(1)->encode($o);
}


1;
