package Lingua::YaTeA::NodeSet;
use UNIVERSAL qw(isa);
use strict;

sub new
{  
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ROOT_NODE} = ();
    $this->{NODES} = [];
    return $this;
}



sub addNode
{
    my ($this,$node) = @_;
    push @{$this->{NODES}}, $node; 
    $this->updateRoot;
}

sub getNodes
{
    my ($this) = @_;
    return $this->{NODES};
}


sub setRoot
{
    my ($this) = @_;
    my $node;
    foreach $node (@{$this->getNodes})
    {
	if(isa($node,'Lingua::YaTeA::RootNode'))
	{
	    $this->{ROOT_NODE} =  $node;
	} 
    }
}


sub getRoot
{
    my ($this,$root) = @_;
    return $this->{ROOT_NODE}; 

}



sub getNode
{
    my ($this,$index) = @_;
    return $this->getNodes->[$index];
}

sub updateRoot
{
    my ($this) = @_;
    my %nodes_id;
    my $node;
    foreach $node (@{$this->getNodes})
    {
	$nodes_id{$node->getID}++;
    }

    if(scalar @{$this->getNodes} == 0)
    {
	undef $this->{ROOT_NODE};
    }
    else
    {
	if
	    (
	     (!defined $this->getRoot)
	     ||
	     (!exists $nodes_id{$this->getRoot->getID})
	     ||
	     (!isa($this->getRoot,'Lingua::YaTeA::RootNode'))
	    )
	{
	    
	    $this->setRoot;
	}
    }
}



sub copy
{
    my ($this) = @_;
    my $new_set = Lingua::YaTeA::NodeSet->new;
    my $node = $this->getRoot;

    $node->copyRecursively($new_set);
    $this->addFreeNodes($new_set);
    return $new_set;
}

sub addFreeNodes
{
    my ($this,$new_set) = @_;
    my $node;
   
    foreach $node (@{$this->getNodes})
    {
	
	if(
	    (isa($node,'Lingua::YaTeA::RootNode'))
	    &&
	    ($node ne $this->getRoot)
	    )
	    
	{
	    $node->copyRecursively($new_set);
	}
    }

}

sub fillNodeLeaves
{
    my ($this,$index_set) = @_;
    my $counter = 0;
  
    $this->getRoot->fillLeaves(\$counter,$index_set);
}



sub updateLeaves
{
    my ($this,$index_set) = @_;
    my $counter = 0;
    $this->getRoot->updateLeaves(\$counter,$index_set);
}

sub searchFreeNodes
{
  my ($this,$words_a) = @_;
  my $node;
  my @free_nodes;
 
 
  foreach $node (@{$this->getNodes})
  {
      if(
	  (isa($node,'Lingua::YaTeA::RootNode'))
	  )
      {
	  push @free_nodes, $node;	  
      }
  }
  return \@free_nodes;
}



sub removeNodes{
    my ($this,$root_node,$words_a) = @_;
    my @tmp;
    my $node;
    my @unplugged;

    while ($node = pop @{$this->getNodes})
    {
	if($node->getID == $root_node->getID)
	{
	    if(isa($node,'Lingua::YaTeA::InternalNode'))
	    {
		if(
		    (isa ($node->getFather->getLeftEdge,'Lingua::YaTeA::InternalNode' )
		     &&
		     ($node->getFather->getLeftEdge->getID == $node->getID)
		    )
		    )
		   
		{
		    $node->{FATHER}->{LEFT_EDGE} = $node->searchHead;
		}
		else
		{
		    if(
			(isa ($node->getFather->getRightEdge,'Lingua::YaTeA::InternalNode' )
			 &&
			 ($node->getFather->getRightEdge->getID == $node->getID)
			)
			)
			
		    {
			$node->{FATHER}->{RIGHT_EDGE} = $node->searchHead;
		    }
		}
	    }
	    if(isa($node->getLeftEdge,'Lingua::YaTeA::Node'))
	    {
		undef $node->getLeftEdge->{FATHER};
		bless($node->getLeftEdge,'Lingua::YaTeA::RootNode');
		push @unplugged,$node->getLeftEdge;
		
	    }
	    if(isa($node->getRightEdge,'Lingua::YaTeA::Node'))
	    {
		undef $node->getRightEdge->{FATHER};
		bless($node->getRightEdge,'Lingua::YaTeA::RootNode');
		push @unplugged,$node->getRightEdge;
	    }
	}
	else
	{
	    push @tmp,$node;
	}
    }
    
    
    @{$this->getNodes} = @tmp;
    $this->updateRoot;

    return \@unplugged;
}



