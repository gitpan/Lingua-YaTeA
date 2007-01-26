package Lingua::YaTeA::ForbiddenStructure;
use strict;

sub new
{
    my ($class,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{FORM} = $form;
    $this->{LENGTH} = $this->setLength($form);
    return $this;
}

sub setLength
{
    my ($this,$form) = @_;
    my @words = split (/ /,$form);
    return scalar @words;
}

sub getLength
{
    my ($this) = @_;
    return $this->{LENGTH};
}
1;
