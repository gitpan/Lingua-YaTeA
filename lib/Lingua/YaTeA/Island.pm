package Lingua::YaTeA::Island;
use strict;

our $id = 0;

sub new
{
    my ($class,$index,$type,$source) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $id++;
    $this->{INDEX_SET} = $index;
    $this->{TYPE} = $type;
    $this->{SOURCE} = $source;
    return $this;
}

sub getIndexSet
{
    my ($this) = @_;
    return $this->{INDEX_SET};
}

sub getType
{
    my ($this) = @_;
    return $this->{TYPE};

}

sub getParsingMethod
{
    my ($this) = @_;
    return $this->getSource->getParsingMethod;
}

sub getIF
{
    my ($this) = @_;
    return $this->getSource->getIF;
}

sub getSource
{
    my ($this) = @_;
    return $this->{SOURCE};
}



sub getID
{
    my ($this) = @_;
    return $this->{ID};

}

sub importNodeSets
{
    my ($this) = @_;
    my $node_sets_a;
    my $tree;
    my $node_set;

    $node_sets_a = $this->getSource->exportNodeSets;
    
    foreach $node_set (@$node_sets_a)
    {
	$node_set->updateLeaves($this->getIndexSet);
    }
    return $node_sets_a;
}




sub print
{
    my ($this,$fh) = @_;

    if(defined $fh)
    {
	print $fh "form: " . $this->getIF;
	print $fh " - indexes: "; 
	$this->getIndexSet->print($fh);
	print $fh "- parsing method : " . $this->getParsingMethod;
	print $fh " - type: " . $this->getType . "\n";
	

    }
    else
    {
	print "form: " . $this->getIF;
	print " - indexes: "; 
	$this->getIndexSet->print;
	print " - type: " . $this->getType . "\n";
    }
}


1;