sub hitchMore
{
    my ($this,$added_node_set,$added_index_set,$words_a) = @_;
    my $free_nodes_a = $this->searchFreeNodes($words_a);
    my $node;
    my $pivot;
    my $hook_node;
    my $hook_place;
    my $below;
    my %integrated;

    if(scalar @$free_nodes_a != 0)
    {
	foreach $node (@$free_nodes_a)
	{
	    
	    if(
		($node != $added_node_set->getNode(0)->searchRoot)
		&&
		(!exists $integrated{$node->getID})
		)
	    {
		$pivot = $node->searchHead->getIndex;
		if($added_index_set->getLast == $pivot)
		{
		    ($hook_node,$hook_place) = $node->getNodeOfLeaf($pivot,$added_index_set->getFirst,$words_a);
		}
		else
		{
		    if($added_index_set->getFirst == $pivot)
		    {
			($hook_node,$hook_place) = $node->getNodeOfLeaf($pivot,$added_index_set->getLast,$words_a);
		    }
		}
	
		if(isa($hook_node,'Lingua::YaTeA::Node'))
		{
		    if($hook_node->hitch($hook_place,$added_node_set->getRoot,$words_a))
		    {
			
			$integrated{$added_node_set->getRoot->getID}= 1;
		    }
		}
	    }
	}
    }
}


