package Lingua::YaTeA::MultiWordPhrase;
use strict;
use Lingua::YaTeA::Phrase;
use Lingua::YaTeA::MultiWordUnit;
use Lingua::YaTeA::Tree;
use Lingua::YaTeA::IndexSet;
use UNIVERSAL qw(isa);
use Data::Dumper;
use NEXT;
use base qw(Lingua::YaTeA::Phrase Lingua::YaTeA::MultiWordUnit);

our $counter = 0;
our $parsed = 0;

sub new
{
    my ($class_or_object,$num_content_words,$words_a,$tag_set) = @_;
    my $this = shift;
    $this = bless {}, $this unless ref $this;
    $this->{ISLAND_SET} = ();
    $this->NEXT::new(@_);
     return $this;
}




sub searchEndogenousIslands
{
    my ($this,$phrase_set,$chunking_data,$tag_set,$lexicon,$sentence_set) = @_;
    my $sub_indexes_set_a = $this->getIndexSet->searchSubIndexesSet($this->getWords,$chunking_data,$tag_set,$lexicon,$sentence_set);
    my $sub_index;
    my $source_a;
    my $corrected = 0;
    if(scalar  @$sub_indexes_set_a > 0)
    {
	foreach $sub_index (@$sub_indexes_set_a)
	{
	    if(
		(!defined $this->getIslandSet)
		||
		(
		 (! $this->getIslandSet->existIsland($sub_index))
		 &&
		 (! $this->getIslandSet->existLargerIsland($sub_index))
		)
		)
	    {
		if($source_a = $phrase_set->searchFromIF($sub_index->buildIFSequence($this->getWords)))
		{
		    $this->makeIsland($sub_index,$source_a,'endogenous','IF',$tag_set,$lexicon,$sentence_set);
		}
		else
		{
		    if($source_a = $phrase_set->searchFromLF($sub_index->buildLFSequence($this->getWords)))
		    {
			if($this->makeIsland($sub_index,$source_a,'endogenous','LF',$tag_set,$lexicon,$sentence_set) == 1)
			{
			    $corrected =1;
			}
		    }
		}
	    }
	}
    }
    return ($this->checkParseCompleteness,$corrected);
}







sub integrateIsland
{
    my ($this,$island,$tagset,$lexicon,$sentence_set) = @_;
    my $i;
    my $tree; 
    my $node_sets_a = $island->importNodeSets;   
    my $new_trees_a;
    my $new;
    my $integrated_at_least_once = 0;
    my $success;
    my $corrected = 0;

    if(!defined $this->getForest)
    {
	$tree = Lingua::YaTeA::Tree->new;
	$tree->setSimplifiedIndexSet($this->getIndexSet);
	$this->addTree($tree);
    }
    
    while ($tree = pop @{$this->getForest})
    {
	
	($success,$new_trees_a) = $tree->integrateIslandNodeSets($node_sets_a,$island->getIndexSet,$this->getWords,$tagset);
	if($success == 1)
	{
	    $integrated_at_least_once = 1;
	}
    }

    while ($new = pop @$new_trees_a)
    {
	$this->addTree($new);
    }

    if($integrated_at_least_once == 0)
    {
	$this->removeIsland($island);
    }
    else
    {
	$corrected = $this->correctPOSandLemma($island,$lexicon,$sentence_set);
    }
    return $corrected;
}

sub correctPOSandLemma
{
    my ($this,$island,$lexicon,$sentence_set) = @_;
    my $i;
    my $index;
    my $corrected = 0;

    for ($i=0; $i< scalar @{$island->getIndexSet->getIndexes}; $i++)
    {
	$index = $island->getIndexSet->getIndexes->[$i];
	if (defined ($island->getSource->getWord($i))) {
	    if  ($island->getSource->getWord($i)->getPOS ne $this->getWord($index)->getPOS)
	    {
		if(lc($island->getSource->getWord($i)->getIF) eq lc($this->getWord($index)->getIF))
		{
		    $this->correctWord($index,$island->getSource->getWord($i),"POS",$lexicon,$sentence_set);
		    $corrected = 1;
		}
	    }
	    if($island->getSource->getWord($i)->getLF ne $this->getWord($index)->getLF)
	    {
		$this->correctWord($index,$island->getSource->getWord($i),"LF",$lexicon,$sentence_set);
		$corrected = 1;
	    }
	} else {
	    warn "Word undefined\n";
	}
    }
    return $corrected;
}

