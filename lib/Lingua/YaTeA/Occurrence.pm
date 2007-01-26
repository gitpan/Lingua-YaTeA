package Lingua::YaTeA::Occurrence;
use strict;

our $counter = 0;

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
