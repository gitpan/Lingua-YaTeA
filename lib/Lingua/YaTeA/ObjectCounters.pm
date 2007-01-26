package Lingua::YaTeA::ObjectCounters;
use strict;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{LEX_ITEMS} = 0;
    return $this;
}
1;

sub increment
{
    my ($this,$object) = @_;
    $this->{$object}++;
    return $this->{$object};
}
