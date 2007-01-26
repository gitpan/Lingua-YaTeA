package Lingua::YaTeA::Hierarchy;
use strict;

sub new
{
    my ($class,$tree,$added_node_set) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{TREE} = $tree;
    $this->{ADDED} = $added_node_set;
    $this->{} = ();
    return $this;

}
