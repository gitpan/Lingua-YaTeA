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
	    die "Invalid line: " .$form . "\n";
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

__END__

=head1 NAME

Lingua::YaTeA::ForbiddenStructureMark - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::ForbiddenStructureMark;
  Lingua::YaTeA::ForbiddenStructureMark->new($form);

=head1 DESCRIPTION


=head1 METHODS

=head2 new()

    new($form);

=head2 parse()

    parse($form);

=head2 isOpener()

    isOpener();

=head2 isCloser()

    isCloser();

=head2 getAction()

    getAction();

=head2 getSplitAfter()

    getSplitAfter();

=head2 isActionSplit()

    isActionSplit();

=head2 isActionDelete()

    isActionDelete();


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
