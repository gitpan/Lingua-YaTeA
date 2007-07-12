package Lingua::YaTeA::Node;
use strict;
use Data::Dumper;
use UNIVERSAL qw(isa);
use Lingua::YaTeA::TermLeaf;
use Lingua::YaTeA::MultiWordTermCandidate;
use Lingua::YaTeA::MonolexicalTermCandidate;

our $id = 0;

sub new
{
    my ($class,$level) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $id++;
    $this->{LEVEL} = $level;
    $this->{LEFT_EDGE} = ();
    $this->{LEFT_STATUS} = ();
    $this->{RIGHT_EDGE} = ();
    $this->{RIGHT_STATUS} = ();
    $this->{DET} = ();
    $this->{PREP}= ();
    $this->{LINKED_TO_ISLAND} = 0;
    return $this;
}

sub addEdge
{
    my ($this,$edge,$status) = @_;
    my %mapping =("M"=>"MODIFIER", "H"=>"HEAD","C1"=>"COORDONNE1", "C2"=>"COORDONNE2" );
    if (!defined $this->{LEFT_EDGE}){ # si le fils gauche est vide, on le remplit
	$this->{LEFT_EDGE} =  $edge;
	$this->{LEFT_STATUS} = $mapping{$status};
    }
    else{
	$this->{RIGHT_EDGE} = $edge; # sinon, on remplit le fils droit
	$this->{RIGHT_STATUS} = $mapping{$status};
    }
}




sub getEdgeStatus
{
    my ($this,$place) = @_;
    return $this->{$place.'_STATUS'};
}

sub getLeftEdgeStatus
{
    my ($this) = @_;
    return $this->{LEFT_STATUS};
}

sub getRightEdgeStatus
{
    my ($this) = @_;
    return $this->{RIGHT_STATUS};
}

sub getNodeStatus
{
    my ($this) = @_;
    my $father;
    if (isa($this,'Lingua::YaTeA::Edge'))
    {
	$father = $this->{FATHER};
	if ($father->{LEFT_EDGE} == $this)
	{
	    return $father->{LEFT_STATUS};
	}
	else
	{
	    return $father->{RIGHT_STATUS};
	}
    }
    else
    {
	return "ROOT";
    }
}

sub getNodePosition
{
    my ($this) = @_;
    my $father;
     if (isa($this,'Lingua::YaTeA::Edge'))
     {
	 $father = $this->{FATHER};
	 if ($father->{LEFT_EDGE} == $this)
	{
	    return "LEFT";
	}
	 else
	 {
	     return "RIGHT";
	 }
     }
}

sub getHead
{
    my ($this) = @_;
    if($this->{LEFT_STATUS} eq "HEAD")
    {
	return $this->{LEFT_EDGE};
    }
    return $this->{RIGHT_EDGE};
}



sub getModifier
{
    my ($this) = @_;
    if($this->{LEFT_STATUS} eq "MODIFIER")
    {
	return $this->{LEFT_EDGE};
    }
    return $this->{RIGHT_EDGE};
}

sub getLeftEdge
{
    my ($this) = @_;
    return $this->getEdge("LEFT");
}

sub getRightEdge
{
    my ($this) = @_;
    return $this->getEdge("RIGHT");
}

sub getEdge
{
    my ($this,$position) = @_;
    return $this->{$position."_EDGE"};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};

}

sub getLevel
{
    my ($this) = @_;
    return $this->{"LEVEL"};
}



sub getDeterminer
{
    my ($this) = @_;
    return $this->{DET};
}

sub getPreposition
{
    my ($this) = @_;
    return $this->{PREP};
}