sub correctWord
{
    my ($this,$index,$standard,$type,$lexicon,$sentence_set) = @_;
    my $form;
    my $new_word;
    
    if($type eq "POS")
    {
	$form = $this->{WORDS}->[$index]->getIF . "\t" . $standard->getPOS .  "\t" . $this->{WORDS}->[$index]->getLF;
		
    }
    else
    {
	$form = $this->{WORDS}->[$index]->getIF . "\t" . $this->{WORDS}->[$index]->getPOS .  "\t" . $standard->getLF;

    }
    $new_word = Lingua::YaTeA::WordFromCorpus->new($form,$lexicon,$sentence_set);
    $this->{WORDS}->[$index] = $new_word->getLexItem;
}



sub getIslandSet
{
    my ($this) = @_;
    return $this->{ISLAND_SET};
}




sub checkMaximumLength
{
    my ($this,$max_length) = @_;
    
    if($this->getLength > $max_length)
    {
	return 0;
    }
    return 1;
}


sub adjustReferences
{
    my ($this,$term_candidates_a,$current,$reference) = @_;
    my $term_candidate;
    my $island;
    
    foreach $term_candidate (@$term_candidates_a)
    {
	if(isa($term_candidate,'Lingua::YaTeA::MultiWordTermCandidate'))
	{
	    if($term_candidate->getRootHead->getID == $current->getID)
	    {
		$term_candidate->{ROOT_HEAD} = $reference;
	    }
	    if($term_candidate->getRootModifier->getID == $current->getID)
	    {
		$term_candidate->{ROOT_MODIFIER} = $reference;
	    }
	}
    }

}

sub existIsland
{
    my ($this,$index) = @_;
    if(! defined $this->getIslandSet)
    {
	return 0;
    }
    return $this->getIslandSet->existIsland($index);
}

sub makeIsland
{    my ($this,$index,$source_a,$type,$access,$tag_set,$lexicon,$sentence_set) = @_;
    my $source;
    my $s;
    my $island;
     my $corrected;
    
     if($type eq "endogenous")
     {
	 $source = $index->chooseBestSource($source_a,$this->getWords,$tag_set);
     }
     else
     {
	$source = $source_a->[0]; 
     }
    
    $island = Lingua::YaTeA::Island->new($index,$type,$source); 
    $this->addIsland($island);

     if(isa($this,'Lingua::YaTeA::MultiWordPhrase'))
     {
	 
	 $corrected = $this->integrateIsland($island,$tag_set,$lexicon,$sentence_set);
     }
     return $corrected;
}

sub removeIsland
{
    my ($this,$island) = @_;
    $this->getIslandSet->removeIsland($island);
}

sub addIsland
{
    my ($this,$island) = @_;
    if(!defined $this->getIslandSet)
    {
	$this->{ISLAND_SET} = Lingua::YaTeA::IslandSet->new;
    }
    $this->getIslandSet->addIsland($island);
}


sub getParsablePotentialIslands
{
    my ($this,$parsing_pattern_set,$tag_set,$parsing_direction) = @_;
    my %potential_islands;
    my $concurrent_set_a;
    my $concurrent;
    my $key;
    
    while (($key,$concurrent_set_a) = each (%{$this->getTestifiedTerms}))
    {
	# islands can be created only from MultiWordTestifiedTerm
	if(isa($concurrent_set_a->[0],'Lingua::YaTeA::MultiWordTestifiedTerm'))
	{
	    foreach $concurrent (@$concurrent_set_a)
	    {
		# filter 1a : only testified terms that have a length inferior or equal to that of the phrase are kept
		if($concurrent->getLength <= $this->getLength)
		{
		    # filter 1b : only testified term that have a parse are kept  
		    if($concurrent->getIfParsable($parsing_pattern_set,$tag_set,$parsing_direction))
		    {
			push @{$potential_islands{$key}}, $concurrent;
		    }
		}
	    }
	}
	
    }
    return \%potential_islands;
}


