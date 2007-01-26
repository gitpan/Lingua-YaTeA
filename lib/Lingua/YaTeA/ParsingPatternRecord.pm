package Lingua::YaTeA::ParsingPatternRecord;
use strict;
use Lingua::YaTeA::ParsingPattern;

sub new
{
    my ($class,$name) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{NAME} = $name;
    $this->{PARSING_PATTERNS} = ();
    return $this;
}

sub getName
{
    my ($this) = @_;
    return $this->{NAME};

}

sub addPattern
{
    my ($this,$pattern) = @_;
    push @{$this->{PARSING_PATTERNS}}, $pattern;
}

sub getPatterns
{
    my ($this) = @_;
    return $this->{PARSING_PATTERNS};
}

sub print 
{
    my ($this) = @_;
    my $pattern;
    print"[";
    print $this->getName . "\n";
    foreach $pattern (@{$this->getPatterns})
    {
	$pattern->print;
    }
    print "]\n";
}


1;
