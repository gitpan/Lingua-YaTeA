package Lingua::YaTeA::ParsingPatternRecordSet;
use strict;
use warnings;

use Lingua::YaTeA::ParsingPatternRecord;
use Lingua::YaTeA::ParsingPattern;
use Lingua::YaTeA::ParsingPatternParser;

our $max_content_words = 0;

our $VERSION=$Lingua::YaTeA::VERSION;

sub new
{
    my ($class,$file_path,$tag_set,$message_set,$display_language) = @_;
    my $this = {};
    bless ($this,$class);
    $this->{PARSING_RECORDS} = {};
    $this->loadPatterns($file_path,$tag_set,$message_set,$display_language);
    return $this;
}

sub loadPatterns
{
    my ($this,$file_path,$tag_set,$message_set,$display_language) = @_;
  
    my $fh = FileHandle->new("<$file_path");


    my $parser = Lingua::YaTeA::ParsingPatternParser->new();

    $parser->YYData->{PPRS} = $this;
    $parser->YYData->{FH} = $fh;
    $parser->YYData->{CANDIDATES} = $tag_set->getTagList("CANDIDATES");
    $parser->YYData->{PREPOSITIONS} = $tag_set->getTagList("PREPOSITIONS");
    $parser->YYData->{DETERMINERS} = $tag_set->getTagList("DETERMINERS");

    $parser->YYParse(yylex => \&Lingua::YaTeA::ParsingPatternParser::_Lexer, yyerror => \&Lingua::YaTeA::ParsingPatternParser::_Error);

#     print STDERR "nberr: " . $parser->YYNberr() ."\n";
}


sub checkContentWords
{
    my ($this,$num_content_words,$num_line) = @_;
    if($num_content_words == 0)
    {
	die "No content word in pattern line " . $num_line . "\n";
    }
}

sub addPattern
{
    my ($this,$pattern) = @_;
    my $record;
    if (! $this->existRecord($pattern->getPOSSequence))
    {
	$record = $this->addRecord($pattern->getPOSSequence);
    }
    else
    {
	$record = $this->getRecord($pattern->getPOSSequence);
    }
    $record->addPattern($pattern);
}

sub getRecord
{
    my ($this,$name) = @_;
    return $this->{PARSING_RECORDS}->{$name};
}

sub addRecord
{
    my ($this,$name) = @_;
    $this->{PARSING_RECORDS}->{$name} = Lingua::YaTeA::ParsingPatternRecord->new($name);    

}

sub existRecord
{
    my ($this,$name) = @_;
    if (exists $this->{PARSING_RECORDS}{$name})
    {
	return $this->{PARSING_RECORDS}{$name};
    }
    return 0;
}

sub getRecordSet
{
    my ($this) = @_;
    return $this->{PARSING_RECORDS};
	
}


sub print
{
    my ($this) = @_;
    my $record;
    foreach $record (values %{$this->getRecordSet})
    {
	$record->print;
    }
}



1;


__END__

=head1 NAME

Lingua::YaTeA::ParsingPatternRecordSet - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::ParsingPatternRecordSet;
  Lingua::YaTeA::ParsingPatternRecordSet->();

=head1 DESCRIPTION


=head1 METHODS


=head2 new()


=head2 loadPatterns()


=head2 checkContentWords()


=head2 addPattern()


=head2 getRecord()


=head2 addRecord()


=head2 existRecord()


=head2 getRecordSet()


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
