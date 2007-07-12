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

__END__

=head1 NAME

Lingua::YaTeA::DocumentSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::DocumentSet;
  Lingua::YaTeA::DocumentSet->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 addDefaultDocument()


=head2 addDocument()


=head2 getCurrent()



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
