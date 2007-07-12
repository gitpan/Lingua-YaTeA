package Lingua::YaTeA::TermCandidate;
use strict;
use UNIVERSAL qw(isa);

our $id = 0;

sub new
{
    my ($class) = @_;
    my $this;
    $this->{ID} = $id++;
    $this->{KEY} = "";
    $this->{HEAD} = ();
    $this->{WORDS} = [];
    $this->{OCCURRENCES} = [];
    $this->{RELIABILITY} = ();
    $this->{ORIGINAL_PHRASE} = ();
    bless ($this,$class);
    return $this;
}

sub getLength
{
    my ($this) = @_;
    return scalar @{$this->getWords};
}

sub addWord
{
    my ($this,$leaf,$words_a) = @_;
    push @{$this->{WORDS}}, $words_a->[$leaf->getIndex];
}

sub addOccurrence
{
    my ($this,$occurrence) = @_;
    push @{$this->{OCCURRENCES}}, $occurrence;
}

sub addOccurrences
{
    my ($this,$occurrences_a) = @_;
    my $occurrence;
    foreach $occurrence (@$occurrences_a)
    {
	$this->addOccurrence($occurrence);
    }
}

sub getKey
{
    my ($this) = @_;
    return $this->{KEY};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}


sub editKey
{
    my ($this,$string) = @_;
    $this->{KEY} .= $string;
}

sub setHead
{
    my ($this) = @_;
    $this->{HEAD} = $this->searchHead;
}

sub getHead
{
    my ($this) = @_;
    return $this->{HEAD};
}


sub getWords
{
    my ($this) = @_;
    return $this->{WORDS};
}

sub getOccurrences
{
    my ($this) = @_;
    return $this->{OCCURRENCES};
}

sub buildLinguisticInfos
{
    my ($this,$tagset) = @_;
    my $if;
    my $pos;
    my $lf;
    my $word;
    
    foreach $word (@{$this->getWords})
    {
	$if .= $word->getIF . " " ;
	if ($tagset->existTag('PREPOSITIONS',$word->getIF))
	{
	    $pos .= $word->getLF . " ";
	}
	else
	{
	    $pos .= $word->getPOS . " ";
	}
	$lf .= $word->getLF . " " ;
    }
    $if =~ s/\s+$//;
    $pos =~ s/\s+$//;
    $lf =~ s/\s+$//;
    return ($if,$pos,$lf);

}

sub getIF
{
    my ($this) = @_;
    my $word;
    my $if;
    foreach $word (@{$this->getWords})
    {
	$if .= $word->getIF . " " ;
    }
    $if =~ s/\s+$//;
    return $if;
}

sub getLF
{
    my ($this) = @_;
    my $word;
    my $lf;
    foreach $word (@{$this->getWords})
    {
	$lf .= $word->getLF . " " ;
    }
    $lf =~ s/\s+$//;
    return $lf;
}

sub getPOS
{
    my ($this) = @_;
    my $word;
    my $pos;
    foreach $word (@{$this->getWords})
    {
	$pos .= $word->getPOS . " " ;
    }
    $pos =~ s/\s+$//;
    return $pos;
}

sub getFrequency
{
    my ($this) = @_;
    return scalar @{$this->getOccurrences};
}

sub setReliability
{
    my ($this,$reliability) = @_;
    $this->{RELIABILITY} = $reliability;
}

sub getReliability
{
    my ($this) = @_;
    return $this->{RELIABILITY};
}

sub getOriginalPhrase
{
    my ($this) = @_;
    return $this->{ORIGINAL_PHRASE};
}

1;

__END__

=head1 NAME

Lingua::YaTeA::TermCandidate - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::TermCandidate;
  Lingua::YaTeA::TermCandidate->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getLength()


=head2 addWord()


=head2 addOccurrence()


=head2 addOccurrences()


=head2 getKey()


=head2 getID()


=head2 editKey()


=head2 setHead()


=head2 getHead()


=head2 getWords()


=head2 getOccurrences()


=head2 buildLinguisticInfos()


=head2 getIF()


=head2 getLF()


=head2 getPOS()


=head2 getFrequency()


=head2 setReliability()


=head2 getReliability()


=head2 getOriginalPhrase()


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
