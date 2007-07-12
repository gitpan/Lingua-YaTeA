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

__END__

=head1 NAME

Lingua::YaTeA::LinguisticItem - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::LinguisticItem;
  Lingua::YaTeA::LinguisticItem->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getForm()


=head2 getType()


=head2 matchesWord()


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
