package Lingua::YaTeA::RootNode;
use Lingua::YaTeA::Node;
use strict;

our @ISA = qw(Lingua::YaTeA::Node);

sub new
{
    my ($class,$level) = @_;
    my $this = $class->SUPER::new($level);
    bless ($this,$class);
    return $this;
}


1;
