package Lingua::YaTeA::Message;
use strict;

sub new
{
    my ($class,$name,$content,$language) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{NAME} = $name;
    $this->{$language}= $content;
    return $this;
}



sub getContent
{
    my ($this,$language) = @_;
    return $this->{$language};
}

sub getName
{
    my ($this) = @_;
    return $this->{NAME};
}

1;
