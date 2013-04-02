package Pixel::PrettyPrinter;
# file: Pixel/PrettyPrinter.pm
#
# This file is part of the Pixel Policy Expression Language
use strict;
#use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
pp
pp_rule_body
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Log::Log4perl qw(get_logger :levels);


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $g_indent = 4;


sub pp {
  my($ast) = @_;

  my $logger = get_logger();

  my $o = "";

  if (defined $ast->{'policy_stmts'}) {
    $o .= join(";\n", (map {pp_policy_stmt($_)} @{ $ast->{'policy_stmts'} }));
  }

  return $o;
}

sub pp_policy_stmt {
  my($ast) = @_;

  my $logger = get_logger();

  my $o = "";
  $o .= pp_cloud_id($ast->{'cloud_id'}) if (defined $ast->{'cloud_id'});

  $o .= pp_effect($ast->{'effect'});

  $o .= pp_event_filter_expr($ast->{'event_filter'});

  $o .= pp_channel_id_expr($ast->{'channel_id'});

  $o .= pp_condition($ast->{'condition'}) if (defined $ast->{'condition'});

  return $o;
}


sub pp_cloud_id {
  my($ast) = @_;

  my $logger = get_logger();
  my $o = "cloud " . $ast;
  return $o;
}

sub pp_effect {
  my($ast) = @_;

  my $logger = get_logger();
  return $ast;
}

sub pp_event_filter_expr {
  my($ast) = @_;

  my $logger = get_logger();
  return pp_event_filter($ast). " events ";
}

sub pp_event_filter {
  my($ast) = @_;

  my $logger = get_logger();
  my $o = "";

  if ($ast->{'domain'}) {
    $o .= $ast->{'domain'};
  }

  if ($ast->{'types'}) {
    if (scalar @{ $ast->{'types'} } > 1) {
      $o .= " :{ " . join(", ", @{ $ast->{'types'} }) . " } ";
    } elsif (scalar @{ $ast->{'types'} } == 1) {
      $o .= ":" . $ast->{'types'}->[0] ;
    }
  }

  return $o;
}

sub pp_channel_id_expr {
  my($ast) = @_;

  my $logger = get_logger();
  my $o = " on ";

  if (  $ast eq 'all' 
     || $ast eq 'any' 
     ) {
    $o .= $ast . " channel ";
  } else {
    $o .= " channel " . $ast ;
  }

  return $o;
}

sub pp_condition {
  my($ast) = @_;

  my $logger = get_logger();
  my $o = "if ";

  my $not = "";
  if (! $ast->{'sense'}) {
    $not = "not";
  }

  if ($ast->{'type'} eq 'relationship_list') {
    $o .= " channel relationship is $not in [ " . join(", ", @{ $ast->{'relationship_list'} }) . ' ] ';
  } elsif ($ast->{'type'} eq 'relationship_single') {
    $o .= " channel relationship is $not " . $ast->{'relationship_id'} ;
  } elsif ($ast->{'type'} eq 'attribute') {
  } elsif ($ast->{'type'} eq 'raised_by_single') {
    $o .= " $not raised by cloud " . $ast->{'cloud_id'}
  } elsif ($ast->{'type'} eq 'raised_by_list') {
    $o .= " $not raised by cloud in " .  " [ " . join(", ", @{ $ast->{'cloud_list'} }) . ' ] ';
  } elsif ($ast->{'type'} eq 'raised_by_match') {
  }


  return $o;
}




sub pp_template {
  my($ast) = @_;

  my $logger = get_logger();
  my $o = "";



  return $o;
}




1;
