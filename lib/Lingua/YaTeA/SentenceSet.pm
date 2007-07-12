package Lingua::YaTeA::SentenceSet;
use strict;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{SENTENCES} = [];
    return $this;
}

sub addSentence
{
    my ($this,$documents) = @_;
    push @{$this->{SENTENCES}}, Lingua::YaTeA::Sentence->new($documents);
}

sub getCurrent
{
    my ($this)= @_;
    return $this->{SENTENCES}[-1];
}

sub getSentences
{
    my ($this)= @_;
    return $this->{SENTENCES};
}
1;

__END__

=head1 NAME

Lingua::YaTeA::SentenceSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::SentenceSet;
  Lingua::YaTeA::SentenceSet->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 addSentence()


=head2 getCurrent()


=head2 getSentences()



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
