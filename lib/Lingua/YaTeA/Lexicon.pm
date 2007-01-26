package Lingua::YaTeA::Lexicon;
use strict;
use Lingua::YaTeA::LexiconItem;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ITEMS} = {};
    return $this;
}

sub addItem
{
    my ($this,$item,$key) = @_;
    $this->{ITEMS}->{$key} = $item;
    $Lingua::YaTeA::LexiconItem::counter++;
}




sub addOccurrence
{
    my ($this,$form) = @_;
    my $item = Lingua::YaTeA::LexiconItem->new($form);
    my $key = $this->buildKey($item);
    if (itemExists($this,$key) == 0)
    {
	$this->addItem($item,$key);
    }
    else
    {
	$item = $this->getItem($key);
    }
    $item->incrementFrequency;
    return $item;
}

sub getItem
{
    my ($this,$key) = @_;
    return $this->{ITEMS}->{$key};
}

sub itemExists
{
    my ($this,$key) = @_;
    if (exists $this->{ITEMS}->{$key}){
	return 1;
    }
    return 0;
}

sub buildKey
{
    my ($this,$item) = @_;
    my $key = $item->{IF}.$item->{POS}.$item->{LF};
    return $key;
}

1;
