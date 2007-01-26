package Lingua::YaTeA::TermCandidate;
use strict;
use UNIVERSAL qw(isa);

our $id = 0;

sub new
{
    my ($class) = @_;
    my $this;
    $this->{ID} = $id++;
    $this->{KEY} = "";
    $this->{HEAD} = ();
    $this->{WORDS} = [];
    $this->{OCCURRENCES} = [];
    $this->{RELIABILITY} = ();
    $this->{ORIGINAL_PHRASE} = ();
    bless ($this,$class);
    return $this;
}

sub getLength
{
    my ($this) = @_;
    return scalar @{$this->getWords};
}

sub addWord
{
    my ($this,$leaf,$words_a) = @_;
    push @{$this->{WORDS}}, $words_a->[$leaf->getIndex];
}

sub addOccurrence
{
    my ($this,$occurrence) = @_;
    push @{$this->{OCCURRENCES}}, $occurrence;
}

sub addOccurrences
{
    my ($this,$occurrences_a) = @_;
    my $occurrence;
    foreach $occurrence (@$occurrences_a)
    {
	$this->addOccurrence($occurrence);
    }
}

sub getKey
{
    my ($this) = @_;
    return $this->{KEY};
}

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}


sub editKey
{
    my ($this,$string) = @_;
    $this->{KEY} .= $string;
}

sub setHead
{
    my ($this) = @_;
    $this->{HEAD} = $this->searchHead;
}

sub getHead
{
    my ($this) = @_;
    return $this->{HEAD};
}


sub getWords
{
    my ($this) = @_;
    return $this->{WORDS};
}

sub getOccurrences
{
    my ($this) = @_;
    return $this->{OCCURRENCES};
}

sub buildLinguisticInfos
{
    my ($this,$tagset) = @_;
    my $if;
    my $pos;
    my $lf;
    my $word;
    
    foreach $word (@{$this->getWords})
    {
	$if .= $word->getIF . " " ;
	if ($tagset->existTag('PREPOSITIONS',$word->getIF))
	{
	    $pos .= $word->getLF . " ";
	}
	else
	{
	    $pos .= $word->getPOS . " ";
	}
	$lf .= $word->getLF . " " ;
    }
    $if =~ s/\s+$//;
    $pos =~ s/\s+$//;
    $lf =~ s/\s+$//;
    return ($if,$pos,$lf);

}

sub getIF
{
    my ($this) = @_;
    my $word;
    my $if;
    foreach $word (@{$this->getWords})
    {
	$if .= $word->getIF . " " ;
    }
    $if =~ s/\s+$//;
    return $if;
}

sub getLF
{
    my ($this) = @_;
    my $word;
    my $lf;
    foreach $word (@{$this->getWords})
    {
	$lf .= $word->getLF . " " ;
    }
    $lf =~ s/\s+$//;
    return $lf;
}

sub getPOS
{
    my ($this) = @_;
    my $word;
    my $pos;
    foreach $word (@{$this->getWords})
    {
	$pos .= $word->getPOS . " " ;
    }
    $pos =~ s/\s+$//;
    return $pos;
}

sub getFrequency
{
    my ($this) = @_;
    return scalar @{$this->getOccurrences};
}

sub setReliability
{
    my ($this,$reliability) = @_;
    $this->{RELIABILITY} = $reliability;
}

sub getReliability
{
    my ($this) = @_;
    return $this->{RELIABILITY};
}

sub getOriginalPhrase
{
    my ($this) = @_;
    return $this->{ORIGINAL_PHRASE};
}

1;
