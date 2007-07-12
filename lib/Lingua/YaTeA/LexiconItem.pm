package Lingua::YaTeA::LexiconItem;
use strict;

our $counter =0;

sub new
{
    my ($class,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $counter;
    my @lex_infos = split /\t/, $form;
    $this->{IF} = $lex_infos[0];
    $this->{POS} = $lex_infos[1];
    $this->{LF} = $this->setLF($lex_infos[2],$this->{IF});
    $this->{LENGTH} = $this->setLength;
    $this->{FREQUENCY} = 0;
    return $this;
}


sub setLF
{
    my ($this,$LF,$IF) = @_;
    if ($LF =~ /(\<unknown\>)|(\@card@)/){ # si le lemme est inconnu du tagger (TTG) : lemme = forme flechie
	return $IF;               
    } 
    return $LF;
} 

sub setLength
{
    my ($this) = @_;
    return length($this->{IF});
}

sub incrementFrequency
{
    my ($this) = @_;
    $this->{FREQUENCY}++;
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
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

sub getLength
{
    my ($this) = @_;
    return $this->{LENGTH};
}

sub getFrequency
{
    my ($this) = @_;
    return $this->{FREQUENCY};
}

sub getAny
{
    my ($this,$field) = @_;
    return $this->{$field};
}

sub isCleaningFrontier
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	if ($chunking_data->existData("CleaningFrontiers",$type,$this->getAny($type)) == 1)
	{
	    if (! $this->isCleaningException($chunking_data))
	    {
		return 1;
	    }
	}
    }
    return 0;
}

sub isCleaningException
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	if ($chunking_data->existData("CleaningExceptions",$type,$this->getAny($type)) == 1)
	{
	    return 1;
	}
    }
    return 0;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::LexiconItem - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::LexiconItem;
  Lingua::YaTeA::LexiconItem->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 setLF()


=head2 setLength()


=head2 incrementFrequency()


=head2 getID()


=head2 getIF()


=head2 getPOS()


=head2 getLF()


=head2 getLength()


=head2 getFrequency()


=head2 getAny()


=head2 isCleaningFrontier()


=head2 isCleaningException()



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
