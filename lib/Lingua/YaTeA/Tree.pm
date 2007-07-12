package Lingua::YaTeA::Tree;
use strict;
use Lingua::YaTeA::IndexSet;
use UNIVERSAL qw(isa);

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{NODE_SET} = ();
    $this->{HEAD} = ();
    $this->{RELIABILITY} = ();
    $this->{INDEX_SET} = Lingua::YaTeA::IndexSet->new();
    $this->{SIMPLIFIED_INDEX_SET} = Lingua::YaTeA::IndexSet->new();
    return $this;
}


sub setHead
{
    my ($this) = @_;
    my $root = $this->getNodeSet->getRoot;
    $this->{HEAD} = $root->searchHead;
}



sub setReliability
{
    my ($this,$reliability) = @_;
    $this->{RELIABILITY} = $reliability;
}



sub fillNodeLeaves
{
    my ($this) = @_;
    $this->getNodeSet->fillNodeLeaves($this->getIndexSet);
}

sub getIndexSet
{
    my ($this) = @_;
    return $this->{INDEX_SET};
}

sub getNodeSet
{
    my ($this) = @_;
    return $this->{NODE_SET};
}


sub setSimplifiedIndexSet
{
    my ($this,$original) = @_;
    $this->{SIMPLIFIED_INDEX_SET} = $original->copy;
}

sub copy
{
    my ($this) = @_;
    my $new = Lingua::YaTeA::Tree->new;
    if(defined $this->getNodeSet)
    {
	$new->{NODE_SET} = $this->getNodeSet->copy;
    	$new->{HEAD} = $new->setHead;
    }
    $new->{INDEX_SET} = $this->getIndexSet->copy;
    $new->{SIMPLIFIED_INDEX_SET} = $this->getSimplifiedIndexSet->copy;
    return $new;
}


sub getSimplifiedIndexSet
{
    my ($this) = @_;
    return $this->{SIMPLIFIED_INDEX_SET};
}


sub getRoot
{
    my ($this) = @_;
    return $this->getNodeSet->getRoot;
}

sub updateRoot
{
    my ($this) = @_;
    $this->getNodeSet->updateRoot;
}





sub setNodeSet
{
    my ($this,$node_set) = @_;
    $this->{NODE_SET} = $node_set;
}


sub addNodes
{
    my ($this,$node_set) = @_;
    $this->getNodeSet->addNodes($node_set);
   
}



sub print
{
    my ($this,$words_a) = @_;
    print "index set ";
    $this->getIndexSet->print;
    print "\n";
    if(defined $this->getSimplifiedIndexSet)
    {
	print "simplified index set ";
	$this->getSimplifiedIndexSet->print;
	print "\n";
    }
    print "node set : ";
    if(defined $this->getNodeSet)
    {
	$this->getNodeSet->printAllNodes($words_a);
    }
}


sub printParenthesised
{
    my ($this,$words_a,$fh) = @_;
   # print "(" . $this . ")";
    $this->getNodeSet->printParenthesised($words_a,$fh);
}


sub getHead
{
    my ($this) = @_;
    return $this->{HEAD};
}

sub getReliability
{
    my ($this) = @_;
    return $this->{RELIABILITY};
}

sub setIndexSet
{
    my ($this,$original) = @_;
    $this->{INDEX_SET} = $original->copy;
}

sub check
{
    my ($this,$phrase) = @_;
    my $if;
    $this->getRoot->buildIF(\$if,$phrase->getWords);
    $if =~ s/ $//;
   
    if($if eq $phrase->getIF)
    {
	return 1;
    }
    else
    {
#	print "Arbre mal forme :" .$if . "\n";
# 	$this->getNodeSet->printAllNodes($phrase->getWords);
 	warn "\nArbre mal forme :" .$if . " (pour " . $phrase->getIF.")\n";
	return 0;
    }
}

