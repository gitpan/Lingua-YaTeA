package Lingua::YaTeA::Lexicon;
use strict;
use warnings;
use Lingua::YaTeA::LexiconItem;

our $VERSION=$Lingua::YaTeA::VERSION;

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

__END__

=head1 NAME

Lingua::YaTeA::LexiconItem - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::LexiconItem;
  Lingua::YaTeA::LexiconItem->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 addItem()


=head2 addOccurrence()


=head2 getItem()


=head2 itemExists()


=head2 buildKey()



=head1 SEE ALSO

Sophie Aubin and Thierry Hamon. Improving Term Extraction with
Terminological Resources. In Advances in Natural Language Processing
(5th International Conference on NLP, FinTAL 2006). pages
380-387. Tapio Salakoski, Filip Ginter, Sampo Pyysalo, Tapio Pahikkala
(Eds). August 2006. LNAI 4139.


=head1 AUTHOR

Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Thierry Hamon and Sophie Aubin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
