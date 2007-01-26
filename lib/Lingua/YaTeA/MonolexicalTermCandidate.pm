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
