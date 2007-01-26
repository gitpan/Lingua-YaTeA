package Lingua::YaTeA::ForbiddenStructureStartOrEnd;
use strict;
use Lingua::YaTeA::ForbiddenStructure;
use Lingua::YaTeA::LinguisticItem;
use Lingua::YaTeA::TriggerSet;
use UNIVERSAL qw(isa);


our @ISA = qw(Lingua::YaTeA::ForbiddenStructure);

sub new
{
    my ($class,$infos_a,$triggers) = @_;
    my ($form,$items_a) = $class->parse($infos_a->[0]);
    my $this = $class->SUPER::new($form);
    bless ($this,$class);
    $this->{POSITION} = $infos_a->[1];
    $this->{ITEMS} = $items_a;
    $triggers->addTrigger($this);
    return $this;
}

sub getFirstItem
{
    my ($this) = @_;
    if($this->isStart)
    {
	return $this->getItemSet->[0];
    }
    if($this->isEnd)
    {
	return $this->getItemSet->[$#{$this->getItemSet}];
    }
}


sub getItemSet
{
    my ($this) = @_;
    return $this->{ITEMS};
}

sub parse
{
    my ($class,$string) = @_;
    my @elements = split / /, $string;
    my $element;
    my $i_form;
    my $fs_form;
    my $type;
    my $rank = 0;
    my @items;

    foreach $element (@elements){
	$element =~ /^([^\\]+)\\(.+)$/;
	$i_form = $1;
	$type =$2;
	push @items, Lingua::YaTeA::LinguisticItem->new($type,$i_form);
	if($rank == 0){
	   
	}
	$fs_form .= $i_form . " ";
	$rank++;
    }
    $fs_form =~ s/ $//;
    return ($fs_form,\@items);
}



sub getItem
{
    my ($this,$index) = @_;
    return $this->getItemSet->[$index];    
}

sub isStart
{
    my ($this) = @_;
    if($this->getPosition eq "START")
    {
	return 1;
    }
    return 0;
}

sub isEnd
{
    my ($this) = @_;
    if($this->getPosition eq "END")
    {
	return 1;
    }
    return 0;
}

sub getPosition
{
    my ($this) = @_;
    return $this->{POSITION};
}





sub apply
{
    my ($this,$words_a) = @_;
    my $i;
    my $j;
   
    $i = 0;
    $j = 0;
    my $to_delete;
    
    if($this->isStart){
	while ($j < $this->getLength)
	{

	    if(isa($words_a->[$i],'Lingua::YaTeA::TestifiedTermMark'))
	    {
		return;
		#return $to_delete;
	    }
	    else
	    {
		if
		    (
		     (isa($words_a->[$i],'Lingua::YaTeA::ForbiddenStructureStartOrEnd'))
		     ||
		     (
		      (isa($words_a->[$i],'Lingua::YaTeA::WordFromCorpus'))
		      &&
		      ($this->getItem($j)->matchesWord($words_a->[$i]))
		     )
		    )
		{
		    $i++;
 		    $j++;
		    $to_delete++;
		}
		else
		{
		    return;
		}
	    }
	}
    }
    if($this->isEnd)
    {
	$i = $#$words_a;
	$j = $this->getLength -1;
	while ($j >= 0)
	{
	    
	    if(isa($words_a->[$i],'Lingua::YaTeA::TestifiedTermMark'))
	    {
		return;
	    }
	    else
	    {
		
		if
		    (
		     (isa($words_a->[$i],'Lingua::YaTeA::ForbiddenStructureStartOrEnd'))
		     ||
		    (
		     (isa($words_a->[$i],'Lingua::YaTeA::WordFromCorpus'))
		     &&
		     ($this->getItem($j)->matchesWord($words_a->[$i]))
		    )
		    )
		{
		    $i--;
		    $j--;
		    $to_delete++;
		}
		else
		{
		    return;
		}
	    }
	}
    }
    return $to_delete;
}

sub print
{
    my ($this) = @_;
    print $this->{FORM} . "\n";
    print $this->{POSITION} . "\n";
}

1;
