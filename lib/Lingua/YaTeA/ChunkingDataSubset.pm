package Lingua::YaTeA::ChunkingDataSubset;
use strict;


sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{IF} = {};
    $this->{POS} = {};
    $this->{LF} = {};
    return $this;
}

sub getIF
{
    my ($this) = @_;
    return $this->{IF};
}

sub getPOS
{
    my ($this) = @_;
    return $this->{POS};
}

sub getLF
{
    my ($this) = @_;
    return $this->{LF};
}

sub getSome
{
    my ($this,$type) = @_;
    return $this->{$type};
}

sub addIF
{
    my ($this,$value);
    $this->{IF}->{$value}++;
}

sub addPOS
{
    my ($this,$value);
    $this->{POS}->{$value}++;
}

sub addLF
{
    my ($this,$value);
    $this->{LF}->{$value}++;
}

sub addSome
{
    my ($this,$type,$value) = @_;
     $this->{$type}->{$value}++;
}

sub existData
{
    my ($this,$type,$value) = @_;
    if(exists $this->getSome($type)->{$value})
    {
	return 1;
    }
    return 0;
}

1;