sub getBestExogenousIslands
{
    my ($this,$potential_islands_h) = @_;
    my $concurrent_set_a;
    my $concurrent;
    my $key;
    my %preselected_islands;
    
    while (($key,$concurrent_set_a) = each (%$potential_islands_h))
    {
	# if more than one testified terms exist for a given span of text
	if(scalar @$concurrent_set_a > 1) 
	{
	    $preselected_islands{$key} =  $this->orderConcurrentPotentialIslands($key,$concurrent_set_a,\%preselected_islands);
	    
	}
	else
	{
	    $preselected_islands{$key} = $concurrent_set_a->[0];
	}
	
    }
    return \%preselected_islands;
}

sub searchExogenousIslands
{
    my ($this,$parsing_pattern_set,$tag_set,$parsing_direction,$lexicon,$sentence_set) = @_;
    my $potential_islands_h;
    my $preselected_islands_h;
    my $key;
    my $corrected = 0;
    
    $potential_islands_h = $this->getParsablePotentialIslands($parsing_pattern_set,$tag_set,$parsing_direction);
    $preselected_islands_h = $this->getBestExogenousIslands($potential_islands_h);
    
    
    my @source;
    foreach $key (sort ({$this->sortIslandKeys($a,$b)} keys %$preselected_islands_h))
    {
	my $index = Lingua::YaTeA::IndexSet->new;
	@{$index->{INDEXES}} = split /-/, $key;
	if
	    (
	     (!defined $this->getIslandSet)
	     ||
	     (
	      (! $this->getIslandSet->existIsland($index))
	      &&
	      (! $this->getIslandSet->existLargerIsland($index))
	     )
	    )
	{
	    $source[0] = $preselected_islands_h->{$key};
	    
	    if($this->makeIsland($index,\@source,'exogenous','UNKNOWN',$tag_set,$lexicon,$sentence_set) == 1)
	    {
		$corrected =1;
	    }
	}    
    }
    
    return ($this->checkParseCompleteness,$corrected);
}

sub plugInternalFreeNodes
{
    my ($this,$parsing_pattern_set,$parsing_direction,$tag_set) = @_;
    my $island;
    my $key;
    my $free_nodes_a;
    my $tree;
    my $inclusions_a;
    my $pair_a;
    my $above;
    my $below;
    my $additional_node_set;
    my $success;
    my $tree_updated;
    my $unplugged_a;
    my $unplugged;
    my $unplugged_index_set;
    my %unexploitable_islands;
    my @tmp_forest;
    my @new_trees;
    
    if(defined $this->getForest)
    {
	foreach  $tree (@{$this->getForest})
	{
	    $tree_updated = 0;
	    $free_nodes_a = $tree->getNodeSet->searchFreeNodes($this->getWords);
	    if(scalar @$free_nodes_a  > 1)
	    {
		$inclusions_a = $this->getIncludedNodes($free_nodes_a);
		foreach $pair_a (@$inclusions_a)
		{
		    $above = $pair_a->[0];
		    $below = $pair_a->[1];
		    
		    ($success,$additional_node_set) = $above->plugInternalNode($below,$pair_a->[2],$pair_a->[3],$parsing_pattern_set,$this->getWords,$parsing_direction,$tag_set);
		    if($success == 1)
		    {
			$tree->addNodes($additional_node_set);
		
			$tree->getSimplifiedIndexSet->removeIndex($pair_a->[1]->searchHead->getIndex);
			$tree->updateRoot;
		    }
		}
	    }
	    $tree->completeDiscontinuousNodes($parsing_pattern_set,$parsing_direction,$tag_set,$this->getWords);
	    ($tree_updated,$unplugged_a) = $tree->removeDiscontinuousNodes($this->getWords);
	    
	    if($tree_updated == 1)
	    {
		
		if(scalar @{$tree->getNodeSet->getNodes} > 0)
		{
		    $tree->updateIndexes($this->getIndexSet,$this->getWords);
		    if(scalar @$unplugged_a > 0)
		    {
			foreach $unplugged (@$unplugged_a)
			{
			    $free_nodes_a = $tree->getNodeSet->searchFreeNodes($this->getWords);
			    $unplugged->hitchMore($free_nodes_a,$tree,$this->getWords);
			}
		    }
		    push @tmp_forest, $tree;
		    
		}
		
	    }
	    else
	    {
		push @tmp_forest, $tree;
	    }
	}
	if(scalar @tmp_forest > 0)
	{
	    @{$this->getForest} = @tmp_forest;
	}
	else
	{
	    undef $this->{FOREST};
	}
    }
    
}



