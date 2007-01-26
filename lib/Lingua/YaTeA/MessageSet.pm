package Lingua::YaTeA::MessageSet;
use strict;

use Lingua::YaTeA::Message;
use Data::Dumper;

sub new
{
    my ($class,$file,$language) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{MESSAGES} = {};
    $this->loadMessages($file,$language);
    return $this;
}

sub loadMessages
{
    my ($this,$file,$language) = @_;
    my $path = $file->getPath;
    my $fh = FileHandle->new("<$path");
    my $line;
    my $line_counter = 0;
    my $message;
    my $option;
  
    
    while ($line= $fh->getline)
    {
	$line_counter++;
	if ($line =~ /^([^\s]+) = \"(.+)\"\s*$/)
	{
	    $message = Lingua::YaTeA::Message->new($1,$2,$language);
	    $this->addMessage($message);	    
	}
	else
	{
	    if($line !~ /^\s*$/)
	    {
		die "ill-formed message in file:" .$file->getPath .  " line " . $line_counter . "\n";
	    }
	}
    }
}

sub addMessage
{
    my ($this,$message) = @_;
    $this->{MESSAGES}->{$message->getName} = $message;
}


sub getMessage
{
    my ($this,$name) = @_;
    return $this->getMessages->{$name};
}

sub getMessages
{
    my ($this) = @_;
    return $this->{MESSAGES};
}
1;
