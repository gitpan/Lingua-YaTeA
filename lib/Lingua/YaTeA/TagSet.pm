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
