package Lingua::YaTeA::MonolexicalPhrase;
use Lingua::YaTeA::Phrase;
use strict;
use NEXT;

our @ISA = qw(Lingua::YaTeA::Phrase);
our $counter = 0;


sub new
{
    my ($class,$num_content_words,$words_a,$tag_set) = @_;
    my $this = $class->SUPER::new($class,$num_content_words,$words_a,$tag_set);
    bless ($this,$class);
    return $this;
}

sub print
{
    my ($this,$fh) = @_;
    if(defined $fh)
    {
	print $fh "if: " . $this->getIF . "\n";
	print $fh "pos: " . $this->getPOS . "\n";
	print $fh "lf: " . $this->getLF . "\n";
	print $fh "is a term candidate: " . $this->isTC. "\n";
    }
    else
    {
	print "if: " . $this->getIF . "\n";
	print "pos: " . $this->getPOS . "\n";
	print "lf: " . $this->getLF . "\n";
	print "is a term candidate: " . $this->isTC. "\n";
    }
}



1;
