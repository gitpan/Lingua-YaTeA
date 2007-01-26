package Lingua::YaTeA::SentenceSet;
use strict;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{SENTENCES} = [];
    return $this;
}

sub addSentence
{
    my ($this,$documents) = @_;
    push @{$this->{SENTENCES}}, Lingua::YaTeA::Sentence->new($documents);
}

sub getCurrent
{
    my ($this)= @_;
    return $this->{SENTENCES}[-1];
}

sub getSentences
{
    my ($this)= @_;
    return $this->{SENTENCES};
}
1;
