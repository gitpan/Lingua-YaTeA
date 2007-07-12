package Lingua::YaTeA::FileSet;
use Lingua::YaTeA::File;
use strict;


sub new
{
    my ($class,$repository) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{REPOSITORY} = $repository;
    $this->{FILES} = ();
    return $this;
}


sub checkRepositoryExists
{
    my ($this) = @_;
    if (! -d $this->getRepository)
    {
	die "No such repository :" . $this->getRepository . "\n";
    }
    else
    {
	print STDERR "Data will be loaded from: ". $this->getRepository . "\n";
    }
}

sub addFile
{
    my ($this,$repository,$name) = @_;
    my $file;
    my $option;
    
    $file = Lingua::YaTeA::File->new($repository,$name);
    
    $this->{FILES}->{$file->getInternalName} = $file;
}

sub getFile
{
    my ($this,$name) = @_;
    return $this->{FILES}->{$name};
}

sub addFiles
{
    my ($this,$repository,$file_name_a) = @_;
    my $name;
    foreach $name (@$file_name_a)
    {
	$this->addFile($repository,$name);
    }
}

sub getRepository
{
    my ($this) = @_;
    return $this->{REPOSITORY} ;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::FileSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::FileSet;
  Lingua::YaTeA::FileSet->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 checkRepositoryExists()


=head2 addFile()


=head2 getFile()


=head2 addFiles()


=head2 getRepository()



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