sub completeDiscontinuousNodes
{
    my ($this,$parsing_pattern_set,$parsing_direction,$tag_set,$words_a) = @_;
    my $previous = -1;
    my $discontinuous_infos_a;
    my $free_nodes_a = $this->getNodeSet->searchFreeNodes($words_a);
    my $discontinuous_nodes_a = $this->getDiscontinuousNodes($free_nodes_a,$words_a);

    foreach $discontinuous_infos_a (@$discontinuous_nodes_a)
    {
	if($discontinuous_infos_a->[0]->completeGap($discontinuous_infos_a->[1], $discontinuous_infos_a->[2],$this,$parsing_pattern_set,$parsing_direction,$tag_set,$words_a))
	{
	    if(
		($discontinuous_infos_a = $discontinuous_infos_a->[0]->isDiscontinuous(\$previous))
		&&
		(isa ($discontinuous_infos_a->[0],'Lingua::YaTeA::Node'))
		)
	    {
		push @$discontinuous_nodes_a,$discontinuous_infos_a;
	    }
	} 
    }
}

sub getDiscontinuousNodes
{
    my ($this,$free_nodes_a,$words_a) = @_;
    my $free_node;
    my $previous = -1;
    my $discontinuous_infos_a;
    my @discontinuous;

    foreach $free_node (@$free_nodes_a)
    {
	$previous = -1;
	$discontinuous_infos_a = $free_node->isDiscontinuous(\$previous);
	if(isa($discontinuous_infos_a->[0],'Lingua::YaTeA::Node')){
	    push @discontinuous,$discontinuous_infos_a;
	}
    }
    return \@discontinuous;
   

}

sub removeDiscontinuousNodes
{
    my ($this,$words_a) = @_;
    my $discontinuous;
    my $modified = 0;
    my @unplugged;

    my $discontinuous_nodes_a = $this->getDiscontinuousNodes($this->getNodeSet->getNodes,$words_a);
    foreach $discontinuous (@$discontinuous_nodes_a)
    {
	push @unplugged, @{$this->getNodeSet->removeNodes($discontinuous->[0],$words_a)};
	$modified = 1;
    }

    $this->updateRoot;
    return ($modified,\@unplugged);
}




sub integrateIslandNodeSets
{
    my ($this,$node_sets,$index_set,$words_a,$tagset) = @_;
    my $to_add;
    my $save;
    my $tree;
    my $i;
    my $integrated = 0;
    my @new_trees;


    if($index_set->appearsIn($this->getSimplifiedIndexSet))
    {
	
	if(scalar @$node_sets > 1)
	{
	    $save = $this->copy;
	}
	
	
	for ($i=0; $i < scalar @$node_sets; $i++)
	{
	    if($i == 0)
	    {
		$tree = $this;
	    }
	    else
	    {
		$tree = $save->copy;
	    }
	    
	    $to_add = $node_sets->[$i]->copy;

	    $to_add->getRoot->linkToIsland;
	    if($tree->append($to_add,$index_set,\@new_trees,$words_a,$tagset))
	    {
		$integrated = 1;
	    }
	    else
	    {
		push @new_trees, $tree;
	    }
	}
	
    }
    else
    { # islands are incompatible
	push @new_trees, $this;
    }
    return ($integrated,\@new_trees);
}

sub append
{
    my ($this,$added_node_set,$added_index_set,$concurrent_trees_a,$words_a,$tagset) = @_;
    my $addition = 0;
    my $pivot;
    my $mode;
    my $root;
    my $index_set;
    
    if(!defined $this->getNodeSet)
    {
	$this->setNodeSet($added_node_set);
	$pivot = -1;
	$this->getSimplifiedIndexSet->simplify($added_index_set,$added_node_set,$this,$pivot);
	push @$concurrent_trees_a, $this;
	return 1;
    }
    
    if($added_index_set->testSyntacticBreakAndRepetition($words_a,$tagset))
    {
	
	$pivot = $added_node_set->getRoot->searchHead->getIndex;
	if(! $this->getIndexSet->indexExists($pivot))
	{
	    $pivot = $this->getIndexSet->searchPivot($added_index_set);
	}
	if(defined $pivot)
	{
	    $index_set = Lingua::YaTeA::IndexSet->new;
	    $root = $this->getNodeSet->searchRootNodeForLeaf($pivot);
	    if (defined $root) { # Added by Thierry 02/03/2007
# 		warn "==> $root\n";
		$root->fillIndexSet($index_set);
	    }
	}
	else
	{
	    $index_set = $this->getIndexSet;
	}
# 	warn "===>$index_set\n";
	$mode = $index_set->defineAppendMode($added_index_set,$pivot);
# 	warn "<<<<\n";
	if(defined $mode)
	{

	    if($mode eq "DISJUNCTION")
	    {
		$addition = $this->appendDisjuncted($added_node_set);	
	    }
	    else
	    {
		if($mode =~ "INCLUSION")
		{
		    $addition = $this->appendIncluded($mode,$root,$index_set,$added_node_set,$added_index_set,$pivot,$words_a);	
		}
		else
		{
		    if($mode =~ "ADJUNCTION")
		    {
			$addition = $this->appendAdjuncts($root,$index_set,$added_node_set,$added_index_set,$pivot,$concurrent_trees_a,$words_a);	

		    }
		}
	    }
	    if($addition == 1)
	    {
		
		$this->getSimplifiedIndexSet->simplify($added_index_set,$added_node_set,$this,$pivot);	
		push @$concurrent_trees_a, $this;
	    }
	}
	
    }

    if($addition == 1)
    {
	
	return 1;
    }
    return 0;
}



