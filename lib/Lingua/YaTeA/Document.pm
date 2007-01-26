package Lingua::YaTeA::Document;
use strict;

our $counter = 0;

sub new
{
    my ($class,$word) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $counter;
    $this->{NAME} = $word->getLexItem->getIF;
    return $this;
}

sub newDefault
{
    my ($class,$word) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = 0;
    $this->{NAME} = "no_name";
    return $this;
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}

sub getName
{
    my ($this) = @_;
    return $this->{NAME};

}

sub update
{
    my ($this,$word) = @_;
    $this->{NAME} = $word->getLexItem->getIF;
}

1;
