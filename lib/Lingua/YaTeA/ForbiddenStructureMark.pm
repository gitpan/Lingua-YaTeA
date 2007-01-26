package Lingua::YaTeA::ForbiddenStructureMark;
use strict;
use Lingua::YaTeA::AnnotationMark;


our @ISA = qw(Lingua::YaTeA::AnnotationMark);

sub new
{
    my ($class,$form) = @_;
    my ($id,$action,$split_after,$type) = $class->parse($form);
    my $this = $class->SUPER::new($form,$id,$type);
    bless ($this,$class);
    $this->{ACTION} = $action;
    $this->{SPLIT_AFTER} = $split_after;
    return $this;
}

sub parse
{
    my ($class,$form) = @_;
    my $id;
    my $action;
    my $split_after;
    my $type;
    
    if ($form =~ /^\<FORBIDDEN ID=([0-9]+) ACTION=([a-z]+)( SPLIT_AFTER=([0-9]+))?\>/)
    { # opening forbidden structure mark
	$type = "opener";
	$id = $1;
	$action = $2;
	if ($action eq "split")
	{ # if splitting instructions are provided
	    $split_after = $4;
	}
    }
    else
    { # closing forbidden structure mark
	if($form =~ /^\<\/FORBIDDEN ID=([0-9]+) ACTION=([a-z]+)( SPLIT_AFTER=([0-9]+))?\>/)
	{
	    $type = "closer";
	    $id = $1;
	    $action = $2;
	    if ($action eq "split")
	    { # if splitting instructions are provided
		$split_after = $4;
	    }
	}
	else{
	    die "Ligne invalide: " .$form . "\n";
	}  
    }
    return ($id,$action,$split_after,$type);
}

sub isOpener
{
    my ($this) = @_;
    if($this->{TYPE} eq "opener")
    {
	return 1
    }
    return 0;
}

sub isCloser
{
    my ($this) = @_;
    if($this->{TYPE} eq "closer")
    {
	return 1
    }
    return 0;
}

sub getAction
{
    my ($this) = @_;
    return $this->{ACTION}
}


sub getSplitAfter
{
    my ($this) = @_;
    return $this->{SPLIT_AFTER}
}


sub isActionSplit
{
    my ($this) = @_;
    if($this->getAction eq "split")
    {
	return 1
    }
    return 0;
}

sub isActionDelete
{
    my ($this) = @_;
    if($this->getAction eq "delete")
    {
	return 1
    }
    return 0;
}

1;
