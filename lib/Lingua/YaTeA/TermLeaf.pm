package Lingua::YaTeA::TermLeaf;
use Lingua::YaTeA::Edge;
use strict;

our @ISA = qw(Lingua::YaTeA::Edge);

sub new
{
    my ($class,$index) = @_;
    my $this = $class->SUPER::new;
    $this->{INDEX} = $index;
    bless ($this,$class);
    return $this;
}


sub getIF
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getIF;
}



sub getPOS
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getPOS;
}

sub getLF
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getLF;
}

sub getID
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getID;
}


sub getIndex
{
    my ($this) = @_;
    return $this->{INDEX};
}

sub getLength
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getLength;
}

sub getWord
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex];
}

sub searchHead
{
    my ($this) = @_;
    return $this;
}


sub print
{
    my ($this,$words_a) = @_;
    if(defined $words_a)
    {
	 $this->printWords($words_a) ;	
	 print  " (" . $this->getIndex. ")";
    }
    else
    {
	print $this->getIndex;
    }
}

sub printWords
{
    my ($this,$words_a) = @_;
    print $this->getIF($words_a);
}

sub searchRightMostLeaf
{
    my ($this) = @_;
    return $this;
}

sub searchLeftMostLeaf
{
    my ($this) = @_;
    return $this;
}

1;

