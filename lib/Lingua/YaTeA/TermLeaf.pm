package Lingua::YaTeA::TermLeaf;
use Lingua::YaTeA::Edge;
use strict;
use warnings;

our @ISA = qw(Lingua::YaTeA::Edge);
our $VERSION=$Lingua::YaTeA::VERSION;

sub new
{
    my ($class,$index) = @_;
    my $this = $class->SUPER::new;
    $this->{INDEX} = $index;
    bless ($this,$class);
    return $this;
}


sub getIF
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getIF;
}



sub getPOS
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getPOS;
}

sub getLF
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getLF;
}

sub getID
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getID;
}


sub getIndex
{
    my ($this) = @_;
    return $this->{INDEX};
}

sub getLength
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex]->getLength;
}

sub getWord
{
    my ($this,$words_a) = @_;
    return $words_a->[$this->getIndex];
}

sub searchHead
{
    my ($this) = @_;
    return $this;
}


sub print
{
    my ($this,$words_a,$fh) = @_;
  #   if(!defined $fh)
#     {
# 	$fh = \*STDERR
#     }
    if(defined $words_a)
    {
	 $this->printWords($words_a,$fh) ;	
	 print  $fh " (" . $this->getIndex. ")";
    }
    else
    {
	print $fh $this->getIndex;
    }
}

sub printWords
{
    my ($this,$words_a,$fh) = @_;
#     if(!defined $fh)
#     {
# 	$fh = \*STDERR
#     }
    print $fh $this->getIF($words_a);
}

sub searchRightMostLeaf
{
    my ($this,$depth_r) = @_;
    return $this;
}

sub searchLeftMostLeaf
{
    my ($this) = @_;
    return $this;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::TermLeaf - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::TermLeaf;
  Lingua::YaTeA::TermLeaf->();

=head1 DESCRIPTION


=head1 METHODS

=head2  new()


=head2 getIF()


=head2 getPOS()


=head2 getLF()


=head2 getID()


=head2 getIndex()


=head2 getLength()


=head2 getWord()


=head2 searchHead()


=head2 print()


=head2 printWords()


=head2 searchRightMostLeaf()


=head2 searchLeftMostLeaf()


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
