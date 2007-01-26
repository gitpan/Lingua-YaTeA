package Lingua::YaTeA::IndexSet;
use strict;
use UNIVERSAL qw(isa);
sub new
{
    my ($class,$words_a) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{INDEXES} = [];
    return $this;
}

sub copy
{
    my ($this) = @_;
    my $new = Lingua::YaTeA::IndexSet->new;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	push @{$new->getIndexes}, $index;
    }
    return $new;
}


sub getIndex
{
    my ($this,$rank) = @_;
    return $this->getIndexes->[$rank];
}

sub getIndexes
{
    my ($this) = @_;
    return $this->{INDEXES};
}



sub getLast
{
    my ($this) = @_;
    return $this->getIndexes->[$#{$this->getIndexes}];
}

sub getFirst
{
    my ($this) = @_;
    return $this->getIndexes->[0];
}


sub appearsIn
{
    my ($this,$larger_index_set) = @_;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	if(! $larger_index_set->indexExists($index))
	{
	    return 0;
	}
    } 
    return 1;
}


sub searchSubIndexesSet
{
    my ($this,$words_a,$chunking_data,$tag_set) = @_;
    my @sub_indexes_set;
    my $sub_index;

    my $max = (2**$this->getSize)  -1;
    my $i;

    for ($i = 1; $i <= $max; $i++)
    {
	$sub_index = $this->searchSubIndexes($i,$words_a,$this->getSize,$chunking_data,$tag_set);
	if(isa($sub_index,'Lingua::YaTeA::IndexSet')){ # the substring is valid
	    push @sub_indexes_set, $sub_index;
	    
	}
    }
   
    @sub_indexes_set = sort ({scalar @{$b->getIndexes} <=> scalar @{$a->getIndexes}}@sub_indexes_set);
    return \@sub_indexes_set;
}




sub isCoveredBy
{
    my ($this,$other_index) = @_;
    my $more_than_one_in_common = 0;
    if
	(
	 ($this->getLast <= $other_index->getFirst)
	 ||
	 ($this->getFirst >= $other_index->getLast)
	)
	{
	    # they do not cover at all;
	    return 0;
	    
    }
   #  if($this->isDisjuncted($other_index))
#     {
# 	return 0;
#     }
    else
    {
	if(
	    ($this->getFirst < $other_index->getFirst)
	    &&
	    ($this->getLast > $other_index->getLast)
	    )	
	{
	    # this one is larger than the other
	    return 0;
	}
	else
	{
	    # $more_than_one_in_common = $this->moreThanOneInCommon($other_index);
	   
	    return ($this->moreThanOneInCommon($other_index));
	}
    }
    return 1;
}
   

sub isDisjuncted
{
    my ($this,$other_index) = @_;
    if
	(
	 ($this->getLast < $other_index->getFirst)
	 ||
	 ($this->getFirst > $other_index->getLast)
	)
    {
	# they do not cover at all;
	return 1;
	
    }
    return 0;
}

sub getIncluded
{
    my ($this,$other_index_sets_a) = @_;
    my $index_set;
    my @included;
    foreach $index_set (@{$other_index_sets_a})
    {
	if(
	    ($this->getFirst < $index_set->getFirst)
	    &&
	    ($this->getLast > $index_set->getLast)
	    &&
	    (!$this->moreThanOneInCommon($index_set))
	    )	
	{
	    push @included, $index_set;
	}
    }
    return \@included;
}


sub isIncluded
{
    my ($this,$other_index,$pivot) = @_;
    if(
	($this->getFirst >= $other_index->getFirst)
	&&
	($this->getLast <= $other_index->getLast)
	&&
	(!$this->moreThanOneInCommon($other_index)
	)
	)	
    {
	if(
	    (!defined $pivot)
	    ||
	    ($this->checkInclusion($other_index,$pivot))
	    )
	{
	    return 1;
	}
	return 0;
    }
    return 0;
}


sub checkInclusion
{
    my ($this,$other_index,$pivot)  = @_;

    my $previous = $other_index->findPrevious($pivot);
    my $next =  $other_index->findNext($pivot);
    if(
	($previous == -1)
	||
	($previous < $this->getFirst)
	)
    {
	if(
	    ($next == -1)
	    ||
	    ($next > $this->getLast)
	    )
	{
	    return 1;
	}
	return 0;
    }
    return 0;
}


sub appendPosition
{
    my ($this,$pivot) = @_;
    if($pivot == $this->getFirst)
    {
	return "LEFT";
    }
    else
    {
	if($pivot == $this->getLast)
	{
	    return "RIGHT";
	}
	else
	{
	    return "MIDDLE";
	}
    }
}

