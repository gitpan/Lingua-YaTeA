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