sub linkToFather
{
    my ($this,$uncomplete_a,$status) = @_;
    my $father;
    if (scalar @$uncomplete_a != 0)
    {
	$father = $uncomplete_a->[$#$uncomplete_a];
	$this->{FATHER} = $father;
	$father->addEdge($this,$status);
    }
    
}

sub fillLeaves
{
    my ($this,$counter_r,$index_set, $deep) = @_;

    $deep++;
    if ($deep < 50) { # Temporary added by Thierry Hamon 02/03/2007
	if ($this->getLeftEdge eq "")
	{
	    $this->{LEFT_EDGE} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
	}
	else
	{
	    $this->getLeftEdge->fillLeaves($counter_r,$index_set, $deep);
	}
	
	if (defined $this->getPreposition)
	{
	    $this->{PREP} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
	}
	if (defined $this->getDeterminer)
	{
	    $this->{DET} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
	}
	if ($this->getRightEdge eq "")
	{
	    $this->{RIGHT_EDGE} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
	}
	else
	{
	    $this->getRightEdge->fillLeaves($counter_r,$index_set, $deep);
	}
    } else {
	warn "fillLeaves: Going out a deep recursive method call (more than 50 calls)\n";
    }
}






sub searchHead
{
    my ($this) = @_;
    my $head = $this->getHead;
    return $head->searchHead;
}


sub printSimple
{
    my ($this,$words_a) = @_;
    my $left_edge;
    my $right_edge;
    print "\t\t[" . ref($this) ."\n";
    print "\t\tid: " . $this->getID . "\n";
    print "\t\tlevel:" . $this->getLevel . "\n";

    $left_edge = $this->getLeftEdge;
    print "\t\tleft_edge: ";
    $left_edge->print($words_a);
    print "\t\tleft_status: " . $this->getLeftEdgeStatus . "\n";
    if (defined $this->{PREP})
    {
	print "\t\tprep: " ;
	$this->{PREP}->print($words_a);
	print "\n";
    }
    if (defined $this->{DET})
    {
	print "\t\tdet: ";
	$this->{DET}->print($words_a);
	print  "\n";
    }
    print "\t\tright_edge: ";
    $right_edge = $this->getRightEdge;
    $right_edge->print($words_a);
    print "\t\tright_status: " . $this->getRightEdgeStatus . "\n";
    print "\t\t]\n";
}

sub printRecursively
{
    my ($this,$words_a) = @_;
    my $left_edge;
    my $right_edge;
  
    print "\t\t[" .ref($this) ."\n";
    print "\t\tid: " . $this->getID . "\n";
    print "\t\tlevel:" . $this->getLevel . "\n";
    if(isa($this,'Lingua::YaTeA::InternalNode'))
    {
	$this->printFather;
    }
    $left_edge = $this->getLeftEdge;
    print "\t\tleft_edge: ";
    $left_edge->print($words_a);

    print "\t\tstatus: " . $this->getLeftEdgeStatus . "\n";
    if (defined $this->getPreposition)
    {
	print "\t\tprep: ";
	if(isa($this->getPreposition,'Lingua::YaTeA::TermLeaf'))
	{
	    $this->getPreposition->print($words_a); 
	}
	else
	{
	    print $this->getPreposition;
	}
	print  "\n";
    }
    if (defined $this->getDeterminer)
    {
	print "\t\tdet: ";
	if(isa($this->getPreposition,'Lingua::YaTeA::TermLeaf'))
	{
	    $this->getDeterminer->print($words_a);
	}
	else
	{
	    print $this->getDeterminer;
	}
	print  "\n";
    }
    print "\t\tright_edge: ";
    $right_edge = $this->getRightEdge;

    $right_edge->print($words_a);
    print "\t\tstatus: " . $this->getRightEdgeStatus . "\n";
    
    print "\t\t]\n";
    

    if (isa($left_edge,"Lingua::YaTeA::Node"))
    {
	$left_edge->printRecursively($words_a);
    }
    if (isa($right_edge,"Lingua::YaTeA::Node"))
    {
	$right_edge->printRecursively($words_a);
    }
}

sub searchRoot
{
    my ($this) = @_;
    if(isa($this,'Lingua::YaTeA::RootNode'))
    {
	return $this;
    }
    $this->getFather->searchRoot;
}

sub hitchMore
{
    my ($this,$free_nodes_a,$tree,$words_a) = @_;

    my $pivot;
    my $node;
    my $position;
    my $above;
    my $below;
    my $mode;
    my $place;
    my $sub_index_set = Lingua::YaTeA::IndexSet->new;
    $this->fillIndexSet($sub_index_set,0);
    my $added_index_set;
    foreach my $n (@$free_nodes_a)
    {
	if($n->getID != $this->getID)
	{
	    $pivot = $n->searchHead->getIndex;
	    $added_index_set = Lingua::YaTeA::IndexSet->new;
	    $n->fillIndexSet($added_index_set,0);
	    
	    ($node,$position) = $this->searchLeaf($pivot);
	    if(isa($node,'Lingua::YaTeA::Node'))
	    {
		
		($mode) = $sub_index_set->defineAppendMode($added_index_set,$pivot);
		if(defined $mode)
		{
		    if($mode =~ "INCLUSION")
		    {
			if($mode =~ /REVERSED/)
			{
			    ($above,$place) = $n->searchLeaf($pivot);
			    $below = $node;
			}
			else
			{
			    ($above,$place) = $node->searchLeaf($pivot);
			    $below = $n;
			}
		    }
		    else
		    {
			if($mode eq "ADJUNCTION")
			{
			    ($above,$place) = $node->searchLeaf($pivot);
			    $below = $n;
			}
		    }
		    
		    $above->hitch($place,$below,$words_a);
		}
		else
		{
		    die;
		}
	
	    }
	    else
	    {
		$pivot = $this->searchHead->getIndex;
		($node,$position) = $n->searchLeaf($pivot);
		if(isa($node,'Lingua::YaTeA::Node'))
		{
		    ($mode) = $added_index_set->defineAppendMode($sub_index_set,$pivot);

		    if(defined $mode)
		    {
			if($mode =~ "INCLUSION")
			{
			    if($mode =~ /REVERSED/)
			    {
			    ($above,$place) = $this->searchLeaf($pivot);
			    $below = $node;
			    }
			    else
			    {
				($above,$place) = $n->searchLeaf($pivot);
				$below = $this;
			    }
			}
			else
			{
			    if($mode eq "ADJUNCTION")
			    {
				
				($above,$place) = $n->searchLeaf($pivot);
				$below = $this;
			    }
			}
			$above->hitch($place,$below,$words_a);
		    }
		}
	    }
	    
	}
   }
}


sub hitch
{
    my ($this,$place,$to_add,$words_a) = @_;

    if($this->checkCompatibility($place,$to_add))
    {
	if(isa($to_add,'Lingua::YaTeA::RootNode'))
	{
	    bless ($to_add,'Lingua::YaTeA::InternalNode');
	}
	if(isa ($this->{$place."_EDGE"},'Lingua::YaTeA::InternalNode'))
	{
	    $to_add->plugSubNodeSet($this->{$place."_EDGE"});
	}
	$to_add->setFather($this);
	$this->{$place."_EDGE"} = $to_add;
	$to_add->updateLevel($this->getLevel + 1);
	
	return 1;
	
    }
    else
    {
	#incompatible nodes
	return 0;
    }
}

sub freeFromFather
{
    my ($this) = @_;
    undef $this->{FATHER};
    bless ($this,'Lingua::YaTeA::RootNode');
}


sub plugSubNodeSet
{
    my ($this,$to_plug) = @_;
    my $head_position = $this->getHeadPosition;
    my $head_node;

    if(isa($this->{$head_position . "_EDGE"},'Lingua::YaTeA::TermLeaf'))
    {
	$this->{$head_position . "_EDGE"} = $to_plug;
	$to_plug->setFather($this);
    }
    else
    {
	($head_node,$head_position) = $this->{$head_position . "_EDGE"}->searchLeaf($to_plug->searchHead->getIndex);
	$head_node->{$head_position . "_EDGE"} = $to_plug;
	$to_plug->setFather($head_node);
    }
}

sub checkCompatibility
{
    my ($this,$place,$to_add) = @_;

    if($this->getID != $to_add->getID)
    {
	if($to_add->searchHead->getIndex == $this->getEdge($place)->searchHead->getIndex)
	{
	    if($this->checkNonCrossing($to_add))
	    {
		return 1;
	    }
	    return 0;
	}
	return 0;
    }
    return 0;
}





sub checkNonCrossing
{
    my ($this,$to_add) = @_;

    my $previous = -1;
    my $gap;
    my $above_index_set = Lingua::YaTeA::IndexSet->new;
    $this->fillIndexSet($above_index_set,0);
    my $above_gaps_a = $above_index_set->getGaps;
    my $to_add_index_set;
    my $index;
    my $pivot;
    my @both;
    
    my $i;
    my %filled_gaps;
    my @gaps;

    if(scalar @$above_gaps_a > 1)
    {
	$to_add_index_set = Lingua::YaTeA::IndexSet->new;
	$to_add->fillIndexSet($to_add_index_set,0);
	foreach $index (@{$to_add_index_set->getIndexes})
	{
	    foreach $gap (@$above_gaps_a)
	    {
		if(exists $gap->{$index})
		{
		    $filled_gaps{$gap} = $gap;
		}
	    }
	}
	@gaps = values %filled_gaps;
	if(scalar @gaps > 1)
	{
	    if(scalar @gaps == 2)
	    {
		$pivot = $above_index_set->searchPivot($to_add_index_set);
		if(defined $pivot)
		{
		    push @both, keys %{$gaps[0]};
		    push @both, keys %{$gaps[1]};
		    @both = sort (@both);
		    $previous = -1;
		    for ($i=0; $i < scalar @both; $i++)
		    {
			$index = $both[$i];

			if(
			    ($index != $previous+1)
			    &&
			    ($pivot == $previous+1) 
			    &&
			    (
			     (!defined $both[$i+1])
			     ||
			     ($pivot == $both[$i+1])
			    )
			    )
			{
			    return 1;
			}
			$previous = $index;
		    }
		    return 0;
		}
	    }
	    return 0;
	}
    }
    return 1;
}



sub copyRecursively
{
    my ($this,$new_set,$father) = @_;
    my $new;
    my $field;
    my @fields = ('LEVEL','LEFT_STATUS','RIGHT_STATUS','DET','PREP','LINKED_TO_ISLAND');
    if (isa($this,'Lingua::YaTeA::RootNode'))
    {
        $new = Lingua::YaTeA::RootNode->new;
	$new_set->{ROOT_NODE} = $new;
    }
    else
    {
	$new = Lingua::YaTeA::InternalNode->new;
	$new->{FATHER} = $father;
    }
    foreach $field (@fields)
    {
	$new->{$field} = $this->{$field};
    }
    $new_set->addNode($new);
    if(isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$new->{LEFT_EDGE} = $this->getLeftEdge;
    }
    else{
	$new->{LEFT_EDGE} = $this->getLeftEdge->copyRecursively($new_set,$new);
    }
    if(isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$new->{RIGHT_EDGE} = $this->getRightEdge;
    }
    else
    {
	$new->{RIGHT_EDGE} = $this->getRightEdge->copyRecursively($new_set,$new);
    }
    return $new;
 
}


sub searchLeftMostLeaf
{
    my ($this) = @_;
    my $left_most;
    my $left;
   
    $left = $this->getLeftEdge;
    if(isa($left,'Lingua::YaTeA::Node'))
    {
	$left = $left->searchLeftMostLeaf;
    }
    return $left;
}



sub searchRightMostLeaf
{
    my ($this) = @_;
    my $right;
    
    $right = $this->getRightEdge;

    if(isa($right,'Lingua::YaTeA::Node'))
    {
	$right = $right->searchRightMostLeaf;
    }
    return $right;
}





sub getPreviousWord
{
    my ($this,$place) = @_;
    if($place eq "LEFT")
    {
	if(isa($this,'Lingua::YaTeA::RootNode'))
	{
	    return;
	}
	else
	{
	    return $this->getFather->getPreviousWord($this->getNodePosition);
	}
    }
    else
    {
	if(defined $this->getDeterminer)
	{
	    return $this->getDeterminer;
	}
	if(defined $this->getPreposition)
	{
	    return $this->getPreposition;
	}
	if(isa($this->getLeftEdge,'Lingua::YaTeA::Node'))
	{
	    return $this->getLeftEdge->searchRightMostLeaf;
	}
	else
	{
	    return $this->getLeftEdge;
	}
    }
    
}




sub getNextWord
{
    my ($this,$place) = @_;
    if($place eq "RIGHT")
    {
	if(isa($this,'Lingua::YaTeA::RootNode'))
	{
	    return;
	}
	else
	{
	    return $this->getFather->getNextWord($this->getNodePosition);
	}
    }
    else
    {
	if(defined $this->getPreposition)
	{
	    return $this->getPreposition;
	}
	if(defined $this->getDeterminer)
	{
	    return $this->getDeterminer;
	}
	if(isa($this->getRightEdge,'Lingua::YaTeA::Node'))
	{
	    return $this->getRightEdge->searchLeftMostLeaf;
	}
	else
	{
	    return $this->getRightEdge;
	}
    }    
}




sub findWordContext
{
    my ($this,$word_index,$place) = @_;
  
    my $next;
    my $previous;

    $previous = $this->getPreviousWord($place);
    $next = $this->getNextWord($place);

    if((!defined $previous)&&(!defined $next))
    {
	die "Index not found\n";
    }
    return ($previous,$next);
}


sub buildIF
{
    my ($this,$if_r,$words_a) = @_;
    
    if(isa($this->getLeftEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getLeftEdge->buildIF($if_r,$words_a);
    }
    else
    {
	$$if_r .= $this->getLeftEdge->getIF($words_a) . " ";
    }
    
    if(defined $this->getPreposition)
    {
	$$if_r .= $this->getPreposition->getIF($words_a) . " ";	
    }


    if(defined $this->getDeterminer)
    {
	$$if_r .= $this->getDeterminer->getIF($words_a) . " ";	
    }

    if(isa($this->getRightEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getRightEdge->buildIF($if_r,$words_a);
    }
    else
    {
	$$if_r .= $this->getRightEdge->getIF($words_a) . " ";
    }
    
}

sub buildParenthesised
{
    my ($this,$analysis_r,$words_a) = @_;
    my %abr = ("MODIFIER" => "M", "HEAD" => "H", "COORDONNE1" => "C1", "COORDONNE2" => "C2");
    $$analysis_r .= "( ";
    if(isa($this->getLeftEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getLeftEdge->buildParenthesised($analysis_r,$words_a);
    }
    else
    {
	$$analysis_r .= $this->getLeftEdge->getIF($words_a) . "<=" .$abr{$this->getLeftEdgeStatus} . "=" . $this->getLeftEdge->getPOS($words_a) . "> ";
    }
    
    if(defined $this->getPreposition)
    {
	$$analysis_r .= $this->getPreposition->getIF($words_a) . " ";	
    }


    if(defined $this->getDeterminer)
    {
	$$analysis_r .= $this->getDeterminer->getIF($words_a) . " ";	
    }

    if(isa($this->getRightEdge,'Lingua::YaTeA::InternalNode'))
    {
	$this->getRightEdge->buildParenthesised($analysis_r,$words_a);
    }
    else
    {
	$$analysis_r .= $this->getRightEdge->getIF($words_a) . "<=" .$abr{$this->getRightEdgeStatus} . "=" . $this->getRightEdge->getPOS($words_a) . "> ";
    }
    if(isa($this,'Lingua::YaTeA::InternalNode'))
    {
	$$analysis_r .= ")<=" . $abr{$this->getNodeStatus} . "=" .$this->searchHead->getPOS($words_a) . "> ";
    }
    else
    {
	$$analysis_r .= ")";
    }
}




sub searchLeaf
{
    my ($this,$index) = @_;
    my $node;
    my $position;
    if(isa($this->getLeftEdge,'Lingua::YaTeA::Node'))
    {
	($node,$position) = $this->getLeftEdge->searchLeaf($index);
    }
    else
    {
	if($this->getLeftEdge->getIndex == $index)
	{
	    return ($this,"LEFT");
	}
    }
    if(!defined $node)
    {
	if(isa($this->getRightEdge,'Lingua::YaTeA::Node'))
	{
	    ($node,$position) = $this->getRightEdge->searchLeaf($index);
	}
	else
	{
	    if($this->getRightEdge->getIndex == $index)
	    {
		return ($this,"RIGHT");
	    }
	}
    }
    return ($node,$position); 
}

sub updateLeaves
{
    my ($this,$counter_r,$index_set) = @_;
    
    if (isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$this->{LEFT_EDGE} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
    }
    else
    {
	$this->getLeftEdge->updateLeaves($counter_r,$index_set);
    }
    
    if (defined $this->getPreposition)
    {
	$this->{PREP} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
    }
    if (defined $this->getDeterminer)
    {
	$this->{DET} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
    }
    if (isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$this->{RIGHT_EDGE} = Lingua::YaTeA::TermLeaf->new($index_set->getIndex($$counter_r++));
    }
    else
    {
	$this->getRightEdge->updateLeaves($counter_r,$index_set);
    }
}


sub buildTermList
{
    my ($this,$term_candidates_a,$words_a,$phrase_occurrences_a,$phrase_island_set,$offset,$maximal) = @_;
   
    my $left;
    my $right;
 
    my $term_candidate = Lingua::YaTeA::MultiWordTermCandidate->new;

    my %abr = ("MODIFIER" => "M", "HEAD" => "H", "COORDONNE1" => "C1", "COORDONNE2" => "C2");
    
    $term_candidate->editKey("( ");
    
    $term_candidate->setOccurrences($phrase_occurrences_a,$$offset,$maximal);

    # left edge is a term leaf
    if(isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$term_candidate->editKey($this->getLeftEdge->getIF($words_a) . "<=" . $abr{$this->getLeftEdgeStatus} . "=" . $this->getLeftEdge->getPOS($words_a) . "=" . $this->getLeftEdge->getLF($words_a). "> ");

	my $mono =  Lingua::YaTeA::MonolexicalTermCandidate->new;
	$mono->editKey("( " . $this->getLeftEdge->getIF($words_a)."<=S=".$this->getLeftEdge->getPOS($words_a) . "=" . $this->getLeftEdge->getLF($words_a). "> )");
	$mono->addWord($this->getLeftEdge,$words_a);

	$mono->setOccurrences($phrase_occurrences_a,$$offset,$this->getLeftEdge->getLength($words_a),0);

	push @$term_candidates_a, $mono;

	$term_candidate->addWord($this->getLeftEdge,$words_a);
	$term_candidate->getIndexSet->addIndex($this->getLeftEdge->getIndex);
	
	$left = $mono;
	$$offset += $this->getLeftEdge->getLength($words_a) +1;

    }
    # left edge is a node
    else
    {
	$left = $this->getLeftEdge->buildTermList($term_candidates_a,$words_a,$phrase_occurrences_a,$phrase_island_set,$offset,0);
	$term_candidate->editKey($left->getKey . "<=" . $abr{$this->getLeftEdge->getNodeStatus} . "=" .$this->getLeftEdge->searchHead->getPOS($words_a) . "> ");
	push @{$term_candidate->getWords},@{$left->getWords};
	$term_candidate->addIndexSet($left->getIndexSet);

    }
    if (defined $this->getPreposition)
    {
	$term_candidate->editKey($this->getPreposition->getIF($words_a) . "<=".$this->getPreposition->getPOS($words_a)  . "=" . $this->getPreposition->getLF($words_a) . "> ");
	$$offset += $this->getPreposition->getLength($words_a) +1;
	$term_candidate->{PREPOSITION} = $this->getPreposition->getWord($words_a);
	$term_candidate->addWord($this->getPreposition,$words_a);
	$term_candidate->getIndexSet->addIndex($this->getPreposition->getIndex);
    }
    if (defined $this->getDeterminer)
    {
	$term_candidate->editKey($this->getDeterminer->getIF($words_a) . "<=" . $this->getDeterminer->getPOS($words_a) . "=" . $this->getDeterminer->getLF($words_a) . "> ");
	$$offset += $this->getDeterminer->getLength($words_a) +1;
	$term_candidate->{DETERMINER} = $this->getDeterminer->getWord($words_a);
	$term_candidate->addWord($this->getDeterminer,$words_a);
	$term_candidate->getIndexSet->addIndex($this->getDeterminer->getIndex);
    }
    if(isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
    {
	$term_candidate->editKey($this->getRightEdge->getIF($words_a) . "<=" . $abr{$this->getRightEdgeStatus} . "=" . $this->getRightEdge->getPOS($words_a)  . "=" . $this->getRightEdge->getLF($words_a). "> ");

	my $mono =  Lingua::YaTeA::MonolexicalTermCandidate->new;
	$mono->editKey("( " . $this->getRightEdge->getIF($words_a). "<=S=".$this->getRightEdge->getPOS($words_a) . "=" . $this->getRightEdge->getLF($words_a). "> )");
	$mono->addWord($this->getRightEdge,$words_a);
	$mono->setOccurrences($phrase_occurrences_a,$$offset,$this->getRightEdge->getLength($words_a),0);
	push @$term_candidates_a, $mono;

	$term_candidate->addWord($this->getRightEdge,$words_a);
	$term_candidate->getIndexSet->addIndex($this->getRightEdge->getIndex);

	$right = $mono;
	$$offset += $this->getRightEdge->getLength($words_a) +1;
    }
    # left edge is a node
    else
    {
	$right = $this->getRightEdge->buildTermList($term_candidates_a,$words_a,$phrase_occurrences_a,$phrase_island_set,$offset,0);
	$term_candidate->editKey($right->getKey . "<=" . $abr{$this->getRightEdge->getNodeStatus} . "=" .$this->getRightEdge->searchHead->getPOS($words_a) . "> ");
	push @{$term_candidate->getWords},@{$right->getWords};
	$term_candidate->addIndexSet($right->getIndexSet);

    }

    $term_candidate->editKey(")");
  
   #  if(isa($this,'Lingua::YaTeA::InternalNode'))
#     {
# 	$term_candidate->editKey("<=" . $abr{$this->getNodeStatus} . "=" .$this->searchHead->getPOS($words_a) . "> ");
#     }
   
    if($this->getHeadPosition eq "LEFT")
    {
	$term_candidate->{ROOT_HEAD} = $left;
	$term_candidate->{ROOT_MODIFIER} = $right;
	$term_candidate->{MODIFIER_POSITION} = "AFTER";

    }
    else
    {
	$term_candidate->{ROOT_HEAD} = $right;
	$term_candidate->{ROOT_MODIFIER} = $left;
	$term_candidate->{MODIFIER_POSITION} = "BEFORE";
    }
    
    $term_candidate->completeOccurrences($$offset);

        
    $term_candidate->setIslands($phrase_island_set,$left,$right);

    push @$term_candidates_a, $term_candidate;

    return $term_candidate;
}




sub getHeadPosition
{
    my ($this) = @_;
    if($this->{LEFT_STATUS} eq "HEAD")
    {
	return "LEFT";
    }
    return "RIGHT";
}

sub getModifierPosition
{
    my ($this) = @_;
    if($this->{LEFT_STATUS} eq "MODIFIER")
    {
	return "LEFT";
    }
    return "RIGHT";
}


sub searchLeftMostNode
{
 my ($this) = @_;
    
    my $left;
   
    $left = $this->getLeftEdge;
    if(isa($left,'Lingua::YaTeA::Node'))
    {
	$left = $left->searchLeftMostNode;
    }
    return $this;
}

sub searchRightMostNode
{
 my ($this) = @_;
    
    my $right;
   
    $right = $this->getRightEdge;
    if(isa($right,'Lingua::YaTeA::Node'))
    {
	$right = $right->searchRightMostNode;
    }
    return $this;
}

sub fillIndexSet
{
    my ($this,$index_set, $deep) = @_;
    $deep++;
    if ($deep < 50) { # Temporary added by thierry Hamon 02/03/2007
	if(isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
	{
	    $index_set->addIndex($this->getLeftEdge->getIndex);	
	}
	else
	{
	    $this->getLeftEdge->fillIndexSet($index_set,$deep);
	}
	if (defined $this->getPreposition)
	{
	    $index_set->addIndex($this->getPreposition->getIndex);
	}
	if (defined $this->getDeterminer)
	{
	    $index_set->addIndex($this->getDeterminer->getIndex);
	}
	if(isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
	{
	    $index_set->addIndex($this->getRightEdge->getIndex);	
	}
	else
	{
# 	warn "vvvvv\n";
# 	warn $this->getRightEdge->getRightEdge . "\n";
# 	warn "$this\n";
# 	warn "-----\n";
	    $this->getRightEdge->fillIndexSet($index_set,$deep);
	}
    } else {
	warn "fillIndexSet: Going out a deep recursive method call (more than 50 calls)\n";
    }
}

sub plugInternalNode
{
    my ($this,$internal_node,$previous_index,$next_index,$parsing_pattern_set,$words_a,$parsing_direction,$tag_set) = @_;
    my $record;
    my $intermediate_node_set;
    my $new_previous_index;
    my $new_next_index;
    my ($node,$place) = $this->searchRoot->getNodeOfLeaf($previous_index,$internal_node->searchHead->getIndex,$words_a);

    if($place =~ /LEFT|RIGHT/)
    {
	if(!defined $node)
	{
	    die;
	}
	else{
	    
	    if($node->getEdgeStatus($place) ne "HEAD")
	    {
		$new_previous_index = $node->searchHead;
		if($new_previous_index < $internal_node->searchHead->getIndex)
		{
		    $previous_index = $new_previous_index;
		}
	    }
	}
    }
    ($node,$place) = $this->searchRoot->getNodeOfLeaf($next_index,$internal_node->searchHead->getIndex,$words_a);
    if($place =~ /LEFT|RIGHT/)
    {
	if($node->getEdgeStatus($place) ne "HEAD")
	{
	    $new_next_index = $node->searchHead;
	    if($new_next_index < $internal_node->searchHead->getIndex)
	    {
		$next_index = $new_next_index;
	    }
	}
    }

    my $left_index_set = Lingua::YaTeA::IndexSet->new;
    $left_index_set->addIndex($previous_index);
    $left_index_set->addIndex($internal_node->searchHead->getIndex);
    my $right_index_set = Lingua::YaTeA::IndexSet->new;
    $right_index_set->addIndex($internal_node->searchHead->getIndex);
    $right_index_set->addIndex($next_index);
   
    my $attached = 0;

    my $pos = $words_a->[$previous_index]->getPOS . " " .$words_a->[$internal_node->searchHead->getIndex]->getPOS  ;
    
    if ($record = $parsing_pattern_set->existRecord($left_index_set->buildPOSSequence($words_a,$tag_set)))
    {
	
	$intermediate_node_set = $this->getParseFromPattern($left_index_set,$record,$parsing_direction,$words_a);

	$intermediate_node_set->getRoot->hitch('RIGHT',$internal_node,$words_a);
	($node,$place) = $this->getNodeOfLeaf($previous_index,$internal_node->searchRightMostLeaf->getIndex,$words_a);
	if(defined $node)
	{
	    if(
		# prevent syntactic break
		($place ne "PREP")  
		&&
		($place ne "DET")
		)
	    {
		if($node->hitch($place,$intermediate_node_set->getRoot,$words_a))
		{
		    $attached = 1;
		}
		else
		{
		    $internal_node->freeFromFather;
		}
	    }
	}
    }
    if($attached == 0)
    {
	$pos = $words_a->[$internal_node->searchHead->getIndex]->getPOS  . " " . $words_a->[$next_index]->getPOS ;
	
	if ($record = $parsing_pattern_set->existRecord($right_index_set->buildPOSSequence($words_a,$tag_set)))
	{
	    $intermediate_node_set = $this->getParseFromPattern($right_index_set,$record,$parsing_direction,$words_a);
	    $intermediate_node_set->getRoot->hitch('LEFT',$internal_node,$words_a);
	    ($node,$place) = $this->getNodeOfLeaf($next_index,$internal_node->searchLeftMostLeaf->getIndex,$words_a);
	    if(defined $node)
	    {
		if($node->hitch($place,$intermediate_node_set->getRoot,$words_a))
		{
		    $attached = 1;
		}
		else
		{
		    $internal_node->freeFromFather;
		}
	    }
	}
    }
   

    return ($attached,$intermediate_node_set);
}

sub getNodeOfLeaf
{
    my ($this,$index,$to_insert,$words_a) = @_;
    my $node;
    my $position;
    my $hook_node;

    if (isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
    {
	if ($this->getLeftEdge->getIndex == $index)
	{
	    $hook_node = $this;

	    while($hook_node->searchRightMostLeaf->getIndex < $to_insert)
	    {
		if(isa($hook_node,'Lingua::YaTeA::RootNode'))
		{
		    return;
		}
		else
		{
		    $hook_node = $hook_node->getFather;
		}
	    }
	    return ($hook_node,"LEFT");
	}
    }
    else
    {
	($node,$position) = $this->getLeftEdge->getNodeOfLeaf($index,$to_insert,$words_a);
    }
    
    if (defined $this->getPreposition)
    {
	if($this->getPreposition->getIndex == $index)
	{
	    return ($this,"PREP");
	}
    }
    
    if (defined $this->getDeterminer)
    {
	if($this->getDeterminer->getIndex == $index)
	{
	    return ($this,"DET");
	}
    }
    
    if 	(! isa($node,'Lingua::YaTeA::Node'))
    {
	if(isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
	{
	    if($this->getRightEdge->getIndex == $index)
	    {
		$hook_node = $this;

		while($hook_node->searchLeftMostLeaf->getIndex > $to_insert)
		{
		    if(isa($hook_node,'Lingua::YaTeA::RootNode'))
		    {
			return;
		    }
		    else
		    {
			$hook_node = $hook_node->getFather;
		    }
		}
		return ($hook_node,"RIGHT");
	    }
	}
	else
	{
	    ($node,$position) = $this->getRightEdge->getNodeOfLeaf($index,$to_insert,$words_a);
	}
    }
    
    return ($node,$position);
}

sub getParseFromPattern
{
    my ($this,$index_set,$pattern_record,$parsing_direction,$words_a) = @_;
    my $pattern;
    my $node_set;
    $pattern = $this->chooseBestPattern($pattern_record->{PARSING_PATTERNS},$parsing_direction);
    $node_set = $pattern->getNodeSet->copy;
    $node_set->fillNodeLeaves($index_set);
    
    return $node_set;
}



sub chooseBestPattern
{
    my ($this,$patterns_a,$parsing_direction) = @_;
    
    my @tmp = sort {$this->sortPatternsByPriority($a,$b,$parsing_direction)} @$patterns_a;
  
    my @sorted = @tmp;

    return $sorted[0];
}



sub isDiscontinuous
{
    my ($this,$previous_r) = @_;
    my $next_node;
    my $infos_a;

    if(isa($this->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
    {
	if(
	    ($$previous_r != -1)
	    &&
	    ($this->getLeftEdge->getIndex != $$previous_r +1)
	    )
	{
	    $infos_a->[0] = -1;
	    $infos_a->[1] = $$previous_r;
	    $infos_a->[2] = $this->getLeftEdge->getIndex;
	    return $infos_a;
	}
	else
	{
	  $$previous_r = $this->getLeftEdge->getIndex; 
	}
    }
    else
    {
	$infos_a = $this->getLeftEdge->isDiscontinuous($previous_r);
	if($infos_a->[0] == -1)
	{
	    $infos_a->[0] = $this;
	}
	if(isa($infos_a->[0],'Lingua::YaTeA::Node'))
	{
	    return $infos_a;
	}
    }

    if (defined $this->getPreposition)
    {
       if(
	    ($$previous_r != -1)
	    &&
	    ($this->getPreposition->getIndex != $$previous_r +1)
	    )
	{
	    $infos_a->[0] = $this;
	    $infos_a->[1] = $$previous_r;
	    $infos_a->[2] = $this->getPreposition->getIndex;
	    return $infos_a;
	}
       else
       {
	   $$previous_r = $this->getPreposition->getIndex;
      }
    }

    if (defined $this->getDeterminer)
    {
	if(
	    ($$previous_r != -1)
	    &&
	    ($this->getDeterminer->getIndex != $$previous_r +1)
	    )
	{
	    $infos_a->[0] = $this;
	    $infos_a->[1] = $$previous_r;
	    $infos_a->[2] = $this->getDeterminer->getIndex;
	    return $infos_a;
	}
	else
	{
	    $$previous_r = $this->getDeterminer->getIndex;
	}
    }

    if(isa($this->getRightEdge,'Lingua::YaTeA::TermLeaf'))
    {
	if(
	    ($$previous_r != -1)
	    &&
	    ($this->getRightEdge->getIndex != $$previous_r +1)
	    )
	{
	    $infos_a->[0] = $this;
	    $infos_a->[1] = $$previous_r;
	    $infos_a->[2] = $this->getRightEdge->getIndex;
	    return $infos_a;
	}
	else
	{
	   
	  $$previous_r = $this->getRightEdge->getIndex; 
	  
	}
    }
    else
    {
	$infos_a = $this->getRightEdge->isDiscontinuous($previous_r);

	if($infos_a->[0] == -1)
	{
	    $infos_a->[0] = $this;
	}
	if(isa($infos_a->[0],'Lingua::YaTeA::Node'))
	{
	    return $infos_a;
	}
    }
    $infos_a->[0] = 0;
    return $infos_a;
}


sub adjustPreviousAndNext
{
    my ($this,$previous,$next,$tree) = @_;
    my $new_prev;
    my $new_next;
    my $node;
    my $place;

    if($this->getLeftEdge->searchHead->getIndex != $previous)
    {

	($node,$place) = $this->searchLeaf($previous);
	if(defined $node)
	{
	    while 
		(
		 (isa($node,'Lingua::YaTeA::InternalNode'))
		 &&
		 (!defined $node->getPreposition)
		 &&
		 ($node->getFather->getID != $this->getID)
		)
	    {
		$node = $node->getFather;
	    }
	    
	    $previous = $node->searchHead->getIndex;
	}
    }
    else
    {
	$new_prev = $previous;
    }
    if($this->getRightEdge->searchHead->getIndex != $next)
    {
	($node,$place) = $this->searchLeaf($next);
	if(defined $node)
	{
	    while 
		(
		 (isa($node,'Lingua::YaTeA::InternalNode'))
		 &&
		 (!defined $node->getPreposition)
		 &&
		 ($node->getFather->getID != $this->getID)
		)
	    {
		$node = $node->getFather;
	    }
	    $next = $node->searchHead->getIndex;
	}
    }
    else
    {
	$new_next = $next;
    }
    return ($new_prev,$new_next);
}


sub completeGap
{
    my ($this,$previous,$next,$tree,$parsing_pattern_set,$parsing_direction,$tag_set,$words_a) = @_;
    my $index = $previous +1;
    my $gap_index_set = Lingua::YaTeA::IndexSet->new;
    my $sub_pos;
    my $pattern;
    my $position;
    my $node_set;
    my $additional_node_set;
    my $partial_index_set;
    my $success = 0;
    
    while ($index < $next)
    {
	$gap_index_set->addIndex($index++);
    }

    while($gap_index_set->getSize > 0)
    {
	if($gap_index_set->getSize > 1) # multi-word gap
	{
	    $sub_pos = $gap_index_set->buildPOSSequence($words_a,$tag_set);

	    ($pattern,$position) = $this->getPartialPattern($gap_index_set,$tag_set,$parsing_direction,$parsing_pattern_set,$words_a);
	    if(isa($pattern,'Lingua::YaTeA::ParsingPattern'))
	    {
		$partial_index_set = $gap_index_set->getPartial($pattern->getLength,$position);
		$node_set = $pattern->getNodeSet->copy;
		$node_set->fillNodeLeaves($partial_index_set);
		($success,$additional_node_set) = $this->plugInternalNode($node_set->getRoot,$previous,$next,$parsing_pattern_set,$words_a,$parsing_direction,$tag_set);
		if($success == 1)
		{
		    $tree->addNodes($node_set);
		    $tree->addNodes($additional_node_set);
		    $tree->getSimplifiedIndexSet->simplify($partial_index_set,$additional_node_set,$tree,-1);
		    $gap_index_set->simplify($partial_index_set,$additional_node_set,$tree,-1);
		    $tree->updateRoot;
		}
		
	    }
	    else
	    {
		$success = 0;
	    }
	    if($success == 0)
	    {
		$success = $this->insertProgressively($previous,$next,$parsing_direction,$gap_index_set,$tree,$tag_set,$parsing_pattern_set,$words_a);
		if($success == 0)
		{
		    return 0;
		}
	    }
	    
	}
	else # one word gap
	{
	    $success = $this->insertOneWord($gap_index_set->getFirst,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a);
	    if($success == 1)
	    {
		$gap_index_set->removeIndex($gap_index_set->getFirst);  
	    }
	    return $success;
	}
    }
    
}

sub insertProgressively
{
    my ($this,$previous,$next,$parsing_direction,$gap_index_set,$tree,$tag_set,$parsing_pattern_set,$words_a) = @_;
    my $success;

    if($parsing_direction eq "LEFT")
    {
	$success = $this->insertOneWord($gap_index_set->getFirst,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a);
	if($success == 0)
	{
	    $success = $this->insertOneWord($gap_index_set->getLast,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a);  
	    if($success == 1)
	    {
		$gap_index_set->removeIndex($gap_index_set->getLast);  
	    }
	}
	else
	{
	    $gap_index_set->removeIndex($gap_index_set->getFirst);
	}
    }
    
    if($parsing_direction eq "RIGHT")
    {
	$success = $this->insertOneWord($gap_index_set->getLast,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a);
	if($success == 0)
	{
	    $success = $this->insertOneWord($gap_index_set->getFirst,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a); 
	     if($success == 1)
	    {
		$gap_index_set->removeIndex($gap_index_set->getFirst);  
	    }
	}
	else
	{
	    $gap_index_set->removeIndex($gap_index_set->getLast);  
	}
    }

    return $success;
    
}

sub insertOneWord
{
    my ($this,$index,$previous,$next,$parsing_direction,$tree,$tag_set,$parsing_pattern_set,$words_a) = @_;
    my $pos;
    my $record;
    my $node_set;
    my $index_set;
    my $above;
    my $hook_node;
    my $place;
    my $attached = 0;
    my $node;
    my $new_previous;
    my $new_next;


    if($tag_set->existTag('DETERMINERS',$words_a->[$index]->getPOS))
    {
	while($this->searchLeftMostLeaf->getIndex > $index)
	{
	    if(isa($this,'Lingua::YaTeA::InternalNode'))
	    {
		$this = $this->getFather
	    }
	    else
	    {
		return 0;
	    }
	}
	$this->addDeterminer($index);
	$tree->getSimplifiedIndexSet->removeIndex($index);
	$tree->getIndexSet->addIndex($index);
	return 1;
    }
    else
    {
	if(! $tag_set->existTag('PREPOSITIONS',$words_a->[$index]->getIF))
	{

	    ($node,$place) = $this->searchRoot->getNodeOfLeaf($previous,$index,$words_a);
	    if ((defined $place) && ($place =~ /EDGE/))
	    {
		if(!defined $node)
		{
		    die;
		}
		else{
		    
		    if($node->getEdgeStatus($place) ne "HEAD")
		    {
			$new_previous = $node->searchHead;
			if($new_previous < $index)
			{
			    $previous = $new_previous;
			}
		    }
		}
	    }
	    ($node,$place) = $this->searchRoot->getNodeOfLeaf($next,$index,$words_a);

	    if ((defined $place) && ($place =~ /EDGE/))
	    {
		if(!defined $node)
		{
		    die;
		}
		else{
		    
		    if($node->getEdgeStatus($place) ne "HEAD")
		    {
			$new_next = $node->searchHead;
			if($new_next < $index)
			{
			    $next = $new_next;
			}
		    }
		}
	    }
	    if($parsing_direction eq "LEFT") # left-first search
	    {
		$index_set = Lingua::YaTeA::IndexSet->new;
		$index_set->addIndex($previous);
		$index_set->addIndex($index);
		$pos = $index_set->buildPOSSequence($words_a,$tag_set);

		if ($record = $parsing_pattern_set->existRecord($pos))
		{
		    
		    $node_set = $this->getParseFromPattern($index_set,$record,$parsing_direction,$words_a);
		    ($hook_node,$place) = $this->getNodeOfLeaf($previous,$index,$words_a);
		    if($hook_node->hitch($place,$node_set->getRoot,$words_a))
		    {
			$tree->addNodes($node_set);
			$tree->getSimplifiedIndexSet->removeIndex($index);
			$tree->getIndexSet->addIndex($index);
			$attached = 1;
		    }
		}
		if($attached == 0)
		{
		    $index_set = Lingua::YaTeA::IndexSet->new;
		    
		    $index_set->addIndex($index);
		    $index_set->addIndex($next);
		    $pos = $index_set->buildPOSSequence($words_a,$tag_set);

		    if ($record = $parsing_pattern_set->existRecord($pos))
		    {
			
			$node_set = $this->getParseFromPattern($index_set,$record,$parsing_direction,$words_a);
			($hook_node,$place) = $this->getNodeOfLeaf($next,$index,$words_a);
			if($hook_node->hitch($place,$node_set->getRoot,$words_a))
			{
			    $tree->addNodes($node_set);
			    $tree->getSimplifiedIndexSet->removeIndex($index);
			    $tree->getIndexSet->addIndex($index);
			    $attached = 1;
			}
		    }
		}
		
	    }
	    if( # right-first search
		($parsing_direction eq "RIGHT")
		||
		($attached == 0)
		)
	    {
		$index_set = Lingua::YaTeA::IndexSet->new;
		
		$index_set->addIndex($index);
		$index_set->addIndex($next);
		$pos = $index_set->buildPOSSequence($words_a,$tag_set);

		if ($record = $parsing_pattern_set->existRecord($pos))
		{
		    
		    $node_set = $this->getParseFromPattern($index_set,$record,$parsing_direction,$words_a);

		    ($hook_node,$place) = $this->getNodeOfLeaf($next,$index,$words_a);
		    if(isa($hook_node,'Lingua::YaTeA::Node'))
		    {
			if($hook_node->hitch($place,$node_set->getRoot,$words_a))
			{
			    $tree->addNodes($node_set);
			    $tree->getSimplifiedIndexSet->removeIndex($index);
			    $tree->getIndexSet->addIndex($index);
			    $attached = 1;
			}
		    }
		    else
		    {
			if($node_set->getRoot->hitch("LEFT",$this,$words_a))
			{
			    $tree->addNodes($node_set);
			    $tree->getSimplifiedIndexSet->removeIndex($index);
			    $tree->getIndexSet->addIndex($index);
			    $attached = 1;
			}
			
		    }
		}
		if($attached == 0)
		{
		    $index_set = Lingua::YaTeA::IndexSet->new;
		    $index_set->addIndex($previous);
		    $index_set->addIndex($index);
		    $pos = $index_set->buildPOSSequence($words_a,$tag_set);

		    if ($record = $parsing_pattern_set->existRecord($pos))
		    {
		    
			$node_set = $this->getParseFromPattern($index_set,$record,$parsing_direction,$words_a);

			($hook_node,$place) = $this->getNodeOfLeaf($previous,$index,$words_a);
			if(isa($hook_node,'Lingua::YaTeA::Node'))
			{
			    if($hook_node->hitch($place,$node_set->getRoot,$words_a))
			    {
				$tree->addNodes($node_set);
				$tree->getSimplifiedIndexSet->removeIndex($index);
				$tree->getIndexSet->addIndex($index);
				$attached = 1;
			    }
			}
			else
			{
			    if($node_set->getRoot->hitch("RIGHT",$this,$words_a))
			    {
				$tree->addNodes($node_set);
				$tree->getSimplifiedIndexSet->removeIndex($index);
				$tree->getIndexSet->addIndex($index);
				$attached = 1;
			    }
			    
			}
		    }
		}
	    }
	}
    }
    return $attached;
}

sub getPartialPattern
{
   my ($this,$simplified_index_set,$tag_set,$parsing_direction,$parsing_pattern_set,$words_a) = @_;
   my $pattern;
   my $position;
   my $POS  = $simplified_index_set->buildPOSSequence($words_a,$tag_set);
   if($parsing_direction eq "LEFT")
   {
       ($pattern,$position) = $this->getPatternsLeftFirst($POS,$parsing_pattern_set,$parsing_direction);
   }
   else{
       ($pattern,$position) = $this->getPatternsRightFirst($POS,$parsing_pattern_set,$parsing_direction);
   }
   return ($pattern,$position);
}



sub getPatternsLeftFirst
{
    my ($this,$POS,$parsing_pattern_set,$parsing_direction) = @_;
    my $pattern;
    my $position = "LEFT";
    if (
	($pattern = $this->getPatternOnTheLeft($POS,$parsing_pattern_set,$parsing_direction))
	&&
	($pattern == 0)
	)
    {
	$pattern = $this->getPatternOnTheRight($POS,$parsing_pattern_set,$parsing_direction);
	$position = "RIGHT";
    }
    return ($pattern,$position);
}

sub getPatternsRightFirst
{
    my ($this,$POS,$parsing_pattern_set,$parsing_direction) = @_;
    my $pattern;
    my $position = "RIGHT";
    if (
	($pattern = $this->getPatternOnTheRight($POS,$parsing_pattern_set,$parsing_direction))
	&&
	($pattern == 0)
	)
    {
	$pattern = $this->getPatternOnTheLeft($POS,$parsing_pattern_set,$parsing_direction);
	$position = "LEFT";
    }
    
    return ($pattern,$position);
}

sub getPatternOnTheLeft
{
    my ($this,$POS,$parsing_pattern_set,$parsing_direction) = @_;
    my @selection;
    my $key;
    my $record;
    my $pattern;
    my $qm_key;

    while (($key,$record) = each %{$parsing_pattern_set->getRecordSet})
    {
	$qm_key = quotemeta($key);
	if ($POS =~ /^$qm_key/)
	{
	    foreach $pattern (@{$record->getPatterns})
	    {
		push @selection, $pattern;
	    }
	}
    }
    $pattern = $this->chooseBestPattern(\@selection,$parsing_direction);
    return $pattern;
}

sub getPatternOnTheRight
{
    my ($this,$POS,$parsing_pattern_set,$parsing_direction) = @_;
    my @selection;
    my $key;
    my $record;
    my $pattern;
    my $qm_key;

    while (($key,$record) = each %{$parsing_pattern_set->getRecordSet})
    {
	$qm_key = quotemeta($key);
	if ($POS =~ /$qm_key$/)
	{
	    foreach $pattern (@{$record->getPatterns})
	    {
		push @selection, $pattern;
	    }
	}
    }
    $pattern = $this->chooseBestPattern(\@selection,$parsing_direction);
    return $pattern;
}


# sub chooseBestPattern
# {
#     my ($this,$patterns_a,$parsing_direction) = @_;
    
#     my @tmp = sort {$this->sortPatternsByPriority($a,$b,$parsing_direction)} @$patterns_a;
#     my @sorted = @tmp;
    
#     return $sorted[0];
# }

sub sortPatternsByPriority
{
    my ($this,$first,$second,$parsing_direction) = @_;

    if($first->getDirection eq $parsing_direction)
    {
	if($second->getDirection eq $parsing_direction)
	{
	    if($first->getNumContentWords > $second->getNumContentWords)
	    {
		return -1;
	    }
	    else
	    {
		if($first->getNumContentWords < $second->getNumContentWords)
		{
		    return 1;
		}
		else
		{
		    return ($second->getPriority <=> $first->getPriority);
		}
	    }
	}
	else
	{
	    return -1;
	}
    }
    else
    {
	if($second->getDirection eq $parsing_direction)
	{
	    return 1;
	}
	else
	{
	    if($first->getNumContentWords > $second->getNumContentWords)
	    {
		return -1;
	    }
	    else
	    {
		if($first->getNumContentWords < $second->getNumContentWords)
		{
		    return 1;
		}
		else
		{
		    return ($second->getPriority <=> $first->getPriority);
		}
	    }
	}
    }
}

sub addDeterminer
{
    my ($this,$index) = @_;
    my $new_leaf = Lingua::YaTeA::TermLeaf->new($index);
    $this->{DET} = $new_leaf;
}

sub getHookNode
{
    my ($this,$insertion_type,$place,$below_index_set) = @_;
    my $hook = $this;
    my $intermediate;

    if($insertion_type eq "RIGHT")
    {
	while ($hook->getLeftEdge->searchRightMostLeaf->getIndex > $below_index_set->getFirst)
	{
	    $intermediate = $hook;
	    if(isa($hook,'Lingua::YaTeA::InternalNode'))
	    {
	        $hook = $hook->getFather;
	    }
	    else
	    {
		undef $hook;
		last;
	    }
	}
	if(defined $intermediate)
	{
	    if($intermediate->searchLeftMostLeaf->getIndex < $below_index_set->getFirst)
	    {
		undef $hook; 
	    }
	}
    }

    if($insertion_type eq "LEFT")
    {
	while ($hook->getRightEdge->searchLeftMostLeaf->getIndex < $below_index_set->getFirst)
	{
	    $intermediate = $hook;
	    if(isa($hook,'Lingua::YaTeA::InternalNode'))
	    {
	        $hook = $hook->getFather;
	    }
	    else
	    {
		undef $hook;
		last;
	    }
	}
	if(defined $intermediate)
	{
	    if($intermediate->searchRightMostLeaf->getIndex > $below_index_set->getLast)
	    {
		undef $hook; 
	    }
	}
    }
    
    return ($hook,$intermediate);
}

sub linkToIsland
{
    my ($this) = @_;
    $this->{"LINKED_TO_ISLAND"} = 1;
    if(isa($this->getLeftEdge,'Lingua::YaTeA::Node'))
    {
	$this->getLeftEdge->linkToIsland;
    }
    if(isa($this->getRightEdge,'Lingua::YaTeA::Node'))
    {
	$this->getRightEdge->linkToIsland;
    }
    
}

1;

__END__

=head1 NAME

Lingua::YaTeA::Node - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::Node;
  Lingua::YaTeA::Node->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 addEdge()


=head2 getEdgeStatus()


=head2 getLeftEdgeStatus()


=head2 getRightEdgeStatus()


=head2 getNodeStatus()


=head2 getNodePosition()


=head2 getHead()


=head2 getModifier()


=head2 getLeftEdge()


=head2 getRightEdge()


=head2 getEdge()


=head2 getID()


=head2 getLevel()


=head2 getDeterminer()


=head2 getPreposition()


=head2 linkToFather()


=head2 fillLeaves()


=head2 searchHead()


=head2 printSimple()


=head2 printRecursively()


=head2 searchRoot()


=head2 hitchMore()


=head2 hitch()


=head2 freeFromFather()


=head2 plugSubNodeSet()


=head2 checkCompatibility()


=head2 checkNonCrossing()


=head2 copyRecursively()


=head2 searchLeftMostLeaf()


=head2 searchRightMostLeaf()


=head2 getPreviousWord()


=head2 getNextWord()


=head2 findWordContext()


=head2 buildIF()


=head2 buildParenthesised()


=head2 searchLeaf()


=head2 updateLeaves()


=head2 buildTermList()


=head2 getHeadPosition()


=head2 getModifierPosition()


=head2 searchLeftMostNode()


=head2 searchRightMostNode()


=head2 fillIndexSet()


=head2 plugInternalNode()


=head2 getNodeOfLeaf()


=head2 getParseFromPattern()


=head2 chooseBestPattern()


=head2 isDiscontinuous()


=head2 adjustPreviousAndNext()


=head2 completeGap()


=head2 insertProgressively()


=head2 insertOneWord()


=head2 getPartialPattern()


=head2 getPatternsLeftFirst()


=head2 getPatternsRightFirst()


=head2 getPatternOnTheLeft()


=head2 getPatternOnTheRight()


=head2 sortPatternsByPriority()


=head2 addDeterminer()


=head2 getHookNode()


=head2 linkToIsland()



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