sub adjunctionType
{
    my ($this,$other_index,$pivot) = @_;
    if 	($this->getFirst == $other_index->getLast)
    {
	return "ADJUNCTION_LEFT";
    }
    else
    {
	if($this->getLast == $other_index->getFirst)
	{
	    return "ADJUNCTION_RIGHT";
	}
	else
	{
	    return "ADJUNCTION_MIDDLE";
	}
    }
    return;
}

sub moreThanOneInCommon
{
    my ($this,$other_index) = @_;
    my $counter = 0;
    my $i = 0;
    my $j = 0;

    while (
	($i < $this->getSize) 
	&&
	($j < $other_index->getSize)
	)
    {
	while ($other_index->getIndex($j) == $this->getIndex($i))
	{
	    $counter++;
	    if($counter > 1)
	    {
		return 1;
	    }
	    $i++;
	    $j++;
	    if(
		($i >= $this->getSize)
		||
		($j >= $other_index->getSize)
		)
	    {
		return ($counter > 1);
	    }
	}
	
	while (
	    ($i < $this->getSize)
	    &&
	    ($this->getIndex($i) < $other_index->getIndex($j))
	    )
	{
	    $i++;
	}
	
	if(
	    ($i >= $this->getSize)
	    ||
	    ($j >= $other_index->getSize)
	    )
	{
	    return ($counter > 1);
	   
	}
	
	while (
	    ($j < $other_index->getSize)
	    &&
	    ($other_index->getIndex($j) < $this->getIndex($i))
	    )
	{
	    $j++;
	}
	

	if(
	    ($i >= $this->getSize)
	    ||
	    ($j >= $other_index->getSize)
	    )
	{
	    return ($counter > 1);
	   
	}
	
    }
    return 0;
}



sub searchSubIndexes
{
    my ($this,$i,$words_a,$size,$chunking_data,$tag_set) = @_;
    my $j;
    my $previous = -1;
    my $sub_index = Lingua::YaTeA::IndexSet->new;
    for ($j =1; $j <= $size ; $j++)
    {

	if ($i&(2**($j-1)))
	{
	    if (
		(
		 ($previous == -1) 
		 &&
		 ($words_a->[$j-1]->isCleaningFrontier($chunking_data))
		)
		||
		($previous != -1)
		)
	    {
		$previous = $j;
	#	push @sub_indexes, $indexes_a->[$j-1];
		$sub_index->addIndex($this->getIndex($j-1));
	    }
	    else
	    {
		last;
	    }
	}
    }
    if($sub_index->getSize > 1)
    {
	if(
	    ($sub_index->getSize < $this->getSize)
	    &&
 	    ($words_a->[$sub_index->getLast]->isCleaningFrontier($chunking_data))
	    && 
	    ($sub_index->testSyntacticBreakAndRepetition($words_a,$tag_set))
	    
	    )
	{
	    return $sub_index;
	}
    }
}


sub testSyntacticBreakAndRepetition
{
    my ($this,$words_a,$tag_set) = @_;
    my @absent;
    my $i;
    my %words;
    my $j = $this->getFirst;

    for($i = 1; $i < $this->getSize; $i++)
    {
	$words{$words_a->[$j]->getLF}++;
		
	if($this->getIndex($i) != ($j+1))
	{
	    while(($j+1) < $this->getIndex($i))
	    {
		if($tag_set->existTag('PREPOSITIONS',$words_a->[($j+1)]->getLF))
		{
		    return;
		}
		if($tag_set->existTag('CANDIDATES',$words_a->[($j+1)]->getPOS))
		{
		    if (exists $words{$words_a->[($j+1)]->getLF})
		    {
			return;
		    }
		}
		
		$j++;	    
	    }
	}
	else
	{
	    $j++;
	}
    }
    return 1;

}

sub buildIFSequence
{
    my ($this,$words_a) = @_;
    my $IF;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	$IF .= $words_a->[$index]->getIF . " ";
    }
    chop $IF;
    return $IF;
}

sub buildPOSSequence
{
    my ($this,$words_a,$tag_set) = @_;
    my $POS;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	if ($tag_set->existTag('PREPOSITIONS',$words_a->[$index]->getLF))
	{
	    $POS .= $words_a->[$index]->getLF . " ";
	}
	else
	{
	    $POS .= $words_a->[$index]->getPOS . " ";
	}
    }
    chop $POS;
    return $POS;
}

sub buildLFSequence
{
    my ($this,$words_a) = @_;
    my $LF;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	$LF .= $words_a->[$index]->getLF . " ";
    }
    chop $LF;
    return $LF;
}

sub buildLinguisticKey
{
    my ($this,$words_a,$tag_set) = @_;
    my $key = $this->buildIFSequence($words_a) . "~" . $this->buildPOSSequence($words_a,$tag_set) . "~" . $this->buildLFSequence($words_a); 
    return $key;
}

