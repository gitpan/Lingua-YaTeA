package Lingua::YaTeA::TagSet;
use strict;



sub new
{
    my ($class,$file_path) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{CANDIDATES} = {};
    $this->{PREPOSITIONS} = {};
    $this->{DETERMINERS} = {};
    $this->{COORDINATIONS} = {};
    $this->{ANY} = {};
    $this->loadTags($file_path);
    return $this;
}

sub loadTags
{
    my ($this,$file_path) = @_;
    
    my $fh = FileHandle->new("<$file_path");
    my $line;
    while ($line= $fh->getline)
    {
	if(($line !~ /^\s*$/)&&($line !~ /^\s*#/)) # line is not empty nor commented
	{
	    $this->parseSubset($line);
	}
    }
}


sub addTag
{
    my ($this,$subset,$tag) = @_;
    $this->getSubset($subset)->{$tag}++;
    $this->getSubset("ANY")->{$tag}++;
}

sub getSubset
{
    my ($this,$subset) = @_;
    return $this->{$subset};
}

sub getTagList
{
    my ($this,$subset) = @_;
    return $this->getSubset($subset)->{"ALL"};
}



sub existTag
{
    my ($this,$subset,$tag) = @_;
    if (exists $this->getSubset($subset)->{$tag})
    {
	return 1;	
    }
    return 0;
}

sub parseSubset
{
    my ($this,$line) = @_;
    my $subset_name;
    my @tags;
    my $tag;
    if($line =~ s/\!\!([\S^=]+)\s*=\s*\(\(([^\!]+)\)\)\!\!\s*$/$2/)
    {
	$subset_name = $1;
	@tags = split /\)\|\(/, $line;
	foreach $tag (@tags)
	{
	    $this->addTag($subset_name,$tag);
	}
	$this->makeALL($subset_name,\@tags);
    }
    else
    {
	die "declaration d'etiquettes: erreur\n";
    }
}

sub makeALL
{
    my ($this,$subset,$tags_a) = @_;
    ${$this->{$subset}}{"ALL"} = $this->sort($tags_a);
}



sub sort
{
    my ($this,$tags_a) = @_;
    my @tmp = reverse (sort @$tags_a);
    my $joint = "\)|\(";
    my $sorted_tag_list = join ($joint,@tmp);
    $sorted_tag_list = "\(\(" .  $sorted_tag_list . "\)\)";
    return $sorted_tag_list;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::TagSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::TagSet;
  Lingua::YaTeA::TagSet->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 loadTags()


=head2 addTag()


=head2 getSubset()


=head2 getTagList()


=head2 existTag()


=head2 parseSubset()


=head2 makeALL()


=head2 sort()


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
