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
use Pixel::Test qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

foreach my $f (@pxl_files) {
  my ($fl,$pxl_text) = getpxl($f);
  $logger->debug("File: $f");
  my $result;
  eval {
    $result = parse_pixel($pxl_text);
  };
  if ($@) {
    $logger->info("Parser failed ($f): $@");
    $result->{'error'} = $@;
  }

  ok(! defined ($result->{'error'}), "$f: $fl")
}


1;

