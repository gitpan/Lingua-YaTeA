package Lingua::YaTeA::Island;
use strict;
use warnings;

our $id = 0;

our $VERSION=$Lingua::YaTeA::VERSION;

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

sub gapSize
{
    my ($this) = @_;
    my $i;
    my $gap =0;
    my $index = $this->getIndexSet->getIndexes->[0];
    for ($i=1; $i < scalar @{$this->getIndexSet->getIndexes}; $i++)
    {
	if($this->getIndexSet->getIndexes->[$i] != $index + 1)
	{
#	    return 0;
	    $gap += $this->getIndexSet->getIndexes->[$i] - $index;
	}
	$index = $this->getIndexSet->getIndexes->[$i];
    }
    return $gap;
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


__END__

=head1 NAME

Lingua::YaTeA::Island - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::Island;
  Lingua::YaTeA::Island->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getIndexSet()


=head2 getType()


=head2 getParsingMethod()


=head2 getIF()


=head2 getSource()


=head2 getID()


=head2 importNodeSets()


=head2 print()


=head1 SEE ALSO

Sophie Aubin and Thierry Hamon. Improving Term Extraction with
Terminological Resources. In Advances in Natural Language Processing
(5th International Conference on NLP, FinTAL 2006). pages
380-387. Tapio Salakoski, Filip Ginter, Sampo Pyysalo, Tapio Pahikkala
(Eds). August 2006. LNAI 4139.


=head1 AUTHOR

Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Thierry Hamon and Sophie Aubin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
