package Lingua::YaTeA::Edge;
use strict;
use UNIVERSAL qw(isa);



sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    #$this->{FATHER} = $father;
    #$this->{POSITION} = "";
    return $this;
}


sub copyRecursively
{
    my ($this,$new_set,$father) = @_;
    my $new;
    if (isa($this,'Lingua::YaTeA::TermLeaf'))
    {
	return "";
    }
    else{
	if(isa($this,'Lingua::YaTeA::InternalNode'))
	{
	    return $this->copyRecursively($new_set,$father);
	}
	else{
	    if (isa($this,'Lingua::YaTeA::PatternLeaf'))
	    {
		return "";
	    }
	}
    }
}

sub update
{
    my ($this,$new_value) = @_;
    $this = $new_value;
}



sub print
{
    my ($this,$words_a) = @_;
    if (isa($this,"Lingua::YaTeA::Node"))
    {
	 print "Node " . $this->getID;
    }
    else{
	$this->printWords($words_a);
    }
}

1;

__END__

=head1 NAME

Lingua::YaTeA::Edge - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::Edge;
  Lingua::YaTeA::Edge->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head2 copyRecursively()


=head2 update()


=head2 print()



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
