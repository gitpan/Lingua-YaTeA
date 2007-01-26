package Lingua::YaTeA::PhraseSet;
use strict;
use Lingua::YaTeA::MultiWordPhrase;
use Lingua::YaTeA::MonolexicalPhrase;
use UNIVERSAL qw(isa);
use Data::Dumper;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{PHRASES} = {};
    $this->{UNPARSED} = ();
    $this->{UNPARSABLE} = ();
    $this->{IF_ACCESS} = ();
    $this->{LF_ACCESS} = ();
    $this->{TERM_CANDIDATES} = {};
    return $this;
}

sub recordOccurrence
{
    my ($this,$words_a,$num_content_words,$tag_set,$parsing_pattern_set,$option_set,$term_frontiers_h,$testified_term_set,$lexicon,$sentence_set) = @_;
    my $phrase;
    my $key;
    my $complete = 0;
    my $corrected;
    if(scalar @$words_a != 0)
    {
	if(scalar @$words_a > 0)
	{
	    if(scalar @$words_a == 1)
	    {
		$phrase = Lingua::YaTeA::MonolexicalPhrase->new($words_a,$tag_set);
	    }
	    else
	    {
		$phrase = Lingua::YaTeA::MultiWordPhrase->new($num_content_words,$words_a,$tag_set);
	    }
	    $key = $phrase->buildKey;
	    
	    if(!exists $this->getPhrases->{$key})
	    {
		$this->addPhrase($key,$phrase);
		if
		    (
		     ($option_set->optionExists('termino'))
		     &&
		     (scalar keys(%$term_frontiers_h) > 0)
		    )
		    # add testified terms here
		    
		{
		    $phrase->addTestifiedTerms($term_frontiers_h,$testified_term_set);
		  
		    
		}
		if (isa($phrase,'Lingua::YaTeA::MultiWordPhrase'))
		{
		    if(!$phrase->checkMaximumLength($option_set->getMaxLength))
		    {
			$phrase->setTC(0);
			$this->addToUnparsable($phrase);
		    }
		    else
		    {
			if (defined $phrase->getTestifiedTerms)
			{
			    ($complete,$corrected) = $phrase->searchExogenousIslands($parsing_pattern_set,$tag_set,$option_set->getParsingDirection,$lexicon,$sentence_set);
			    if($corrected == 1)
			    {
# 				print "reengistre\n";
			    }
			    if($complete == 1)
			    {
				$phrase->setTC(1);
				$phrase->setParsingMethod('TESTIFIED_MATCHING');
				$this->giveAccess($phrase);
			    }
			}
			if($complete == 0)
			{
			    if($phrase->searchParsingPattern($parsing_pattern_set,$tag_set,$option_set->getParsingDirection))
			    {
				$phrase->setTC(1);
				$phrase->setParsingMethod('PATTERN_MATCHING');
				$this->giveAccess($phrase);
				
			    }
			    else
			    {
				$this->addToUnparsed($phrase);
			    }
			}
		    }
		}
		else
		{ 

		    if ((defined $option_set->getOption('monolexical-all')) && ($option_set->getOption('monolexical-all')->getValue() == 1))
		    {
			$phrase->setTC(1);
			$phrase->setParsingMethod('MONOLEXICAL');
			$this->giveAccess($phrase);	
		    }
		    else
		    {
			
			# monolexical phrases are added to the unparsable phrase set
			$this->addToUnparsable($phrase);
		    }
		}
	    }
	    else{
		# debaptiser le phrase qui vient d'etre construit
		$phrase = $this->getPhrases->{$key};
	    }
	   
	    $phrase->addOccurrence($words_a,1);
	}
    }
}




sub addPhrase
{
    my ($this,$key,$phrase) = @_;
    $this->getPhrases->{$key} = $phrase;
    $Lingua::YaTeA::Phrase::counter++;
    if(isa($phrase,'Lingua::YaTeA::MultiWordPhrase'))
    {
	$Lingua::YaTeA::MultiWordPhrase::counter++;
    }
    else
    {
	$Lingua::YaTeA::MonolexicalPhrase::counter++;
    }
}



sub getPhrases
{
    my ($this) = @_;
    return $this->{PHRASES};
}



sub giveAccess
{
    my ($this,$phrase) = @_;
    push @{$this->{IF_ACCESS}->{$phrase->getIF}}, $phrase; 
  
    push @{$this->{LF_ACCESS}->{$phrase->getLF}}, $phrase; 
}


sub searchFromIF
{
    my ($this,$key) = @_;
    if(exists $this->{IF_ACCESS}->{$key})
    {
	return $this->{IF_ACCESS}->{$key};
    }
   
}


