package Lingua::YaTeA::ParsingPattern;
use strict;
use Parse::Lex;
use Lingua::YaTeA::NodeSet;
use Lingua::YaTeA::InternalNode;
use Lingua::YaTeA::RootNode;
use Lingua::YaTeA::PatternLeaf;
use Data::Dumper;
 

sub new
{
    my ($class,$parse,$pos_sequence,$node_set,$priority,$direction,$num_content_words,$num_line) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{PARSE} = $parse;
    $this->{PRIORITY} = $priority;
    $this->{PARSING_DIRECTION} = $direction;
    $this->{DECLARATION_LINE} = $num_line;
    $this->{POS_SEQUENCE} = $pos_sequence;
    $this->{NODE_SET} = $node_set;
    $this->{CONTENT_WORDS} = $num_content_words;
    return $this;
}

sub setNodeSet
{
    my ($this,$node_set) = @_;
    $this->{NODE_SET} = $node_set;
}



sub getParse
{
    my ($this) = @_;
    return $this->{PARSE};
}


sub getLength
{
    my ($this) = @_;
    my @array = split (/ /, $this->getPOSSequence);
    return scalar @array;
}


sub getPriority
{
    my ($this) = @_;
    return $this->{PRIORITY};
}

sub getDirection
{
    my ($this) = @_;
    return $this->{PARSING_DIRECTION};
}

sub getNodeSet
{
    my ($this) = @_;
    return $this->{NODE_SET};
}

sub getNumContentWords
{
    my ($this) = @_;
    return $this->{CONTENT_WORDS};
}

sub getPOSSequence
{
    my ($this) = @_;
    return $this->{POS_SEQUENCE};
}

sub print
{
    my ($this) = @_;
   
    print "\t[\n";
    print "\tPARSE: " . $this->getParse . "\n";
    print "\tPOS: " . $this->getPOSSequence . "\n";
    print "\tPRIORITY: " . $this->getPriority . "\n";
    print "\tPARSING_DIRECTION: " . $this->getDirection . "\n";
    print "\tNODE_SET: \n";
    $this->getNodeSet->print;
    print "]\n";
}


1;


__END__

=head1 NAME

Lingua::YaTeA::ParsingPattern - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::ParsingPattern;
  Lingua::YaTeA::ParsingPattern->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 setNodeSet()


=head2 getParse()


=head2 getLength()


=head2 getPriority()


=head2 getDirection()


=head2 getNodeSet()


=head2 getNumContentWords()


=head2 getPOSSequence()


=head2 print()



=head1 SEE ALSO

Sophie Aubin and Thierry Hamon. Improving Term Extraction with
Terminological Resources. In Advances in Natural Language Processing
(5th International Conference on NLP, FinTAL 2006). pages
380-387. Tapio Salakoski, Filip Ginter, Sampo Pyysalo, Tapio Pahikkala
(Eds). August 2006. LNAI 4139.


=head1 AUTHOR

Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Thierry Hamon and Sophie Aubin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
