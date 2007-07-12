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

__END__

=head1 NAME

Lingua::YaTeA::IslandSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::IslandSet;
  Lingua::YaTeA::IslandSet->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 getIslands()


=head2 existIsland()


=head2 getIsland()


=head2 existLargerIsland()


=head2 addIsland()


=head2 removeIsland()


=head2 size()


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
