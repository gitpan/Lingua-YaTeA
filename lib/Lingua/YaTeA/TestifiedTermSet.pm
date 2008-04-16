package Lingua::YaTeA::TestifiedTermSet;
use strict;
use warnings;
use Lingua::YaTeA::MultiWordTestifiedTerm;
use Lingua::YaTeA::MonolexicalTestifiedTerm;
use UNIVERSAL qw(isa);

our $VERSION=$Lingua::YaTeA::VERSION;

sub new
{
    my ($class) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{TESTIFIED_TERMS} = {};
    $this->{LEXICON} = Lingua::YaTeA::Lexicon->new;
    $this->{SOURCES} = [];
    return $this;
}

sub addSubset
{
    my ($this,$file_path,$filtering_lexicon_h,$sentence_boundary,$match_type,$tag_set) = @_;
    my $line;
    
    
    my $format = $this->testTerminologyFormat($file_path);
    print STDERR "\  -". $file_path . " (format: ". $format . ")\n";
    
    if($format eq "TTG")
    {
	$this->loadTTGformatTerminology($file_path,$filtering_lexicon_h,$sentence_boundary,$match_type,$tag_set);
    }
    
}

sub testTerminologyFormat
{
    my ($this,$file_path) = @_;
    my $fh = FileHandle->new("<$file_path");
    my $line;
    while ($line= $fh->getline)
    {
	if($line =~ /^[^\t]+\t[^\t]+\t[^\t]+$/)
	{
	    return "TTG";
	}
	
    }
    die "undefined terminology input format";

}

sub loadTTGformatTerminology
{
    my ($this,$file_path,$filtering_lexicon_h,$sentence_boundary,$match_type,$tag_set) = @_;

    my $fh = FileHandle->new("<$file_path");    
    my $word;
    my $block;

    local $/ = "\.\t". $sentence_boundary ."\t\.\n";
    
    while (! $fh->eof)
    {
	$block = $fh->getline;
	$this->buildTestifiedTerm($block,$sentence_boundary,$match_type,$filtering_lexicon_h,$file_path,$tag_set);
    }

}

sub buildTestifiedTerm
{
    my ($this,$block,$sentence_boundary,$match_type,$filtering_lexicon_h,$source,$tag_set) = @_;
    my $word;
    my $testified;
    my $item;
    my @words = split /\n/,$block;
    my @clean_words;
    my $num_content_words = 0;
    my @lex_items;
    foreach $word (@words)
    {
	if (
	    ($word =~ /^([^\t]+)\t([^\t]+)\t([^\t]+)$/)
	    &&
	    ($2 ne $sentence_boundary)
	    )
	{
	    
	    if($match_type eq "loose") # look at IF or LF
	    {
		if(
		    (!exists $filtering_lexicon_h->{lc($1)})
		    &&
		    (!exists $filtering_lexicon_h->{lc($3)})
		    )
		{
		    # current word does not appear in the corpus : testified term won't be loaded
		    return;
		}
	    }
	    else
	    {
		if($match_type eq "strict") # look at IF and POS
		{
		    if
			(!exists $filtering_lexicon_h->{lc($1)."~".$2})
		    {
			# current word does not appear in the corpus : testified term won't be loaded
			return;
		    }

		}
		else
		{
		    # default match: look at IF
		    if
			(!exists $filtering_lexicon_h->{lc($1)})
		    {
			# current word does not appear in the corpus : testified term won't be loaded
			return;
		    }
		}		

	    }
	    push @clean_words, $word;
	}
    }
    foreach $word (@clean_words)
    {
	
	$item = $this->getLexicon->addOccurrence($word);
	if ($tag_set->existTag('CANDIDATES',$item->getPOS))
	{
	    $num_content_words++;
	}
	push @lex_items, $item;
    }
    if(scalar @lex_items > 1)
    {
	$testified = Lingua::YaTeA::MultiWordTestifiedTerm->new($num_content_words,\@lex_items,$tag_set,$source,$match_type);
    }
    else
    {
	if(scalar @lex_items == 1)
	{
	    $testified = Lingua::YaTeA::MonolexicalTestifiedTerm->new($num_content_words,\@lex_items,$tag_set,$source,$match_type);
	}
    }
    if(isa($testified,'Lingua::YaTeA::TestifiedTerm'))
    {
	$this->addTestified($testified);
    }
}

sub addTestified
{
    my ($this,$testified) = @_;
    my $key = $testified->buildKey;
    if(!exists $this->getTestifiedTerms->{$key})
    {
	$Lingua::YaTeA::TestifiedTerm::id++;
	$this->getTestifiedTerms->{$key} = $testified;
    }
    else
    {
	push @{$this->getTestifiedTerms->{$key}->getSource}, @{$testified->getSource};
    }
}


sub getLexicon
{
    my ($this) = @_;
    return $this->{LEXICON};
}

sub getTestifiedTerms
{
    my ($this) = @_;
    return $this->{TESTIFIED_TERMS};
}

sub size
{
    my ($this) = @_;
    return scalar (keys %{$this->getTestifiedTerms});
}


sub changeKeyToID
{
    my ($this) = @_;
    my $original_h = $this->getTestifiedTerms;
    my %new;
    my $testified;
    
    foreach $testified (values %$original_h)
    {
	$new{$testified->getID} = $testified;
    }
    %{$this->getTestifiedTerms} = %new;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::TestifiedTermSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::TestifiedTermSet;
  Lingua::YaTeA::TestifiedTermSet->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 addSubset()


=head2 testTerminologyFormat()


=head2 loadTTGformatTerminology()


=head2 buildTestifiedTerm()


=head2 addTestified()


=head2 getLexicon()


=head2 getTestifiedTerms()


=head2 size()


=head2 changeKeyToID()


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
