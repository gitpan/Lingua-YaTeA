package Lingua::YaTeA::IslandSet;
use strict;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ISLANDS} = {};
    return $this;
}

sub getIslands
{
    my ($this) = @_;
    return $this->{ISLANDS};
}

sub existIsland
{
    my ($this,$index_set) = @_;
    my $key = $index_set->joinAll('-');
    if(exists $this->getIslands->{$key})
    {
	return 1;
    }
    return 0; 
}

sub getIsland
{
    my ($this,$index_set) = @_;
    my $key = $index_set->joinAll('-');
    return $this->getIslands->{$key};
}

sub existLargerIsland
{
    my ($this,$index) = @_;
    my $key = $index->joinAll('-');
    my $island;
    foreach $island (values (%{$this->getIslands}))
    {
	if($index->isCoveredBy($island->getIndexSet))
	{
	    return 1;
	}
    }
    return 0;
}

sub addIsland
{
    my ($this,$island) = @_;
    my $key = $island->getIndexSet->joinAll('-');
    $this->getIslands->{$key} = $island;
}

sub removeIsland
{
    my ($this,$island) = @_;
    my $key = $island->getIndexSet->joinAll('-');
    delete($this->getIslands->{$key});
    $island = undef;
}


sub size
{
    my ($this) = @_;
    return scalar (keys %{$this->getIslands});
}

sub print
{
    my ($this,$fh) = @_;
    my $island;
    if(defined $fh)
    {
	foreach $island (values (%{$this->getIslands}))
	{
	print $fh "\t";
	$island->print($fh);
	}
    }
    else
    {
	foreach $island (values (%{$this->getIslands}))
	{
	print "\t";
	$island->print;
	}
    }
}


1;
