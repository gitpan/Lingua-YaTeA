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

__END__

=head1 NAME

Lingua::YaTeA::ParsingPatternRecord - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::ParsingPatternRecord;
  Lingua::YaTeA::ParsingPatternRecord->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 getName()


=head2 addPattern()


=head2 getPatterns()


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