sub findHierarchy
{
    my ($this,$pivot,$added_index_set,$added_node_set) = @_;
    my $node;
    my $pivot_node;
    my $pivot_place;
    my $left_most;
    my $right_most;
    my $recorded;
  
    foreach $node (@{$this->getNodes})
    {
	if(isa($node,'Lingua::YaTeA::RootNode'))
	{
	    ($pivot_node,$pivot_place) = $node->searchLeaf($pivot);
	    
	    if(isa($pivot_node,'Lingua::YaTeA::Node'))
	    {
		$left_most = $node->searchLeftMostLeaf;
		$right_most = $node->searchRightMostLeaf;
		$recorded = $node;
		last;
	    }
	}
    }

    if(
	(defined $left_most)
	&& 
	(defined $right_most)
	)
    {
	if($right_most->getIndex == $added_index_set->getLast)
	{
	    if($left_most->getIndex > $added_index_set->getFirst)
	    {
		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
		return ($pivot_node,$pivot_place,$recorded);
	    }
	    if($left_most->getIndex < $added_index_set->getFirst)
	    {
		return ($pivot_node,$pivot_place,$added_node_set->getRoot);
	    }
	    die "not defined";
	}

	if($right_most->getIndex == $added_index_set->getFirst)
	{
	    ($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
	    return ($pivot_node,$pivot_place,$recorded);
	}

	if($left_most->getIndex == $added_index_set->getLast)
	{
	   
	    if($added_node_set->getRoot->searchHead->getIndex == $left_most->getIndex)
	    {
		return ($pivot_node,$pivot_place,$added_node_set->getRoot);
	    }
	    else
	    {
		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
		return ($pivot_node,$pivot_place,$recorded);
	    }
	}

	if($left_most->getIndex == $added_index_set->getFirst)
	{
	    if($right_most->getIndex > $added_index_set->getLast)
	    {
		return ($pivot_node,$pivot_place,$added_node_set->getRoot);
	    }
	    if($right_most->getIndex < $added_index_set->getLast)
	    {
		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
		return ($pivot_node,$pivot_place,$recorded);
	    }
	}
	if($left_most->getIndex > $added_index_set->getFirst)
	{
	    if($right_most->getIndex < $added_index_set->getLast)
	    {
		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
		return ($pivot_node,$pivot_place,$recorded);
	    }
	    else
	    {
		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
		return ($pivot_node,$pivot_place,$recorded);
	    }
	    die "not defined";
	}

	if($left_most->getIndex < $added_index_set->getFirst)
	{
	    if($right_most->getIndex > $added_index_set->getLast)
	    {
		return ($pivot_node,$pivot_place,$added_node_set->getRoot->searchLeftMostNode);  
	    }
	    if($recorded->searchHead->getIndex == $pivot)
 	    {
		
 		($pivot_node,$pivot_place) = $added_node_set->getRoot->searchLeaf($pivot);
 		return ($pivot_node,$pivot_place,$recorded);
 	    }
	    else
	    {
		return;
	    }
	}
	die "not defined";
    }
}


sub getNodeWithPivot
{
    my ($this,$pivot) = @_;
    my $node;
     
    foreach $node (@{$this->getNodes})
    {
	if (
	    (isa($node->getLeftEdge,'Lingua::YaTeA::TermLeaf'))
	    &&
	    ($node->getLeftEdge->getIndex == $pivot)
	    )
	    
	{
	    return ($node,"LEFT");
	}

	if (
	    (isa($node->getRightEdge,'Lingua::YaTeA::TermLeaf'))
	    &&
	    ($node->getRightEdge->getIndex == $pivot)
	    )
	    
	{
	    return ($node,"RIGHT");
	}
    }
    
    return;
}



sub addNodes
{
    my ($this,$node_set) = @_;
    my $node;
    foreach $node (@{$node_set->getNodes})
    {
	$this->addNode($node);
    }
}




sub print
{
    my ($this,$words_a,$fh) = @_;
    if(defined $fh)
    {
	print $fh "ROOT_NODE :" . $this->getRoot->getID . "\n";
	print $fh "NODES : \n"; 
	$this->getRoot->printRecursively($words_a,$fh);
    }
    else
    {
	print "ROOT_NODE :" . $this->getRoot->getID . "\n";
	print "NODES : \n"; 
	$this->getRoot->printRecursively($words_a);
    }
}


sub printAllNodes
{
    my ($this,$words_a) = @_;
    my $node;
    print "ROOT_NODE :" . $this->getRoot->getID . "\n";
    print "NODES : \n"; 

    foreach $node (@{$this->getNodes})
    {
	$node->printSimple($words_a);
    }
    print "\n";
}


sub printParenthesised
{
    my ($this,$words_a,$fh) = @_;
    my $analysis = "";
     if(defined $fh)
    {
	$this->getRoot->buildParenthesised(\$analysis,$words_a);
	print $fh $analysis . "\n";
    }
    else
    {
	$this->getRoot->buildParenthesised(\$analysis,$words_a);
	print $analysis . "\n";
    }
}

sub searchRootNodeForLeaf
{
    my ($this,$index) = @_;
    my ($node,$place) = $this->getNodeWithPivot($index);
    return $node->searchRoot;
}

sub fillIndexSet
{
    my ($this,$index_set) = @_;
    my $node;
    
    foreach $node (@{$this->getNodes})
    {
	if(isa($node,'Lingua::YaTeA::RootNode'))
	{
	    $node->fillIndexSet($index_set);
	}
    }
    $index_set->removeDoubles;
}

sub searchHeads
{
    my ($this,$words_a) = @_;
    my %heads;
    my $root;
    my $free_nodes_a = $this->searchFreeNodes($words_a);

    foreach $root (@$free_nodes_a)
    {
	$heads{$root->searchHead->getIndex}++;
    }
    return \%heads;
}

1;
