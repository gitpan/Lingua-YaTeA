package Lingua::YaTeA::Option;
use strict;

sub new
{
    my ($class,$name,$value) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{NAME} = $name;
    $this->{VALUE} = $value;
    return $this;
}

sub getName
{
    my ($this) = @_;
    return $this->{NAME};
}


sub getValue
{
    my ($this) = @_;
    return $this->{VALUE};
}

sub update
{
    my ($this,$new_value,$message_set,$display_language) = @_;
    my $old_value = $this->getValue;
    $this->{VALUE} = $new_value;
    if(defined $message_set)
    {
	print STDERR "WARNING: " . $this->getName . ": " . $message_set->getMessage('OPTION_VALUE_UPDATE')->getContent($display_language) . "\"" . $new_value . "\" (";
	print STDERR $message_set->getMessage('OLD_OPTION_VALUE')->getContent($display_language) . "\"". $old_value . "\")\n";
    } 
}

1;