sub chooseBestSource
{
    my ($this,$source_a,$words_a,$tag_set) = @_;
    if(scalar @$source_a > 1)
    {
	@$source_a = sort ({$this->sortIslands($a,$b,$words_a,$tag_set)} @$source_a);
    }
    return $source_a->[0];
}

sub sortIslands
{
    my ($this,$a,$b,($words_a,$tag_set)) = @_;
    if($a->getPOS eq $b->getPOS){ # both POS are the same
	return 0;
    }
    if($a->getPOS eq $this->buildPOSSequence($words_a,$tag_set)){
	return -1; 
	
    }
    if($b->getPOS eq $this->buildPOSSequence($words_a,$tag_set)){
	return 1;
    }
    return 0;  # both POS are different and different from the wanted POS

}

sub joinAll
{
    my ($this,$joint) = @_;
    return (join ($joint, @{$this->getIndexes}));
}

sub fill
{
    my ($this,$words_a) = @_;
    my $i = 0;

    while ($i < scalar @$words_a)
    {
	push  @{$this->getIndexes}, $i++;
    }
}

sub getSize
{
    my ($this) = @_;
    return scalar @{$this->getIndexes};
}

sub addIndex
{
    my ($this,$index) = @_;
    push @{$this->getIndexes}, $index;
    @{$this->getIndexes}= sort ({$a <=> $b} @{$this->getIndexes});
}

sub getPartial
{
    my ($this,$length,$position) = @_;
    my $i;
    my $partial = Lingua::YaTeA::IndexSet->new;

    if($position eq "LEFT")
    {
	for ($i = 0; $i < $length; $i++)
	{
	    $partial->addIndex($this->getIndex($i));
	}
    }
    if($position eq "RIGHT")
    {
	for ($i = (scalar @{$this->getIndexes} - $length); $i < scalar @{$this->getIndexes}; $i++){
	     $partial->addIndex($this->getIndex($i));
	}
    }

    return $partial;
}

sub simplify
{
    my ($this,$partial_index_set,$node_set,$tree,$pivot) = @_;
    my $i;
    my $j=0;
    my $index;
    my $index_partial;
    my @simplified;
    
    for ($i= 0; $i < scalar @{$this->getIndexes}; $i++)
    {
	$index = $this->getIndex($i);
	if($j < scalar @{$partial_index_set->getIndexes})
	{
	    $index_partial  = $partial_index_set->getIndex($j);
	    if($index == $index_partial)
	    {
		if(
		    (
		     (!defined $pivot)
		     ||
		     ($index != $pivot)
		    )
		    &&
		    (! $tree->getIndexSet->indexExists($index))
		    )
		{
		    $tree->getIndexSet->addIndex($index);
		}
		if($index_partial == $node_set->getRoot->searchHead->getIndex)
		{
		    push  @simplified, $index_partial;
		    
		}
		$j++;
	    }
	    
	    else
	    {
		push  @simplified, $index;
	    }
	}
	else
	{
	    push  @simplified, $index;
	}
	
    }
    @{$this->getIndexes} = @simplified;

}

sub simplifyWithSeveralPivots
{
    my ($this,$partial_index_set,$node_set,$tree,$pivots_h) = @_;
    my $i;
    my $j=0;
    my $index;
    my $index_partial;
    my @simplified;
    
    for ($i= 0; $i < scalar @{$this->getIndexes}; $i++)
    {
	$index = $this->getIndex($i);

	if($j < scalar @{$partial_index_set->getIndexes})
	{
	    $index_partial  = $partial_index_set->getIndex($j);

	    if($index == $index_partial)
	    {
		if(exists $pivots_h->{$index})
		{
		    push @simplified, $index_partial;
		}
		$j++;
	    }
	    
	    else
	    {
		push  @simplified, $index;
	    }
	}
	else
	{
	    push  @simplified, $index;
	}
	
    }
    @{$this->getIndexes} = @simplified;

}


sub searchPivot
{
    my ($this,$other_set) = @_;
    my $i;
    my $j;

    foreach $i (@{$this->getIndexes})	
    {
	foreach $j (@{$other_set->getIndexes})
	{
	    if ($i == $j)
	    {
		return $i;
	    }
	}
    }
    return;
}



sub print 
{
    my ($this,$fh) = @_;
    my $index;
    if(defined $fh)
    {
	print $fh (joinAll($this,'-'));	
    }
    else
    {
	print joinAll(($this,'-'));
    }
}

sub mergeWith
{
    my ($this,$index_set_to_add) = @_;
    my $index;
    push @{$this->getIndexes},@{$index_set_to_add->getIndexes};
    @{$this->getIndexes}= sort ({$a <=> $b} @{$this->getIndexes});
}


sub contains
{
    my ($this,$other_index) = @_;
   
    if(
	($this->getFirst <= $other_index->getFirst)
	&&
	($this->getLast >= $other_index->getLast)
	)
    {
	return 1;
    }
    return 0;
}

