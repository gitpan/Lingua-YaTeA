package Lingua::YaTeA::ChunkingDataSet;
use strict;
use Lingua::YaTeA::ChunkingDataSubset;


sub new
{
    my ($class,$file_set) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{ChunkingFrontiers} = Lingua::YaTeA::ChunkingDataSubset->new;
    $this->{ChunkingExceptions} = Lingua::YaTeA::ChunkingDataSubset->new;
    $this->{CleaningFrontiers} = Lingua::YaTeA::ChunkingDataSubset->new;
    $this->{CleaningExceptions} = Lingua::YaTeA::ChunkingDataSubset->new;
 
    $this->loadData($file_set);
    return $this;
}


sub loadData
{
    my ($this,$file_set) = @_;
    my $name;
    my $path;
    my $subset;
    my $line;
    my $type;
    my $value;
    my @file_names = ("ChunkingFrontiers","ChunkingExceptions","CleaningFrontiers","CleaningExceptions");
    foreach $name (@file_names)
    {
	$path = $file_set->getFile($name)->getPath;
		
	$subset = $this->getSubset($name);
	
	my $fh = FileHandle->new("<$path");

	while ($line= $fh->getline)
	{
	    if(($line !~ /^#/)&&($line !~ /^\s*$/))
	    {
		chomp $line;
		$line =~ /([^\t]+)\t([^\t]+)/;
		$type= $1;
		$value = $2;
		$subset->addSome($type,$value);
	    }
	}
	
    }
}

sub getSubset
{
    my ($this,$name) = @_;
    return $this->{$name};
}


sub existData
{
    my ($this,$set,$type,$data) = @_;
    return $this->getSubset($set)->existData($type,$data);
}

1;
