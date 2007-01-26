package Lingua::YaTeA::PatternLeaf;
use strict;
use Lingua::YaTeA::Edge;

our @ISA = qw(Lingua::YaTeA::Edge);

sub new
{
    my ($class,$tag,$father) = @_;
    my $this = $class->SUPER::new($father);
    bless ($this,$class);
    $this->{POS_TAG} = $tag;
    return $this;
}


sub getPOS
{
    my ($this) = @_;
    return $this->{POS_TAG};
}

sub print
{
    my ($this) = @_;
    print $this->getPOS;
}


1;
