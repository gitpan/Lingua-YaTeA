package Lingua::YaTeA::InternalNode;
use strict;
use Lingua::YaTeA::Node;
use Lingua::YaTeA::Edge;
use UNIVERSAL qw(isa);
our @ISA = qw(Lingua::YaTeA::Node Lingua::YaTeA::Edge);

sub new
{
    my ($class,$level) = @_;
    my $this = $class->SUPER::new($level);
    $this->{FATHER} = ();
    bless ($this,$class);
    return $this;
}

sub setFather
{
    my ($this,$father) = @_;
    $this->{FATHER} = $father;
}

sub getFather
{
    my ($this) = @_;
    return $this->{FATHER};
}

sub updateLevel
{
    my ($this,$new_level) = @_;
    $this->{LEVEL} = $new_level++;
    if(isa($this->getLeftEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getLeftEdge->updateLevel($new_level);
    }
    if(isa($this->getRightEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getRightEdge->updateLevel($new_level);
    }
}

sub searchRoot
{
    my ($this) = @_;
    if(isa($this->getFather,'Lingua::YaTeA::RootNode'))
    {
	return $this->getFather;
    }
    
    return $this->getFather->searchRoot;
}




sub printFather
{
    my ($this) = @_;
    print"\t\tfather: " . $this->getFather->getID . "\n"; 
}

1;
