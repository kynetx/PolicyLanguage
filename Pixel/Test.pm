package Pixel::Test;
# file: Pixel/Test.pm
#
# This file is part of the Pixel Policy Expression Language
use strict;
#use warnings;
use utf8;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use lib qw(/web/lib/perl);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
getpxl
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub getpxl {
    my $filename = shift;

    open(PXL, "< $filename") || die "Can't open file $filename: $!\n";
    my $first_line = <PXL>;
    local $/ = undef;
    my $pxl = <PXL>;
    close PXL;
    if ($first_line =~ m%^\s*//.*%) {
	return ($first_line,$pxl);
    } else {
	return ("No comment", $first_line . $pxl);
    }

}




1;





