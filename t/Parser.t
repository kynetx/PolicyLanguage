#!/usr/bin/perl -w
#
# This file is part of the Pixel Policy Expression Languagge
use lib qw(..);
use strict;

# grab the test data file names
my @pxl_files = @ARGV ? @ARGV : <data/*.pxl>;


use Test::More;
plan tests => $#pxl_files+1;
use Test::LongString;

use Pixel::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

foreach my $f (@pxl_files) {
    my ($fl,$pxl_text) = getpxl($f);
    $logger->debug("File: $f");
    my $result = parse_pixel($pxl_text);
    ok(! defined ($result->{'error'}), "$f: $fl")
}

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

