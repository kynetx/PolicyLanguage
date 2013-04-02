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

use Data::Dumper;
use Encode;

use Pixel::Parser qw/:all/;
use Pixel::PrettyPrinter qw/:all/;
use Pixel::Test qw/:all/;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

foreach my $f (@pxl_files) {
  my ($fl,$pxl_text) = getpxl($f);
  
  
#  $logger->debug("Input ($f): ", $pxl_text);
  # the parser doesn't like newlines. Not sure why...
  $pxl_text =~ s%\n%%g;
  my $tree;
  eval {
    $tree = parse_pixel($pxl_text);
  };
  if ($@) {
    $logger->info("Parser failed ($f): $@");
    $tree->{'error'} = $@;
  }
#  $logger->debug("$fl: ", sub {Dumper($tree)});
  # compare to text with comments removed since pp can't reinsert them.
  # Use the internal perl string structure for the compare
  my $pxl = decode("UTF-8",$pxl_text);
  $pxl =~ s/;\s*$//; # pp doesn't print trailing semicolons
  my $result = is_string_nows(decode("UTF-8",pp($tree)), remove_comments($pxl), "$f: $fl");
  die unless ($result);
}



1;

