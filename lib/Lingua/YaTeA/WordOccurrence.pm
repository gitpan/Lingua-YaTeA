package Lingua::YaTeA::WordOccurrence;
use strict;
use Lingua::YaTeA::ChunkingDataSet;
use UNIVERSAL qw(isa);

sub new
{
    my ($class,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{FORM} = $this->setForm($form);
    return $this;
}

sub setForm
{
    my ($this,$form) = @_;
    $this->{FORM} = $form;
}

sub getForm
{
    my ($this,$form) = @_;
    return $this->{FORM};
}

sub isChunkEnd
{
    my ($this,$action,$split_after,$sentence_boundary,$document_boundary,$chunking_data) = @_;
    
    if(isa($this, "Lingua::YaTeA::WordFromCorpus"))
    {
	$$split_after--;
	if($$split_after == 0)
	{
	    return 1;
	}
	if ( # word is a sentence or document boundary : end 
	    ($this->isSentenceBoundary($sentence_boundary) == 1)
	    ||
	    ($this->isDocumentBoundary($document_boundary) == 1)
	    )
	{
	    return 1;
	}
	# Test if word is a chunking frontier
	if ($this->isChunkingFrontier($chunking_data))
	{
	    if($Lingua::YaTeA::Corpus::tt_counter == 0)
	    {
		return 1;
	    }
	}

    }
    else{
	if(isa($this, "Lingua::YaTeA::ForbiddenStructureMark"))
	{
	    if ($this->isOpener)
	    {
		$Lingua::YaTeA::Corpus::forbidden_counter ++;
		$$action = $this->getAction;
		if($$action eq "split")
		{
		    
		    $$split_after = $this->getSplitAfter +1;
		}
	    }
	    else{
		if ($this->isCloser)
		{
		    $Lingua::YaTeA::Corpus::forbidden_counter --;
		    if($Lingua::YaTeA::Corpus::tt_counter == 0)
		    {
			return 1;
		    }
		}	
		else{
		    die "erreur\n";
		}
	    }	
	}
	else
	{
	    if(isa($this, 'Lingua::YaTeA::TestifiedTermMark'))
	    {
		if ($this->isOpener)
		{
		    $Lingua::YaTeA::Corpus::tt_counter++;
		}
		else
		{
		    if ($this->isCloser)
		    {
			$Lingua::YaTeA::Corpus::tt_counter--;
		    }
		}
		return 0;
	    }
	}
    }
    
    if( # word is in a forbidden structure but out of testified term frontiers: end
	($Lingua::YaTeA::Corpus::forbidden_counter != 0)
	&&
	($Lingua::YaTeA::Corpus::tt_counter == 0)
	)
    {
	if ($$action eq "delete")
	{
	    return 1;
	}
	else{
	   
	   # $Lingua::YaTeA::Corpus::split_counter--;
	   # if($Lingua::YaTeA::Corpus::split_counter == 0)
	    
	    #return 0;
	}
	return 0;
    }
    if ($Lingua::YaTeA::Corpus::tt_counter != 0){ # word is between testified term frontiers: not end
	return 0;
    }

}

sub print
{
    my ($this) = @_;
    print $this->getForm . "\n";
}

1;
