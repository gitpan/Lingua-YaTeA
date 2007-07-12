package Lingua::YaTeA::MonolexicalTermCandidate;
use strict;
use Lingua::YaTeA::TermCandidate;

our @ISA = qw(Lingua::YaTeA::TermCandidate);

sub new
{
    my ($class) = @_;
    my $this = $class->SUPER::new;
    bless ($this,$class);
    return $this;
}

sub searchHead
{
    my ($this) = @_;
    return $this;
}

sub setOccurrences
{
    my ($this,$phrase_occurrences_a,$offset,$word_length,$maximal) = @_;
    my $phrase_occurrence;
    
    foreach $phrase_occurrence (@$phrase_occurrences_a)
    {
	my $occurrence = Lingua::YaTeA::Occurrence->new;
	$occurrence->{SENTENCE} =  $phrase_occurrence->getSentence;
	$occurrence->{START_CHAR} = $phrase_occurrence->getStartChar + $offset;
	$occurrence->{END_CHAR} = $phrase_occurrence->getStartChar + $offset + $word_length;
	$occurrence->{MAXIMAL} = $maximal;
	$this->addOccurrence($occurrence);
    }

}

sub getPOS
{
    my ($this) = @_;
    return $this->getWords->[0]->getPOS;
}

sub getIF
{
    my ($this) = @_;
    return $this->getWords->[0]->getIF;
}

sub addMonolexicalOccurrences
{
    my ($this,$phrase_set,$monolexical_transfer_h) = @_;
    my $key = $this->getIF . "~" . $this->getPOS . "~" . $this->getLF;
    my $occurrences_a;
    if(exists $phrase_set->{$key})
    {
	$occurrences_a = $phrase_set->{$key}->getOccurrences;
	$this->addOccurrences($occurrences_a);
	$phrase_set->{$key}->setTC(1);
	$monolexical_transfer_h->{$phrase_set->{$key}->getID}++;
    }
}

sub getHeadAndLinks
{
    my ($this,$LGPmapping_h) = @_;
    my $head = $this->getWord(0);
    my @links;
    return ($head,0,\@links);
}


1;


__END__

=head1 NAME

Lingua::YaTeA::MonolexicalTermCandidate - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::MonolexicalTermCandidate;
  Lingua::YaTeA::MonolexicalTermCandidate->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 searchHead()


=head2 setOccurrences()


=head2 getPOS()


=head2 getIF()


=head2 addMonolexicalOccurrences()


=head2 getHeadAndLinks()




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
