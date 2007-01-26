package Lingua::YaTeA::LinguisticItem;
use strict;

sub new
{
    my ($class,$type,$form) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{TYPE} = $type;
    $this->{FORM} = $form;
    return $this;
}

sub getForm
{
    my ($this) = @_;
    return $this->{FORM};
}

sub getType
{
    my ($this) = @_;
    return $this->{TYPE};
}

sub matchesWord
{
    my ($this,$word) = @_;
    if($this->getForm eq $word->getLexItem->getAny($this->getType))
    {
	return 1;
    }
    return;
}
1;
