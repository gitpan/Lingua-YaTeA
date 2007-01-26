package Lingua::YaTeA::TestifiedTermMark;
use strict;
use Lingua::YaTeA::AnnotationMark;


our @ISA = qw(Lingua::YaTeA::AnnotationMark);

sub new
{
    my ($class,$form) = @_;
    my ($frontier_id,$testified_id,$type) = $class->parse($form);
    my $this = $class->SUPER::new($form,$frontier_id,$type);
    bless ($this,$class);
    $this->{TESTIFIED_ID} = $testified_id;
    $this->{START} = ();
    $this->{END} = ();
    return $this;
}


sub getTestifiedID
{
    my ($this) = @_;
    return $this->{TESTIFIED_ID};
}

sub isOpener
{
    my ($this) = @_;
    if ($this->getType eq "opener")
    {
	return 1;
    }
    return 0;
}

sub isCloser
{
    my ($this) = @_;
    if ($this->getType eq "closer")
    {
	return 1;
    }
    return 0;
}

sub parse
{
    my ($class,$form) = @_;
    my $frontier_id;
    my $testified_id;
    my $type;

    # opening testified term frontier
    if ($form =~ /^\<FRONTIER ID=([0-9]+) TT=([0-9]+)/)
    {
	$frontier_id = $1;
	$testified_id = $2;
	$type = "opener";
    }
    # closing testified term frontier
    else
    {
	if ($form =~ /^\<\/FRONTIER ID=([0-9]+) TT=([0-9]+)/)
	{
	    $frontier_id = $1;
	    $testified_id = $2;
	    $type = "closer";
	}
	else
	{
	    die "balise invalide :" . $form;
	}
    }
    return ($frontier_id,$testified_id,$type);
}

sub getStart
{
    my ($this) = @_;
    return $this->{START};  
}

sub getEnd
{
    my ($this) = @_;
    return $this->{END};  
}

1;
