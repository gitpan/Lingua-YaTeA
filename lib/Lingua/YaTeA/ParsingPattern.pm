package Lingua::YaTeA::ParsingPattern;
use strict;
use Parse::Lex;
use Lingua::YaTeA::NodeSet;
use Lingua::YaTeA::InternalNode;
use Lingua::YaTeA::RootNode;
use Lingua::YaTeA::PatternLeaf;
use Data::Dumper;
 

sub new
{
    my ($class,$parse,$pos_sequence,$node_set,$priority,$direction,$num_content_words,$num_line) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{PARSE} = $parse;
    $this->{PRIORITY} = $priority;
    $this->{PARSING_DIRECTION} = $direction;
    $this->{DECLARATION_LINE} = $num_line;
    $this->{POS_SEQUENCE} = $pos_sequence;
    $this->{NODE_SET} = $node_set;
    $this->{CONTENT_WORDS} = $num_content_words;
    return $this;
}

sub setNodeSet
{
    my ($this,$node_set) = @_;
    $this->{NODE_SET} = $node_set;
}



sub getParse
{
    my ($this) = @_;
    return $this->{PARSE};
}


sub getLength
{
    my ($this) = @_;
    my @array = split (/ /, $this->getPOSSequence);
    return scalar @array;
}


sub getPriority
{
    my ($this) = @_;
    return $this->{PRIORITY};
}

sub getDirection
{
    my ($this) = @_;
    return $this->{PARSING_DIRECTION};
}

sub getNodeSet
{
    my ($this) = @_;
    return $this->{NODE_SET};
}

sub getNumContentWords
{
    my ($this) = @_;
    return $this->{CONTENT_WORDS};
}

sub getPOSSequence
{
    my ($this) = @_;
    return $this->{POS_SEQUENCE};
}

sub print
{
    my ($this) = @_;
   
    print "\t[\n";
    print "\tPARSE: " . $this->getParse . "\n";
    print "\tPOS: " . $this->getPOSSequence . "\n";
    print "\tPRIORITY: " . $this->getPriority . "\n";
    print "\tPARSING_DIRECTION: " . $this->getDirection . "\n";
    print "\tNODE_SET: \n";
    $this->getNodeSet->print;
    print "]\n";
}






1;