sub indexExists
{
    my ($this,$index) = @_;
    my %this_index = map ({ $_ => 1 } @{$this->getIndexes});
    if(exists $this_index{$index})
    {
	return 1;
    }
    return 0;
}

sub getIncludedContext
{
    my ($this,$included) = @_;
    my $left_context = $this->findPrevious($included->getFirst); 
    my $right_context = $this->findNext($included->getLast); 

    return ($left_context,$right_context);
}

sub findPrevious
{
    my ($this,$stop_index) = @_;
    my $previous = -1;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	if($index >= $stop_index)
	{
	    return $previous;
	}
	$previous = $index;
    }
    return -1;
}

sub findNext
{
    my ($this,$stop_index) = @_;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	if($index > $stop_index)
	{
	    return $index;
	}
    }
    return -1;
}

sub removeIndex
{
    my ($this,$index_to_remove) = @_;
    my @tmp;
    my $index;
    foreach $index (@{$this->getIndexes})
    {
	if($index != $index_to_remove)
	{
	    push @tmp, $index;
	}
    }
    @{$this->getIndexes} = @tmp;
}


sub defineAppendMode
{
    my ($this,$to_append,$pivot) = @_;
    my $mode;

    if(
	($this->getLast < $to_append->getFirst)
	||
	($this->getFirst > $to_append->getLast)
	)
    {    
	return "DISJUNCTION"; # external disjunction
    }

    if(
	($this->getLast == $to_append->getFirst)
	||
	($this->getFirst == $to_append->getLast)
	)
    {
	return "ADJUNCTION";
    }

    if($this->getFirst <= $to_append->getFirst)
    {
	if($this->getLast >= $to_append->getLast)
	{
	    if(defined $pivot)
	    {

		return "INCLUSION";
	    }
	    return "DISJUNCTION"; # internal disjunction
	}
	else
	{
	    if($this->getLast < $to_append->getLast)
	    {
		if (defined $pivot)
		{
		    if($pivot == $this->getLast)
			
		    {
			return "INCLUSION";
		    }
		    else
		    {
			return "REVERSED_INCLUSION";
		    }
		}
	    }
	}
    }
    if($this->getFirst >= $to_append->getFirst)
    {
	if($this->getLast <= $to_append->getLast)
	{
	    if(defined $pivot)
	    {
		return "REVERSED_INCLUSION";
	    }
	    return "DISJUNCTION"; # internal disjunction
	}
	else
	{
	    if($this->getLast > $to_append->getLast)
	    {
		if (defined $pivot)
		{
		    if ($pivot == $this->getFirst)
		    {
			return "INCLUSION";  
		    }
		    else
		    {
			return "REVERSED_INCLUSION";
		    }
		}
	    }
	}
    }
   
    return $mode;
}

sub crosses
{
    my ($this,$to_append) = @_;
    my $gaps_a;
    my %gaps;
    my $gap_h;
    my $index;
    my @fulled_gaps;
    if	
	(
	 (
	  ($this->getFirst < $to_append->getFirst)
	  &&
	  ($this->getLast > $to_append->getFirst)
	  &&
	  ($this->getLast < $to_append->getLast)
	 )
	 ||
	 (
	  ($this->getFirst > $to_append->getFirst)
	  &&
	  ($this->getFirst < $to_append->getLast)
	  &&
	  ($this->getLast > $to_append->getLast)
	 )
	)
    {
	return 1;
    }
    $gaps_a = $this->getGaps;
    if(scalar @$gaps_a > 1)
    {
	foreach $index (@{$to_append->getIndexes})
	{
	    foreach $gap_h (@$gaps_a)
	    {
		if(exists $gap_h->{$index})
		{
		    $gaps{$gap_h}++;
		}
	    }
	}
    }
    @fulled_gaps = keys %gaps;
    if(scalar @fulled_gaps > 1)
    {
	return 1;
    }
    return 0;
}

sub getGaps
{
    my ($this) = @_;
    my $index;
    my $previous;
    my $counter = 0;
    my @gaps;

    foreach $index (@{$this->getIndexes})
    {
	if(
	    (defined $previous)
	    &&
	    ($index != $previous+1)
	    )
	{
	    my %gap;
	    $counter = $previous+1;
	    while ($counter != $index)
	    {
		$gap{$counter++} = 0;
	    }
	    push @gaps, \%gap;
	}
	$previous = $index;
    }
    return \@gaps;
}


sub removeDoubles
{
    my ($this) = @_;
    my $index;
    my %uniq;
    my @tmp;

    foreach $index (@{$this->getIndexes})
    {
	if(!exists $uniq{$index})
	{
	    push @tmp, $index;
	}
	$uniq{$index}++;
    }
    @{$this->getIndexes} = @tmp;
}

1;

