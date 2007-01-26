package Lingua::YaTeA::Sentence;
use strict;

our $counter = 0;
our $in_doc_counter = 0;
our $start_char = 0;

sub new
{
    my ($class,$documents) = @_;
    my $this = {};
    bless ($this,$class);
     $this->{ID} = $counter;
    $this->{IN_DOC_ID} = $in_doc_counter;
    $this->{DOCUMENT} = $documents->getCurrent;
    return $this;
}

sub resetInDocCounter
{
    my ($class) = @_;
    $in_doc_counter = 0;
}

sub resetStartChar
{
    my ($class) = @_;
    $start_char = 0;
}

sub updateStartChar
{
    my ($class,$word) = @_;
    $start_char += $word->getLexItem->getLength +1;
}

sub getDocument
{
    my ($this) = @_;
    return $this->{DOCUMENT};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}

sub getInDocID
{
    my ($this) = @_;
    return $this->{IN_DOC_ID};
}


1;
