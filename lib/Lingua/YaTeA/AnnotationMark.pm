package Lingua::YaTeA::AnnotationMark;
use strict;
use Lingua::YaTeA::WordOccurrence;

our @ISA = qw(Lingua::YaTeA::WordOccurrence);

sub new
{
    my ($class,$form,$id,$type) = @_;
    my $this = $class->SUPER::new($form);
    bless ($this,$class);
    $this->{ID} = $id;
    $this->{TYPE} = $type;
    return $this;
}

sub getType
{
    my ($this) = @_;
    return $this->{TYPE};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}

1;
