package Lingua::YaTeA::Edge;
use strict;
use UNIVERSAL qw(isa);



sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    #$this->{FATHER} = $father;
    #$this->{POSITION} = "";
    return $this;
}


sub copyRecursively
{
    my ($this,$new_set,$father) = @_;
    my $new;
    if (isa($this,'Lingua::YaTeA::TermLeaf'))
    {
	return "";
    }
    else{
	if(isa($this,'Lingua::YaTeA::InternalNode'))
	{
	    return $this->copyRecursively($new_set,$father);
	}
	else{
	    if (isa($this,'Lingua::YaTeA::PatternLeaf'))
	    {
		return "";
	    }
	}
    }
}

sub update
{
    my ($this,$new_value) = @_;
    $this = $new_value;
}



sub print
{
    my ($this,$words_a) = @_;
    if (isa($this,"Lingua::YaTeA::Node"))
    {
	 print "Node " . $this->getID;
    }
    else{
	$this->printWords($words_a);
    }
}

1;
