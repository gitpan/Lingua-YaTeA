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
