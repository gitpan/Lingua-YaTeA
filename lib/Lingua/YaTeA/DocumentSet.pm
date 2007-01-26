package Lingua::YaTeA::DocumentSet;
use strict;
use Lingua::YaTeA::Document;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{DOCUMENTS} = [];
    $this->addDefaultDocument;
    return $this;
}


sub addDefaultDocument
{
    my ($this,$word) = @_;
    push @{$this->{DOCUMENTS}}, Lingua::YaTeA::Document->newDefault;
}

sub addDocument
{
    my ($this,$word) = @_;
    
    if((scalar @{$this->{DOCUMENTS}} == 1)&&($this->getCurrent->getName eq "unknown") && ($Sentence::counter == 0)){
	$this->getCurrent->update($word);
    }
    else{
	$Lingua::YaTeA::Document::counter++;
	push @{$this->{DOCUMENTS}}, Lingua::YaTeA::Document->new($word);
	
    }

}


sub getCurrent
{
    my ($this)= @_;
    return $this->{DOCUMENTS}[-1];
}
1;