sub appendAdjuncts
{
    my ($this,$root,$index_set,$added_node_set,$added_index_set,$pivot,$concurrent_trees_a,$words_a) = @_;
    my $type;
    my $place;
    my $above;
    my $root2;
    my $tree_save = $this->copy;
    my $added_save = $added_node_set->copy;
    my $sub_index_set_save = $index_set->copy;
    my $added_index_set_save = $added_index_set->copy;

    if($added_node_set->getRoot->searchHead->getIndex == $pivot )
    {
	my $tree2 = $tree_save->copy;
	my $added2 = $added_save->copy;
	$root2 = $tree2->getNodeSet->searchRootNodeForLeaf($pivot);
	if (defined $root) { # Added by Thierry 02/03/2007
	    ($above,$place) = $root2->searchLeaf($pivot); 
	    if($above->{"LINKED_TO_ISLAND"} == 0)
	    {
		if($above->hitch($place,$added2->getRoot,$words_a))
		{
		    $tree2->getSimplifiedIndexSet->simplify($added_index_set,$added2,$tree2,$pivot);	
		    $tree2->addNodes($added2);
		    $root2->searchRoot->hitchMore($tree2->getNodeSet->searchFreeNodes($words_a),$tree2,$words_a);
		    $tree2->updateRoot;
		    push @$concurrent_trees_a,$tree2;
		    
		}
	    }
	}
	
    }
    if($root->searchHead->getIndex == $pivot)
    {
	($above,$place) = $added_node_set->getRoot->searchLeaf($pivot);
	if (defined $above) { # Added by Thierry Hamon 31/01/2007 - to check
	if($above->hitch($place,$root,$words_a))
	{
	    $this->addNodes($added_node_set);
	    $above->searchRoot->hitchMore($this->getNodeSet->searchFreeNodes($words_a),$this,$words_a);
	    $this->updateRoot;
	    return 1;

	}
    }
    }

    return 0;
}

sub appendIncluded
{
    my ($this,$mode,$root,$index_set,$added_node_set,$added_index_set,$pivot,$words_a) = @_;
    my $above;
    my $above_index_set;
    my $below;
    my $below_index_set;
    my $type;
    my $place;
    my $intermediate_node;
    if($mode =~ /REVERSED/)
    {
	$above = $added_node_set->getRoot;
	$above_index_set = $added_index_set;
	$below = $root;
	$below_index_set = $index_set;
    }
    else
    {
	$above = $root;
	$above_index_set = $index_set;
	$below = $added_node_set->getRoot;
	$below_index_set = $added_index_set;
    }
    $type = $below_index_set->appendPosition($pivot);

    ($above,$place) = $above->searchLeaf($pivot);

    ($above,$intermediate_node) = $above->getHookNode($type,$place,$below_index_set);
    if(defined $above)
    {
	if($above->hitch($place,$below,$words_a))
	{
	    $this->addNodes($added_node_set);
	    $above->searchRoot->hitchMore($this->getNodeSet->searchFreeNodes($words_a),$this,$words_a);
	    $this->updateRoot;
	    return 1;
	}
    }
    return 0;
}

sub appendDisjuncted
{
    my ($this,$added_node_set) = @_;
    $this->addNodes($added_node_set);
    return 1;
}

