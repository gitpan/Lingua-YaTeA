package Lingua::YaTeA::MonolexicalTestifiedTerm;
use strict;
use Lingua::YaTeA::TestifiedTerm;

our @ISA = qw(Lingua::YaTeA::TestifiedTerm);

sub new
{
    my ($class,$num_content_words,$words_a,$tag_set,$source,$match_type) = @_;
    my $this = $class->SUPER::new($num_content_words,$words_a,$tag_set,$source,$match_type);
    bless ($this,$class);
   
    return $this;
}

sub getHeadAndLinks
{
    my ($this,$LGPmapping_h) = @_;
    my $head = $this->getWord(0);
    my @links;
    return ($head,0,\@links);
}



1;