sub getIncludedNodes
{
    my ($this,$free_nodes_a) = @_;
    my $node;
    my $index_set;
    my %index_key_to_nodes;
    my @index_sets;
    my $included_a;
    my $included;
    my @node_inclusions;
    foreach $node (@$free_nodes_a)
    {
	$index_set = Lingua::YaTeA::IndexSet->new;
	$node->fillIndexSet($index_set);
	$index_key_to_nodes{$index_set->joinAll('-')} = $node;
	push @index_sets, $index_set;
    }   
    foreach $index_set (@index_sets)
    {
	$included_a = $index_set->getIncluded(\@index_sets);
	
	foreach $included (@{$included_a})
	{
	    my @pair;
	    $pair[0] = $index_key_to_nodes{$index_set->joinAll('-')};
	    $pair[1] = $index_key_to_nodes{$included->joinAll('-')};
	    ($pair[2],$pair[3]) = $index_set->getIncludedContext($included);
	    push @node_inclusions,\@pair;
	}
    }
    return \@node_inclusions;
}


sub checkParseCompleteness
{
    my ($this) = @_;
    my @uncomplete_trees;
    my @complete_trees;
    my $tree;
    my $parsed =0;

    if(!defined $this->getForest)
    {
	return 0;
    }
    else
    {
	while ($tree = pop @{$this->getForest})
	{
	    if($tree->getSimplifiedIndexSet->getSize == 1)
	    {
		$parsed = 1;
		$tree->setHead;
		$tree->setReliability(3);
		push @complete_trees, $tree;
	    }
	    else
	    {
		push @uncomplete_trees, $tree;
	    }
	}
    }
    if($parsed == 1)
    {
	@{$this->{FOREST}} = @complete_trees;
	return 1;
    }
    else
    {
	@{$this->{FOREST}} = @uncomplete_trees;
	return 0;
    }
}

sub orderConcurrentPotentialIslands
{
    my ($this,$key,$concurrent_set_a) = @_;
    my $concurrent;
    my $inflected_score;
    my %inflected_form_scores;
    my @sorted_scores;
    my $best_set_a;
    
    # filter 2 : compare inflected forms
    foreach $concurrent (@$concurrent_set_a)
    {
	$inflected_score = $this->compareInflectedFormWithTestified($concurrent,$key);
	push @{$inflected_form_scores{$inflected_score}}, $concurrent;
    }
    @sorted_scores = sort ({ $b <=> $a } keys (%inflected_form_scores)) ;
    
    $best_set_a = $inflected_form_scores{$sorted_scores[0]};
    
    # filter 3 : compare POS sequence
    # if several testified terms have the same inflected and lemmatized forms
    if(scalar @$best_set_a > 1)
    {
	@$best_set_a = sort ({$this->sortPotentialIslandsAccordingToPOS($a,$b,$key)} @$best_set_a) ;
       
    }
    
    return $best_set_a->[0];
}



sub sortIslandKeys
{
    my ($this,$first,$second) = @_;
    my @first_index = split /-/, $first;
    my @second_index = split /-/, $second;
    return (scalar @second_index <=> scalar @first_index);
}


sub sortPotentialIslandsAccordingToPOS
{
    my ($this,$first,$second,$key) = @_;
    return ($this->comparePOSWithTestified($second,$key) <=> $this->comparePOSWithTestified($first,$key));
}


