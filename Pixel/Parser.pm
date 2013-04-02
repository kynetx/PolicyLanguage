package Pixel::Parser;
# file: Pixel/Parser.pm
#
# This file is part of the Pixel Policy Expression Languagge
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
parse_pixel
remove_comments
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Pixel::JParser;
use Encode qw(from_to);
use JSON::XS;

use vars qw(%VARIABLE);


my $parser = Pixel::JParser::get_antlr_parser();

# this removes KRL-style comments taking into account quotes
my $comment_re = qr%
       /\*         ##  Start of /* ... */ comment
       [^*]*\*+    ##  Non-* followed by 1-or-more *'s
       (
         [^/*][^*]*\*+
       )*          ##  0-or-more things which don't start with /
                   ##    but do end with '*'
       /           ##  End of /* ... */ comment
     |
       //[^\n]*    ## slash style comments that don't have \ in front (quote)
     |         ##     OR  various things which aren't comments:

       (
         "           ##  Start of " ... " string
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^"\\]        ##  Non "\
         )*
         "           ##  End of " ... " string
        |
         \#           ##  Start of # ... # regexp
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^#\\]        ##  Non "\
         )*
         \#          ##  End
        |         ##     OR  various things which aren't comments:
          <<           ##  Start of << ... >> string
          .*?
          >>           ##  End of " ... " string
       |
         \\//  # backslashes before double slashes
       |         ##     OR
        .           ##  Anything other char
         [^/"#'<\\]*   ##  Chars which doesn't start a comment, string or escape
       )
     %xms;

sub remove_comments {

    my($ruleset) = @_;

    $ruleset =~ s%$comment_re%defined $2 ? $2 : ""%gxmse;
    return $ruleset;

}

sub parse_pixel {
    my ($pixel) = @_;

    my $logger = get_logger();
    $logger->trace("[parser::parse_pixel] passed: ", sub {Dumper($pixel)});

    #$pixel = remove_comments($pixel);

    $logger->debug("[parser::parse_pixel] after comments: ", sub {$pixel});
    my $json = $parser->pixel($pixel);
    $logger->debug("Result: ",$json);
    my $result;
    eval {
        $result = jsonToAst($json);
    };

    if ($@) {
        my @jsonerr = ("Invalid JSON Format!");
        $logger->warn("JSON error: ", $@);
        my $string = $@;
        push (@jsonerr,$string);
        push (@jsonerr,$result);
        $result->{'error'} = @jsonerr;
    }
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
	   $logger->error("Can't parse pixel: $estring");
    } else {
	   $logger->trace("Parsed pixels");
    }
    return $result;
}


sub jsonToAst {
    my ($json) = @_;
    my $logger = get_logger();
    #$logger->debug("Original string: (", ref $json,") ", $json);
    #return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->decode($json);
    return JSON::XS::->new->convert_blessed(1)->pretty(1)->decode($json);

}

1;
