#!/usr/bin/perl -w

use strict;

use lib qw(..);

use Getopt::Std;
use Data::Dumper;


use Pixel::Parser;
use Pixel::PrettyPrinter qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


# global options
use vars qw/ %opt /;
my $opt_string = 'f:ph?';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};


my $filename = 0;
if($opt{'f'}) {
    $filename = $opt{'f'};
} else {
    die "You must supply a filename\n";
}

die "Don't append extension" if $filename =~ m#\.pm$#;


# config

my $base_var = 'PIXEL_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment; set it before using $0";

my $ast;
eval {
  $ast = Pixel::Parser::parse_pixel(getfile($filename));
};
if ($@) {
  $ast->{'error'} = $@;
}

if ($opt{'p'}) { # pretty print -- round trip
  print pp($ast);
} else {
  my $json = Pixel::Parser::astToJson($ast);
  print $json  ;
}



1;

sub usage {
    print STDERR <<EOF;

usage:  

   $0 -f pixel_file

Parses a pixel file

Options are:

  -f name  : module is named name (do not include .pm extension in name)

EOF

exit;

}


sub getfile {
  my($filename) = @_;
  open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $krl = <KRL>;
  close KRL;
  return $krl;

}
