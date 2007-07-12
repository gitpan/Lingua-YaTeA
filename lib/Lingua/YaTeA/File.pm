package Lingua::YaTeA::File;
use strict;



sub new
{
    my ($class,$repository,$name) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{INTERNAL_NAME} = ();
    $this->{FULL_NAME} = $name;
    $this->{PATH} = $repository . "/" . $this->{FULL_NAME};
    $this->setInternalName;
    return $this;
}



sub getPath
{
    my ($this) = @_;
    return $this->{PATH};
}

sub getFullName
{
    my ($this) = @_;
    return $this->{FULL_NAME};
}

sub getInternalName
{
    my ($this) = @_;
    return $this->{INTERNAL_NAME};
}

sub setInternalName
{
    my ($this) = @_;
    
    if($this->getFullName =~ /^(.+)\.[^\.]+$/)
    {
	$this->{INTERNAL_NAME} = $1;
    }
    else
    {
	$this->{INTERNAL_NAME} = $this->getFullName;
    }
    
}

1;


__END__

=head1 NAME

Lingua::YaTeA::File - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::File;
  Lingua::YaTeA::File->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 getPath()


=head2 getFullName()


=head2 getInternalName()


=head2 setInternalName()



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