sub getAppendContexts
{
    my ($this,$mode,$pivot,$root,$index_set,$added_node_set,$added_index_set,$words_a)  = @_;
    my @contexts;
    my $place;
    my $above;
    my $below;
    my $tree_save = $this->copy;
    my $added_save = $added_node_set->copy;
    my $sub_index_set_save = $index_set->copy;
    my $added_index_set_save = $added_index_set->copy;

    if($mode =~ /INSERTION/)
    {
	if($mode =~ /REVERSED/)
	{
	    ($above,$place) =  $added_node_set->getRoot->searchLeaf($pivot);
	    $below = $root;	    
	}
	else
	{
	    ($above,$place) = $root->searchLeaf($pivot);
	    $below = $added_node_set->getRoot;
	}
	my $context = {"ABOVE"=>$above, "PLACE"=>$place, "BELOW" => $below, "TREE"=>$this, "INDEX_SET"=>$index_set, "ADDED_NODE_SET"=>$added_node_set, "ADDED_INDEX_SET"=>$added_index_set};
	push @contexts, $context;
    }
    else
    {

	if($mode !~ /MIDDLE/)
	{
	    ($above,$place) = $added_node_set->getRoot->searchLeaf($pivot);
	    $below = $root;
	    my $context = {"ABOVE"=>$above, "PLACE"=>$place, "BELOW" => $below, "TREE"=>$this, "INDEX_SET"=>$index_set, "ADDED_NODE_SET"=>$added_node_set, "ADDED_INDEX_SET"=>$added_index_set};
	    push @contexts, $context;
	    if($root->{"LINKED_TO_ISLAND"} == 0) # conserver cette condion ?
	    {
		my $tree2 = $tree_save->copy;

		my $added2 = $added_save->copy;
		($above,$place) =   $tree2->getNodeSet->getNodeWithPivot($pivot);
		$below = $added2->searchRootNodeForLeaf($pivot);
		if (defined $below) { # Added by Thierry 02/03/2007
		    my $context2 = {"ABOVE"=>$above, "PLACE"=>$place, "BELOW" => $below, "TREE"=>$tree2, "INDEX_SET"=>$sub_index_set_save, "ADDED_NODE_SET"=>$added2, "ADDED_INDEX_SET"=>$added_index_set_save};
		    push @contexts, $context2;
		}
	    }
	}
	
	else
	{
	    ($above,$place) =  $added_node_set->getRoot->searchLeaf($pivot);
	    $below = $this->getNodeSet->searchRootNodeForLeaf($pivot);
	    if (defined $below) { # Added by Thierry 02/03/2007
		my $context = {"ABOVE"=>$above, "PLACE"=>$place, "BELOW" => $below, "TREE"=>$this, "INDEX_SET"=>$index_set, "ADDED_NODE_SET"=>$added_node_set, "ADDED_INDEX_SET"=>$added_index_set};
		push @contexts, $context;
	    }
	}
    }
    return \@contexts;
}

sub updateIndexes
{
    my ($this,$phrase_index_set,$words_a) = @_;
    my $heads_h;
    my $index_set = Lingua::YaTeA::IndexSet->new;
    my $simplified_index_set = $phrase_index_set->copy;
    $this->getNodeSet->fillIndexSet($index_set);
    

    $heads_h = $this->getNodeSet->searchHeads($words_a);
    $simplified_index_set->simplifyWithSeveralPivots($index_set,$this->getNodeSet,$this,$heads_h);

    @{$this->getIndexSet->getIndexes} = @{$index_set->getIndexes};
    @{$this->getSimplifiedIndexSet->getIndexes} = @{$simplified_index_set->getIndexes};
}

1;

__END__

=head1 NAME

Lingua::YaTeA::Tree - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::Tree;
  Lingua::YaTeA::Tree->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 setHead()


=head2 setReliability()


=head2 fillNodeLeaves()


=head2 getIndexSet()


=head2 getNodeSet()


=head2 setSimplifiedIndexSet()


=head2 copy()


=head2 getSimplifiedIndexSet()


=head2 getRoot()


=head2 updateRoot()


=head2 setNodeSet()


=head2 addNodes()


=head2 print()


=head2 printParenthesised()


=head2 getHead()


=head2 getReliability()


=head2 setIndexSet()


=head2 check()


=head2 completeDiscontinuousNodes()


=head2 getDiscontinuousNodes()


=head2 removeDiscontinuousNodes()


=head2 integrateIslandNodeSets()


=head2 append()


=head2 appendAdjuncts()


=head2 appendIncluded()


=head2 appendDisjuncted()


=head2 getAppendContexts()


=head2 updateIndexes()


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