sub searchFromLF
{
    my ($this,$key) = @_;
    if(exists $this->{LF_ACCESS}->{$key})
    {
	return $this->{LF_ACCESS}->{$key};
    }
}


sub addToUnparsed
{
    my ($this,$phrase) = @_;

    push @{$this->{UNPARSED}},$phrase;
}

sub addToUnparsable
{
    my ($this,$phrase) = @_;
    push @{$this->{UNPARSABLE}},$phrase;
}

sub getUnparsed
{
    my ($this) = @_;
    return $this->{UNPARSED};
}



sub sortUnparsed
{
    my ($this) = @_;
    if(defined $this->{UNPARSED})
    {
	@{$this->{UNPARSED}} = sort{$b->getLength <=> $a->getLength} @{$this->{UNPARSED}}; 
    }
}

sub parseProgressively
{
    my ($this,$tag_set,$parsing_direction,$parsing_pattern_set,$chunking_data,$lexicon,$sentence_set) = @_;
    my $phrase;
    my $counter = 0;
    my $complete;
    my $corrected;
    #foreach $phrase (@{$this->getUnparsed})
    if(defined $this->{UNPARSED})
    {
	while ($phrase = pop @{$this->getUnparsed})
	{ 
	    $counter++;
	    if(($counter % 100) == 0)
	    {
		print STDERR "-";
	    }
	    ($complete,$corrected) = $phrase->searchEndogenousIslands($this,$chunking_data,$tag_set,$lexicon,$sentence_set);
	    if($corrected == 1)
	    {
		$this->updateRecord($phrase,$tag_set);
		print "reenregistre2\n";
	    }
	    $phrase->plugInternalFreeNodes($parsing_pattern_set,$parsing_direction,$tag_set);
	    if($phrase->parseProgressively($tag_set,$parsing_direction,$parsing_pattern_set,$chunking_data))
	    {
		$phrase->setParsingMethod('PROGRESSIVE');
		$phrase->setTC(1);
		$this->giveAccess($phrase);
	    }
	    else
	    {
		$phrase->setTC(0);
		$this->addToUnparsable($phrase);
	    }
	}
	print STDERR "\n";
    }
    
}

sub updateRecord
{
    my ($this,$phrase,$tag_set) = @_;
    my $key;
    my $reference;
    
    $key = $phrase->buildKey;
    
    if(exists $this->getPhrases->{$key})
    {
	delete $this->getPhrases->{$key};

    }

    $phrase->buildLinguisticInfos($phrase->getWords,$tag_set);
    $key = $phrase->buildKey;
    
     if(exists $this->getPhrases->{$key})
    {
	$reference = $this->getPhrases->{$key};
	$reference->addOccurrences($phrase->getOccurrences);
    }
    else
    {
	$this->getPhrases->{$key} = $phrase;
    }
}


sub getUnparsable
{
    my ($this) = @_;
    return $this->{UNPARSABLE};
}



sub getIFaccess
{
    my ($this) = @_;
    return $this->{IF_ACCESS};
}

