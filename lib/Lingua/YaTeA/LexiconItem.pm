package Lingua::YaTeA::LexiconItem;
use strict;

our $counter =0;

sub new
{
    my ($class,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ID} = $counter;
    my @lex_infos = split /\t/, $form;
    $this->{IF} = $lex_infos[0];
    $this->{POS} = $lex_infos[1];
    $this->{LF} = $this->setLF($lex_infos[2],$this->{IF});
    $this->{LENGTH} = $this->setLength;
    $this->{FREQUENCY} = 0;
    return $this;
}


sub setLF
{
    my ($this,$LF,$IF) = @_;
    if ($LF =~ /(\<unknown\>)|(\@card@)/){ # si le lemme est inconnu du tagger (TTG) : lemme = forme flechie
	return $IF;               
    } 
    return $LF;
} 

sub setLength
{
    my ($this) = @_;
    return length($this->{IF});
}

sub incrementFrequency
{
    my ($this) = @_;
    $this->{FREQUENCY}++;
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}

sub getIF
{
    my ($this) = @_;
    return $this->{IF};
}

sub getPOS
{
    my ($this) = @_;
    return $this->{POS};
}

sub getLF
{
    my ($this) = @_;
    return $this->{LF};
}

sub getLength
{
    my ($this) = @_;
    return $this->{LENGTH};
}

sub getFrequency
{
    my ($this) = @_;
    return $this->{FREQUENCY};
}

sub getAny
{
    my ($this,$field) = @_;
    return $this->{$field};
}

sub isCleaningFrontier
{
    my ($this,$chunking_data) = @_;
    my @types = ("POS",  "LF", "IF");
    my $type;
    foreach $type (@types)
    {
	if ($chunking_data->existData("CleaningFrontiers",$type,$this->getAny($type)) == 1)
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
	if ($chunking_data->existData("CleaningExceptions",$type,$this->getAny($type)) == 1)
	{
	    return 1;
	}
    }
    return 0;
}

1;
