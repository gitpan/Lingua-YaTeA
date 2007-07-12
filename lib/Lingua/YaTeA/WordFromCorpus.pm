package Lingua::YaTeA::WordFromCorpus;
use strict;
use Lingua::YaTeA::WordOccurrence;
use UNIVERSAL qw(isa);

our @ISA = qw(Lingua::YaTeA::WordOccurrence);
our $counter = 0;

sub new
{
    my ($class,$form,$lexicon,$sentences) = @_;
    my $this = $class->SUPER::new($form);
    bless ($this,$class);
    $this->{ID} = $counter;
    $this->{LEX_ITEM} = $this->setLexItem($form,$lexicon);    
    $this->{SENTENCE} = $sentences->getCurrent;
    $this->{START_CHAR} = $Lingua::YaTeA::Sentence::start_char;
    return $this;
}


sub setLexItem
{
    my ($this,$form,$lexicon) = @_;
    return $lexicon->addOccurrence($form);
}


sub getID
{
    my ($this) = @_;
    return $this->{ID};
}


sub getSentence
{
    my ($this) = @_;
    return $this->{SENTENCE};
}

sub getDocument
{
    my ($this) = @_;
    return $this->getSentence->getDocument;
}

sub getSentenceID
{
    my ($this) = @_;
    return $this->getSentence->getID;
}

sub getDocumentID
{
    my ($this) = @_;
    return $this->getSentence->getDocument->getID;
}

sub getStartChar
{
    my ($this) = @_;
    return $this->{START_CHAR};
}

sub getLexItem
{
    my ($this) = @_;
    return $this->{LEX_ITEM};
}

sub isSentenceBoundary
{
    my ($this,$sentence_boundary) = @_;
   
    if ($this->getLexItem->getPOS eq $sentence_boundary)
    {
	return 1;
    }
    return 0;
}

sub isDocumentBoundary
{
    my ($this,$document_boundary) = @_;
   
    if ($this->getLexItem->getPOS eq $document_boundary)
    {
	return 1;
    }
    return 0;
}



sub updateSentence
{
    my ($this,$sentences) = @_;
    $this->{SENTENCE} = $sentences->getCurrent;
}

sub updateStartChar
{
    my ($this) = @_;
    $this->{START_CHAR} = $Lingua::YaTeA::Sentence::start_char;
}

sub isChunkingFrontier
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	# word is a chunking frontier
	if ($chunking_data->existData("ChunkingFrontiers",$type,$this->getLexItem->{$type}) == 1)
	{
	    # word is not a chunking exception : end
	    if (! $this->isChunkingException($chunking_data) )
	    {
		
		return 1;
	    }
	    return 0;
	}
    }
    return 0;
}

sub isChunkingException
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	if ($chunking_data->existData("ChunkingExceptions",$type,$this->getLexItem->{$type}) == 1)
	{
	    return 1;
	}
    }
    return 0;
}

sub isCleaningFrontier
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	if ($chunking_data->existData("CleaningFrontiers",$type,$this->getLexItem->{$type}) == 1)
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
	if ($chunking_data->existData("CleaningExceptions",$type,$this->getLexItem->{$type}) == 1)
	{
	    return 1;
	}
    }
    return 0;
}

sub isCompulsory
{
    my ($this,$compulsory) = @_;
#    my $compuslory = $options->getCompulsory;
    
    if # (
# 	(isa($this, "Lingua::YaTeA::TestifiedTermMark"))
# 	||
	($this->getLexItem->getPOS =~ /$compulsory/) 
#	)
    {
	return 1;
    }
    return 0;
}

sub getPOS
{
    my ($this) = @_;
    return $this->getLexItem->getPOS;
}

sub isEndTrigger
{
    my ($this,$end_trigger_set) = @_;
    return $end_trigger_set->findTrigger($this);
}

sub isStartTrigger
{
    my ($this,$start_trigger_set) = @_;
    return $start_trigger_set->findTrigger($this);
}


sub getIF
{
    my ($this) = @_;
    return $this->getLexItem->getIF;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::WordFromCorpus - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::WordFromCorpus;
  Lingua::YaTeA::WordFromCorpus->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 setLexItem()


=head2 getID()


=head2 getSentence()


=head2 getDocument()


=head2 getSentenceID()


=head2 getDocumentID()


=head2 getStartChar()


=head2 getLexItem()


=head2 isSentenceBoundary()


=head2 isDocumentBoundary()


=head2 updateSentence()


=head2 updateStartChar()


=head2 isChunkingFrontier()


=head2 isChunkingException()


=head2 isCleaningFrontier()


=head2 isCleaningException()


=head2 isCompulsory()


=head2 getPOS()


=head2 isEndTrigger()


=head2 isStartTrigger()


=head2 getIF()



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
