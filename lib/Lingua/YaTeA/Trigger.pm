package Lingua::YaTeA::Trigger;
use strict;

sub new
{
    my ($class,$type,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{TYPE} = $type;
    $this->{FORM} = $form;
    $this->{FS} = [];
    return $this;
}

sub addFS
{
    my ($this,$fs) = @_;
    psuh @{$this->{FS}}, $fs;
}

sub getType
{
    my ($this) = @_;
    return $this->{TYPE};
}

sub getForm
{
    my ($this) = @_;
    return $this->{FORM};
}

1;
