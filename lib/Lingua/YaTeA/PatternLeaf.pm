package Lingua::YaTeA::PatternLeaf;
use strict;
use Lingua::YaTeA::Edge;

our @ISA = qw(Lingua::YaTeA::Edge);

sub new
{
    my ($class,$tag,$father) = @_;
    my $this = $class->SUPER::new($father);
    bless ($this,$class);
    $this->{POS_TAG} = $tag;
    return $this;
}


sub getPOS
{
    my ($this) = @_;
    return $this->{POS_TAG};
}

sub print
{
    my ($this) = @_;
    print $this->getPOS;
}


1;

__END__

=head1 NAME

Lingua::YaTeA::PatternLeaf - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::PatternLeaf;
  Lingua::YaTeA::PatternLeaf->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 getPOS()


=head2 print()


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
