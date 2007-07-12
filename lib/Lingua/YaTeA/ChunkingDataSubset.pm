package Lingua::YaTeA::ChunkingDataSubset;
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

sub getIF
{
    my ($this) = @_;
    return $this->{IF};
}

sub getPOS
{
    my ($this) = @_;
    return $this->{POS};
}

sub getLF
{
    my ($this) = @_;
    return $this->{LF};
}

sub getSome
{
    my ($this,$type) = @_;
    return $this->{$type};
}

sub addIF
{
    my ($this,$value);
    $this->{IF}->{$value}++;
}

sub addPOS
{
    my ($this,$value);
    $this->{POS}->{$value}++;
}

sub addLF
{
    my ($this,$value);
    $this->{LF}->{$value}++;
}

sub addSome
{
    my ($this,$type,$value) = @_;
     $this->{$type}->{$value}++;
}

sub existData
{
    my ($this,$type,$value) = @_;
    if(exists $this->getSome($type)->{$value})
    {
	return 1;
    }
    return 0;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::ChunkingDataSubset - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::ChunkingDataSubset;
  Lingua::YaTeA::ChunkingDataSubset->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getIF()


=head2 getPOS()


=head2 getLF()


=head2 getSome()


=head2 addIF()


=head2 addPOS()


=head2 addLF()


=head2 addSome()


=head2 existData()


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
