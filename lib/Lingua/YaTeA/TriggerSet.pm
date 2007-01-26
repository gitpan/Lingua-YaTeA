package Lingua::YaTeA::TriggerSet;
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

sub addTrigger
{
    my ($this,$fs) = @_;
    my $trigger = $fs->getFirstItem;
    push @{$this->getSubset($trigger->getType)->{$trigger->getForm}}, $fs; 
}



sub getSubset
{
    my ($this,$type) = @_;
    return $this->{$type};
}

sub findTrigger
{
    my ($this,$word) = @_;
    my @types = ("IF","POS","LF");
    my $type;
    foreach $type (@types)
    {
	if(defined $this->getSubset($type))
	{
	    if(exists $this->getSubset($type)->{$word->getLexItem->{$type}})
	    {
		return $this->getSubset($type)->{$word->getLexItem->{$type}};
	    }
	}
    }
    return;
}


1;
