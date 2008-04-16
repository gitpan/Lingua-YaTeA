package Lingua::YaTeA::Occurrence;
use strict;
use warnings;

our $counter = 0;

our $VERSION=$Lingua::YaTeA::VERSION;

sub new
{
    my ($class,) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $counter++;
    $this->{SENTENCE} = ();
    $this->{START_CHAR} = ();
    $this->{END_CHAR} = ();
    $this->{MAXIMAL} = ();
    return $this;
}



sub getSentence
{
    my ($this) = @_;
    return $this->{SENTENCE};
}

sub getStartChar
{
    my ($this) = @_;
    return $this->{START_CHAR};
}

sub getEndChar
{
    my ($this) = @_;
    return $this->{END_CHAR};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}

sub getDocument
{
    my ($this) = @_;
    return $this->getSentence->getDocument;
}


sub isMaximal
{
    my ($this) = @_;
    return $this->{MAXIMAL};
}

sub setInfoForPhrase
{
    my ($this,$words_a,$maximal) = @_;
    my $first = $words_a->[0];
    my $last = $words_a->[$#$words_a];
    $this->{SENTENCE} = $first->getSentence;
    $this->{START_CHAR} = $first->getStartChar;
    $this->{END_CHAR} = $last->getStartChar + $last->getLexItem->getLength;
    $this->{MAXIMAL} = $maximal;
}

sub setInfoForTestifiedTerm
{
    my ($this,$sentence,$start_char,$end_char) = @_;
    $this->{SENTENCE} = $sentence;
    $this->{START_CHAR} = $start_char;
    $this->{END_CHAR} = $end_char;
}

sub print
{
    my ($this,$fh) = @_;
    if(defined $fh)
    {
	print $fh "DOC: " . $this->getDocument . " - SENT: " . $this->getSentence . " from: " . $this->getStartChar . " to: " .$this->getEndChar . "\n";
    }
    else
    {
	print "DOC: " . $this->getDocument->getID . " - SENT: " . $this->getSentence->getID . " from: " . $this->getStartChar . " to: " .$this->getEndChar . "\n";
    }
}

sub isNotBest
{
    my ($this,$other_occurrences_a,$parsing_direction) = @_;
    my $other;

    foreach $other (@$other_occurrences_a)
    {
	if($this->isIncludedIn($other)) # best is the largest
	{
	    return 1;
	}
	# best is the one that has the position corresponding to the parsing direction (ex: leftmost TT for parsing direction = LEFT) 
	if($this->crossesWithoutPriority($other,$parsing_direction))
	{
	    return 1;
	}
    }
    return;
    
}

sub crossesWithoutPriority
{
 my ($this,$other,$parsing_direction) = @_;
 if(
     ($this->getStartChar > $other->getStartChar)
     &&
     ($this->getStartChar < $other->getEndChar)
     &&
     ($this->getEndChar > $other->getEndChar)
     &&
     ($parsing_direction eq "LEFT")
     
     )
 {
     return 1;
 }
 if(
     ($this->getEndChar < $other->getEndChar)
     &&
     ($this->getEndChar > $other->getStartChar)
     &&
     ($this->getStartChar < $other->getStartChar)
     &&
     ($parsing_direction eq "RIGHT")
     
     )
 {
     return 1;
 }
 return;
}

sub isIncludedIn
{
    my ($this,$other) = @_;
    if(
	(
	 ($this->getStartChar >= $other->getStartChar)
	 &&
	 ($this->getEndChar < $other->getEndChar)
	)
	||
	(
	 (
	 ($this->getStartChar > $other->getStartChar)
	 &&
	  ($this->getEndChar <= $other->getEndChar)
	)
	)
	)
    {
	return 1;
    }
    return;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::Occurrence - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::Occurrence;
  Lingua::YaTeA::Occurrence->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getSentence()


=head2 getStartChar()


=head2 getEndChar()


=head2 getID()


=head2 getDocument()


=head2 isMaximal()


=head2 setInfoForPhrase()


=head2 setInfoForTestifiedTerm()


=head2 print()


=head2 isNotBest()


=head2 crossesWithoutPriority()


=head2 isIncludedIn()


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
