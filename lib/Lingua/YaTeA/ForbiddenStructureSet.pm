package Lingua::YaTeA::ForbiddenStructureSet;
use strict;
use Lingua::YaTeA::ForbiddenStructureAny;
use Lingua::YaTeA::ForbiddenStructureStartOrEnd;
use Lingua::YaTeA::TriggerSet;


sub new
{
    my ($class,$file_path) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ANY} = [];
    $this->{START} = [];
    $this->{END} = [];
    $this->{START_TRIGGERS} = Lingua::YaTeA::TriggerSet->new();
    $this->{END_TRIGGERS} = Lingua::YaTeA::TriggerSet->new();
    $this->loadStructures($file_path);
    return $this;
}


sub loadStructures
{
    my ($this,$file_path) = @_;

    my @infos;
    my $fh = FileHandle->new("<$file_path");
    my $line;
    while ($line= $fh->getline)
    {
	if(($line !~ /^#/)&&($line !~ /^\s*$/))
	{
	    @infos = split /\t/, $line;
	    $this->cleanInfos(\@infos);
	    if($infos[1] eq "ANY")
	    {
		my $fs = Lingua::YaTeA::ForbiddenStructureAny->new(\@infos); 
		push @{$this->{ANY}}, $fs;
	    }
	    else{
		chomp $infos[1];
		if(($infos[1] eq "START") ||($infos[1] eq "END") )
		{
		    my $fs = Lingua::YaTeA::ForbiddenStructureStartOrEnd->new(\@infos,$this->getTriggerSet($infos[1])); 
		    push @{$this->{$infos[1]}}, $fs;
		}
	    }
	}
    }
    $this->sort($this->getSubset("START"));
    $this->sort($this->getSubset("END"));
    
}



sub getTriggerSet
{
    my ($this,$position) = @_;
    my $name = $position . "_TRIGGERS";
    return $this->{$name};
}

sub getSubset
{
    my ($this,$name) = @_;
    return $this->{$name};

}

sub cleanInfos
{
    my ($this,$infos_a) = @_;
    my $info;
    foreach $info (@$infos_a)
    {
	chomp $info;
    }
}

sub sort
{
    my ($this,$subset) = @_;
   
    @$subset = sort ({$b->getLength <=> $a->getLength} @$subset);

}


1;