sub compareInflectedFormWithTestified
{
    my ($this,$testified_term,$key) = @_; 
    my $i;
    my $j;
    my $score = 0;
    my @index = split(/-/,$key); 
    for ($i = $index[0]; $i <= $index[$#index]; $i++)
    {
	for ($j = 0; $j < scalar @index; $j++)
	{
	    if($this->getWord($i)->getIF eq $testified_term->getWord($j)->getIF)
	    {
		$score++;
	    }
	}
    }
    return $score;
}


sub comparePOSWithTestified
{
    my ($this,$testified_term,$key) = @_; 
    my $i;
    my $j;
    my $score = 0;
    my @index = split(/-/,$key); 
    for ($i = $index[0]; $i <= $index[$#index]; $i++)
    {
	for ($j = 0; $j < scalar @index; $j++)
	{
	    if($this->getWord($i)->getPOS eq $testified_term->getWord($j)->getPOS)
	    {
		$score++;
	    }
	}
    }
    return $score;
}


sub printIslands
{
    my ($this,$fh) = @_;

    if(defined $fh)
    {
	if(defined $this->getIslandSet)
	{
	    print $fh " " . $this->getIslandSet->size . "\n";
	    $this->getIslandSet->print($fh);
	}
	else
	{
	    print $fh " 0\n";
	}
    }
    else
    {
	if(defined $this->getIslandSet)
	{
	    print "\n";
	    $this->getIslandSet->print;
	}
	else
	{
	    print "0\n";
	}
    }
}

sub print 
{
    my ($this,$fh) = @_;
  
    if(defined $fh)
    {

	print $fh  "if: " . $this->getIF . "\n";
	print $fh "pos: " . $this->getPOS . "\n";
	print $fh "lf: " . $this->getLF . "\n";
	print $fh "is a term candidate: " . $this->isTC. "\n";
	if($this->isTC)
	{
	    print $fh "parsing method: ". $this->getParsingMethod . "\n";
	    print $fh "forest: " ;
	    $this->printForestParenthesised($fh);
	    
	}
	print $fh "islands:";
	$this->printIslands($fh);
	
    }
    else
    {
	print  "if: " . $this->getIF . "\n";
	print "pos: " . $this->getPOS . "\n";
	print "lf: " . $this->getLF . "\n";
	print "is a term candidate: " . $this->isTC. "\n";
	if($this->isTC)
	{
	    print "parsing method: ". $this->getParsingMethod . "\n";
	    print "forest: " ;
	    $this->printForestParenthesised;
	    
	}
	print "islands:";
	$this->printIslands;
	print "\n";
    }
}


sub printDebug
{
    my ($this, $debugFile) = @_;

    print $debugFile "\n\n";
    print $debugFile "$this\n";
    print $debugFile $this->{'IF'} . "\n";
    $this->print($debugFile);
    $this->printForestParenthesised($debugFile);
    print $debugFile "\n\n";

}


1;


__END__

=head1 NAME

Lingua::YaTeA::MultiWordPhrase - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::MultiWordPhrase;
  Lingua::YaTeA::MultiWordPhrase->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 searchEndogenousIslands()


=head2 integrateIsland()


=head2 correctPOSandLemma()


=head2 correctWord()


=head2 getIslandSet()


=head2 checkMaximumLength()


=head2 adjustReferences()


=head2 existIsland()


=head2 makeIsland()


=head2 removeIsland()


=head2 addIsland()


=head2 getParsablePotentialIslands()


=head2 getBestExogenousIslands()


=head2 searchExogenousIslands()


=head2 plugInternalFreeNodes()


=head2 getIncludedNodes()


=head2 checkParseCompleteness()


=head2 orderConcurrentPotentialIslands()


=head2 sortIslandKeys()


=head2 sortPotentialIslandsAccordingToPOS()


=head2 compareInflectedFormWithTestified()


=head2 comparePOSWithTestified()


=head2 printIslands()


=head2 print()


=head2 printDebug()


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
