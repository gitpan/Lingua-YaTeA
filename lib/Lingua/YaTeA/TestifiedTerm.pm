package Lingua::YaTeA::TestifiedTerm;
use strict;
use UNIVERSAL qw(isa);
use NEXT;

our $id = 0;

sub new
{
    my ($class_or_object,$num_content_words,$words_a,$tag_set,$source,$match_type) = @_;
   
    my $this = shift;
    
    $this = bless {}, $this unless ref $this;
    $this->{ID} = $id;
    $this->{IF} = ();
    $this->{POS} = ();
    $this->{LF} = ();
    $this->{SOURCE} = [];
    $this->{WORDS} = [];
    $this->{REG_EXP} = ();
    $this->{FOUND} = 0;
    $this->{OCCURRENCES} = [];
    $this->{INDEX_SET} = Lingua::YaTeA::IndexSet->new;
    $this->buildLinguisticInfos($words_a,$tag_set);
    push @{$this->getSource}, $source;
    $this->buildRegularExpression($match_type);
    $this->setIndexSet(scalar @{$this->getWords});
    $this->NEXT::new(@_);
    return $this;
}

sub buildLinguisticInfos
{
    my ($this,$lex_items_a,$tag_set) = @_;
    
    my $lex;
    my $IF;
    my $POS;
    my $LF;
    my %prep = ("of"=>"of", "to"=>"to");
    
    
    foreach $lex (@$lex_items_a)
    {
	if(isa($lex, "Lingua::YaTeA::LexiconItem"))
	{
	    $IF .= $lex->getIF . " " ;
	    #if (exists $prep{$lex->getLF})
	    if ($tag_set->existTag('PREPOSITIONS',$lex->getIF))
	    {
		$POS .= $lex->getLF . " ";
	    }
	    else
	    {
		$POS .= $lex->getPOS . " ";
	    }
	    $LF .= $lex->getLF . " " ;
	    push @{$this->getWords}, $lex;
	}
	else
	{
	    die "problem: " . $lex . "\n";
	}
    }
    $IF =~ s/\s+$//;
    $POS =~ s/\s+$//;
    $LF =~ s/\s+$//;
    $this->setIF($IF);
    $this->setPOS($POS);
    $this->setLF($LF);
}

sub getWords
{
    my ($this) = @_;
    return $this->{WORDS};
}

sub setIF
{
    my ($this,$new) = @_;
    $this->{IF} = $new;
}

sub setPOS
{
    my ($this,$new) = @_;
    $this->{POS} = $new;
}

sub setLF
{
    my ($this,$new) = @_;
    $this->{LF} = $new;
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

sub getID
{
    my ($this) = @_;
    return $this->{ID};
}


sub buildKey
{
    my ($this) = @_;
    my $key = $this->{"IF"} . "~" . $this->{"POS"} . "~" . $this->{"LF"};
    return $key;
}

sub getSource
{
    my ($this) = @_;
    return $this->{SOURCE};
}

sub buildRegularExpression
{
    my ($this,$match_type) = @_;
    my $frontier = "\(\\n\\<\\/\?FRONTIER ID=\[0\-9\]\+ TT=\[0\-9\]\+\\>\)\*";
    my $reg_exp = $frontier . "\?";
    my $lex;
   
    if($match_type eq "loose") # IF or LF
    {
	foreach $lex (@{$this->getWords})
	{
	    $reg_exp .= "\(\(\\n".quotemeta($lex->getIF) . "\\t\[\^\\t\]\+\\t\[\^\\t\]\+\)\|\(\\n\[\^\\t\]\+\\t\[\^\\t\]\+\\t". quotemeta($lex->getLF) . "\)\)" . $frontier;
	    
	}
    }
    else
    { 
	if($match_type eq "strict") # IF and POS
	{
	    foreach $lex (@{$this->getWords})
	    {
		$reg_exp .= "\\n".quotemeta($lex->getIF) . "\\t".quotemeta($lex->getPOS) ."\\t\[\^\\t\]\+" . $frontier;
	    }
	}
	else
	{
	    foreach $lex (@{$this->getWords}) # IF
	    {
		$reg_exp .= "\\n".quotemeta($lex->getIF) . "\\t\[\^\\t\]\+\\t\[\^\\t\]\+" . $frontier;
	    }
	}
    }
    $reg_exp .= "\\n";
    $this->{REG_EXP} = $reg_exp;
}


sub getRegExp
{
    my ($this) = @_;
    return $this->{REG_EXP};
}

sub getWord
{
    my ($this,$index) = @_;
    return $this->getWords->[$index];

}

sub addOccurrence
{
    my ($this,$phrase_occurrence,$phrase,$key) = @_;
    my $start_offset;
    my $end_offset;
    my $testified_occurrence;
    my @index = split(/-/,$key);

    ($start_offset,$end_offset) = $this->getPositionInPhrase($phrase,\@index);

    $testified_occurrence = Lingua::YaTeA::Occurrence->new;
    $testified_occurrence->setInfoForTestifiedTerm($phrase_occurrence->getSentence,$phrase_occurrence->getStartChar + $start_offset, $phrase_occurrence->getEndChar - $end_offset);
    push @{$this->{OCCURRENCES}}, $testified_occurrence; 
}

sub getPositionInPhrase
{
    my ($this,$phrase,$index_a) = @_;
    my @before;
    my @after;
    my $index;
    my $start_offset = 0;
    my $end_offset = 0;
    for ($index = 0; $index < $index_a->[0]; $index++)
    {
	push @before, $index;
    }
    for ($index = $index_a->[$#$index_a] +1; $index < $phrase->getIndexSet->getSize; $index++)
    {
	push @after, $index;
    }

    foreach $index (@before)
    {
	$start_offset += $phrase->getWord($index)->getLength +1;
    }
    
    foreach $index (@after)
    {
	$end_offset += $phrase->getWord($index)->getLength +1;
    }
   
    return ($start_offset,$end_offset);   
}

sub setIndexSet
{
    my ($this,$size) = @_;
    my $i = 0;
    while ($i < $size)
    {
	$this->getIndexSet->addIndex($i);
	$i++;
    }
    
}

sub getIndexSet
{
    my ($this) = @_;
    return $this->{INDEX_SET};
}

sub getOccurrences
{
    my ($this) = @_;
    return $this->{OCCURRENCES};
}


1;
