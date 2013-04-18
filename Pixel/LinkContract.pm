package Pixel::LinkContract;
# file: Pixel/LinkContract.pm
#
# This file is part of the Pixel Policy Expression Languagge
# Copyright Kynetx, Inc. 2013

use strict;
use warnings;
use lib qw(..);

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Data::UUID;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


use Pixel::Parser;

sub gen_lc {
  my($ast) = @_;

  my $logger = get_logger();

  my $decls = eval_decls($ast->{'decls'});

  my $o = [];

  push @{ $o}, {'[$do]/$do$signal'=> ['+channel{}+event{}']};


  foreach my $policy_stmt (@{ $ast->{'policy'} } ) {
    
#    $logger->debug("Policy ", sub{Dumper $policy_stmt});

    my $channel = $decls->{$policy_stmt->{'channel_id'}} || $policy_stmt->{'channel_id'};
    push @{$o}, @{gen_event_filter($policy_stmt->{'event_filter'}, $channel)};
    push @{$o}, @{ gen_condition($policy_stmt->{'condition'}, $channel) };
    
  }

  my $result = {};
  
  foreach my $clause (@{ $o }) {
    foreach my $k (keys %{ $clause }) {
      $result->{$k} = $clause->{$k}
    }
  }

  return Pixel::Parser::astToJson($result);
}

sub eval_decls {
  my($decls) = @_;

  my $logger = get_logger();

  my $o = {};
  foreach my $decl (@{ $decls }) {
    $o->{$decl->{'lhs'}} = eval_decl_expr($decl->{'expr'});
  }

  return $o;

}

sub eval_decl_expr {
  my($ast) = @_;

  my $logger = get_logger();

  my $o = $ast;

  return $o;

}


sub gen_event_filter {
  my($event_filter, $channel) = @_;

  my $logger = get_logger();

  my $o = [];

#  $logger->debug("Event filter: ", sub{Dumper $event_filter});

  my $subject_prefix = '[$do][$if][$and]';
  my $action = '$do$signal';
  my $channel_subj = '+channel'.$channel.'+event{1}';
  if ($event_filter->{'domain'}) {

    my $domain_obj = gen_XDI_triple($channel_subj,'+domain','+'.$event_filter->{'domain'});
    push @{ $o }, gen_XDI_triple($subject_prefix,$action,$domain_obj);
  }
  my $ev_id = gen_policy_id();
  my $ev_subj = $subject_prefix.'$or'.$ev_id;
  my $ev_obj = gen_XDI_triple($channel_subj,'+type', [map {'+'.$_} @{ $event_filter->{'types'}}]);
  push @{ $o }, gen_XDI_triple($ev_subj, $action, $ev_obj);

  return $o

}

sub gen_condition {
  my($condition, $channel, $o) = @_;

  my $logger = get_logger();
  my $o = [];

  return $o;

}

sub gen_XDI_triple {
  my($subj, $pred, $obj) = @_;

  my $sub = join('/', ($subj, $pred));
  if (! ref $obj eq 'ARRAY') {
    $obj = [ $obj ];
  }
  return {$sub => $obj};
}

sub wrap_triple {
 my ($triple) = @_;
 return '('.$triple.')';
}

sub gen_policy_id {
  my $ug    = new Data::UUID;
  return '!.uuid.'.$ug->create_str();
}


1;