sub addTermCandidates
{
    my ($this,$option_set) = @_;
    my $phrase;
    my $phrase_set;
    my $term_candidate;
    my %mapping_from_phrases_to_TCs_h;
    my %monolexical_transfer;
   
   
    if(defined $this->getIFaccess)
    {
	foreach $phrase_set (values (%{$this->getIFaccess}))
	{
	    foreach $phrase (@$phrase_set){
		$phrase->addTermCandidates($this->getTermCandidates,\%mapping_from_phrases_to_TCs_h,$option_set,$this->getPhrases,\%monolexical_transfer);
	    }
	}
    }
    foreach $term_candidate (values (%{$this->getTermCandidates}))
	{
	
	if(
	    (isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate'))
	    &&
	    ($term_candidate->containsIslands)
	    )
	{
	    $term_candidate->adjustIslandReferences(\%mapping_from_phrases_to_TCs_h);
	}
    }
    if ((defined $option_set->getOption('monolexical-included')) && ($option_set->getOption('monolexical-included')->getValue() == 1))
    {
	$this->adjustMonolexicalPhrasesSet(\%monolexical_transfer);
    }
}


sub adjustMonolexicalPhrasesSet
{
    my ($this,$monolexical_transfer_h) = @_;
    my @adjusted_list;
    my $phrase;
    
    if(defined $this->{UNPARSABLE})
    {
	while ($phrase = pop @{$this->getUnparsable})
	{
	    if
		(
		 (isa($phrase,'Lingua::YaTeA::MultiWordPhrase'))
		 ||
		 (!exists $monolexical_transfer_h->{$phrase->getID})
		)
	    {
		push @adjusted_list, $phrase;
	    }
	}
    }
    @{$this->{UNPARSABLE}} = @adjusted_list;
}

sub getTermCandidates
{
    my ($this) = @_;
    return $this->{TERM_CANDIDATES};
}


sub printTermList
{
    my ($this,$file,$term_list_style) = @_;
    my $fh = FileHandle->new(">".$file->getPath);
    my $term_candidate;
    
    print $fh "Inflected form\tFrequency\n";
   foreach $term_candidate ( sort ({$b->getFrequency <=> $a->getFrequency} values(%{$this->getTermCandidates})))
   {

       if(
	   ($term_list_style eq "")
	   ||
	   ($term_list_style eq "all")
	   ||
	   (
	    ($term_list_style eq "multi") 
	    &&
	    (isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate')) 
	   )
           )
	   
       {
	   print $fh $term_candidate->getIF. "\t" . $term_candidate->getFrequency . "\t\t\n";
       }
   }
}

sub printUnparsable
{
    my ($this,$file) = @_;
    my $phrase;
    my $fh = FileHandle->new(">".$file->getPath);
    foreach $phrase (@{$this->getUnparsable})
    {
	if(isa($phrase,'Lingua::YaTeA::MultiWordPhrase'))
	{
	    print $fh $phrase->getIF . "\t" . $phrase->getPOS . "\n";
	}
    }
}

sub printTermCandidatesTTG
{
    my ($this,$file,$ttg_style) = @_;
    
    my $fh = FileHandle->new(">".$file->getPath);
    my $term_candidate;
    my $word;
    
    foreach $term_candidate (values(%{$this->getTermCandidates}))
    {
	if
	    (
	     ($ttg_style eq "")
	     ||
	     ($ttg_style eq "all")
	     ||
	     (
	      ($ttg_style eq "multi")
	      &&
	      (isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate')) 
	     )
	    )
	{
	    foreach $word (@{$term_candidate->getWords})
	    {
		print $fh $word->getIF . "\t" . $word->getPOS . "\t" . $word->getLF . "\n";
	    }
	    print $fh "\.\tSENT\t\.\n";
	}
    }
}

sub printTermCandidatesXML
{
    my ($this,$file,$tagset) = @_;
    
    my $fh = FileHandle->new(">".$file->getPath);
    my $term_candidate;
    my $if;
    my $pos;
    my $lf;
    my $occurrence;
    my $island;
    my $position;

    # header
    print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n";
    print $fh "<!DOCTYPE TERM_EXTRACTION_RESULTS SYSTEM \"extracteurDeTermes.dtd\">\n";
    print $fh "\n";
    print $fh "<TERM_EXTRACTION_RESULTS>\n";
    print $fh "  <LIST_TERM_CANDIDATES>\n";

    foreach $term_candidate (values(%{$this->getTermCandidates}))
    {
	($if,$pos,$lf) = $term_candidate->buildLinguisticInfos($tagset);
	print $fh "    <TERM_CANDIDATE>\n";
	print $fh "      <ID>term" . $term_candidate->getID . "</ID>\n";
	print $fh "      <FORM>" . $if . "</FORM>\n";
	print $fh "      <LEMMA>" . $lf . "</LEMMA>\n";
	print $fh "      <MORPHOSYNTACTIC_FEATURES>\n";
	print $fh "	    <SYNTACTIC_CATEGORY>" .$pos  . "</SYNTACTIC_CATEGORY>\n"; 
	print $fh "      </MORPHOSYNTACTIC_FEATURES>\n";
	print $fh "      <HEAD>term" . $term_candidate->getHead->getID . "</HEAD>\n";

	# occurrences
	print $fh "      <NUMBER_OCCURRENCES>". $term_candidate->getFrequency . "</NUMBER_OCCURRENCES>\n";
	print $fh "      <LIST_OCCURRENCES>\n";
	foreach $occurrence (@{$term_candidate->getOccurrences})
	{
	    print $fh "      <OCCURRENCE>\n";
	    print $fh "        <ID>occ" . $occurrence->getID . "</ID>\n";
	    print $fh "        <MNP>" .$occurrence->isMaximal .  "</MNP>\n";
	    print $fh "        <DOC>" .$occurrence->getDocument->getID . "</DOC>\n";
	    print $fh "        <SENTENCE>" .$occurrence->getSentence->getInDocID . "</SENTENCE>\n";
	    print $fh "        <START_POSITION>";
	    print $fh $occurrence->getStartChar;
	    print $fh "</START_POSITION>\n";
	    print $fh "        <END_POSITION>";
	    print $fh $occurrence->getEndChar;
	    print $fh "</END_POSITION>\n";
	    print $fh "        </OCCURRENCE>\n";
	}
	print $fh "      </LIST_OCCURRENCES>\n";
	print $fh "      <TERM_CONFIDENCE>" . $term_candidate->getReliability . "</TERM_CONFIDENCE>\n"; 

	# islands of reliability
	if(
	    (isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate'))
	    &&
	    ($term_candidate->containsIslands)
	    )
	{
	    print $fh "      <LIST_RELIABLE_ANCHORS>\n";
	    foreach $island (@{$term_candidate->getIslands})
	    {
		print $fh "        <RELIABLE_ANCHOR>\n";
		if(isa($island,'Lingua::YaTeA::TermCandidate'))
		{
		    print $fh "          <ID>term";
		    print $fh $island->getID;
		}
		else
		{
		    print $fh "          <ID>testified_term";
		    print $fh $island->getID;
		}
		print $fh "</ID>\n";
		print $fh "          <FORM>";
		print $fh $island->getIF;
		print $fh "</FORM>\n";
		print $fh "          <ORIGIN>";
		print $fh $island->getIslandType;
		print $fh "</ORIGIN>\n";
		print $fh "        </RELIABLE_ANCHOR>\n";
	    }
	    print $fh "      </LIST_RELIABLE_ANCHORS>\n";
	}
	print $fh "      <LOG_INFORMATION>YaTeA</LOG_INFORMATION>\n";
	if(isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate'))
	{
	    print $fh "      <SYNTACTIC_ANALYSIS>\n";
	    print $fh "        <HEAD>\n        term";
	    print $fh $term_candidate->getRootHead->getID;
	    print $fh "\n        </HEAD>\n";
	    print $fh "        <MODIFIER POSITION=\"";
	    print $fh $term_candidate->getModifierPosition;	
	    print $fh "\">\n        term";
	    print $fh $term_candidate->getRootModifier->getID;
	    print $fh "\n        </MODIFIER>\n";
	    if(defined $term_candidate->getPreposition)
	    {
		print $fh "        <PREP>\n        ";
		print $fh $term_candidate->getPreposition->getIF;
		print $fh "\n        </PREP>\n";
	    }
	    if(defined $term_candidate->getDeterminer)
	    {
		print $fh "        <DETERMINER>\n        ";
		print $fh $term_candidate->getDeterminer->getIF;
		print $fh "\n        </DETERMINER>\n";
	    }
	    print $fh "      </SYNTACTIC_ANALYSIS>\n";
	}
	print $fh "    </TERM_CANDIDATE>\n";
    }
    print $fh "  </LIST_TERM_CANDIDATES>\n";
    print $fh "</TERM_EXTRACTION_RESULTS>\n";
   
}








sub print
{
    my ($this,$fh) = @_;
    my $phrase;
      if(!defined $fh)
    {
	$fh = "STDOUT";
    }
    foreach $phrase (values(%{$this->getPhrases}))
    {
	$phrase->print($fh);
	print $fh "\n";
    }
}



sub printPhrases
{
    my ($this,$file) = @_;
    my $phrase;
    
    my $fh = FileHandle->new(">".$file->getPath);
    
    if(!defined $fh)
    {
	$fh = "STDOUT";
    }
    
    foreach $phrase (values(%{$this->getPhrases}))
    {
	$phrase->print($fh);
	print $fh "\n-----------------\n\n";
    }
}

sub printChunkingStatistics
{
    my ($this,$message_set,$display_language) = @_;
    print STDERR "\t" . $message_set->getMessage('PHRASES_NUMBER')->getContent($display_language) . $Lingua::YaTeA::Phrase::counter . "\n";
    print STDERR "\t  -" . $message_set->getMessage('MULTIWORDPHRASES_NUMBER')->getContent($display_language) . $Lingua::YaTeA::MultiWordPhrase::counter . "\n";
    print STDERR "\t  -" . $message_set->getMessage('MONOLEXICALPHRASES_NUMBER')->getContent($display_language) . $Lingua::YaTeA::MonolexicalPhrase::counter . "\n";
}

sub printParsingStatistics
{
    my ($this,$message_set,$display_language) = @_;
    print STDERR "\t" . $message_set->getMessage('PARSED_PHRASES_NUMBER')->getContent($display_language) . $Lingua::YaTeA::MultiWordPhrase::parsed . "\n";
}

1;
