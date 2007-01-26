package Lingua::YaTeA::ParsingPatternRecordSet;
use strict;
use Lingua::YaTeA::ParsingPatternRecord;
use Parse::Lex;
use Lingua::YaTeA::ParsingPattern;

our $max_content_words = 0;

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
    my $lexer;
    my @pos_sequence;
    my @uncomplete;
    my $pattern;
    my $pos_sequence;
    my $priority;
    my $direction;
    my $parse;
    my @parse;
    my $node_set;
    my $node;
    my $level = 0;
    my $num_line = 1;
    my $num_content_words;
    my @token = (
	'empty', '^((^\s*\n$)|(^\s*#.*\n$))', sub {
	    $num_line++;
	},
	'new_pattern', '^', sub{
	    $node_set = Lingua::YaTeA::NodeSet->new;
	    $lexer->end('new_pattern');
	    $lexer->start('parse');
	    $_[1]
	},
	'parse:OPEN', '\(', sub{
	    if ($level == 0)
	    {
		$node = Lingua::YaTeA::RootNode->new($level);
	    }
	    else
	    {
		$node = Lingua::YaTeA::InternalNode->new($level);
	    }
	    $node_set->addNode($node);
	    push @uncomplete, $node;
 	    $level++;
	    push @parse, $_[1];
	},
	'parse:CANDIDATE', $tag_set->getTagList("CANDIDATES") .'\<=(([MH])||(C[12]))\>', sub{
	    $_[1] =~ /([^\s\<\)]+)\<=(([MH]||(C[12])))\>/; # tag parsing (tag + status)
	    my $edge = Lingua::YaTeA::PatternLeaf->new($1,$node);
	    $node->addEdge($edge,$2);
	    $num_content_words++;
	    push @pos_sequence,$1;  
	    push @parse, $_[1];
	},
	'parse:PREP', $tag_set->getTagList("PREPOSITIONS"), sub{
	    $node->{"PREP"} = $_[1]; 
	    push @pos_sequence, $_[1];
	    push @parse, $_[1];
	},

	'parse:DET', $tag_set->getTagList("DETERMINERS"), sub{
	    $node->{"DET"} = $_[1]; 
	    push @pos_sequence, $_[1]; 
	    push @parse, $_[1];
	},

	'parse:CLOSE', '\)\<=(([MH])||(C[12]))\>', sub{
	    pop @uncomplete;
	    $node->linkToFather(\@uncomplete,$1);
	    $node = $uncomplete[$#uncomplete];
	    $level--;
	    push @parse, $_[1];
	},
	'parse:END', '\)\t', sub{
	    
	    $lexer->end('parse');
	    $lexer->start('priority');
	    push @parse, ')';
	    $_[1];
	},
	'priority', '([0-9]+)\t', sub{
	    $priority = $1;
	    $lexer->end('priority');
	    $lexer->start('direction');
	},
	'direction', '((LEFT)|(RIGHT))', sub{
	    $direction = $_[1];
	    $lexer->end('direction');
	},
	'end', '\n', sub {
	    $pos_sequence = join(" ",@pos_sequence);
	    $parse = join(" ",@parse);
	    $node_set->setRoot; 
	    $pattern = Lingua::YaTeA::ParsingPattern->new($parse,$pos_sequence,$node_set,$priority,$direction,$num_content_words,$num_line);
	    $this->addPattern($pattern);
	    @pos_sequence = ();
	    @uncomplete = ();
	    @parse = ();
	    $level = 0;
	    $this->checkContentWords($num_content_words,$num_line);

	    if ($num_content_words > $max_content_words)
	    {
		$max_content_words = $num_content_words;
	    }
	    $num_content_words = 0;
	    $num_line++;
	    $lexer->start('INITIAL');
	},
	# erreur: message + sortie du programme
	'ALL:ERROR' => '' => sub{   # patron mal forme
	    print STDERR $message_set->getMessage('INVALID_TOKEN')->getContent($display_language) . $$num_line . $message_set->getMessage('IN_FILE')->getContent($display_language) . $file_path . "\n";
	    print STDERR "Patron mal forme " . $num_line ." :: " . $pos_sequence . "\n" ;
	    $lexer->end('ALL');
	    exit 0;
	    
	}
	);
#    Parse::Lex->trace;
    Parse::Lex->exclusive('parse');
    $lexer = Parse::Lex->new(@token);
    $lexer->from($fh);
    $lexer->every( sub {});   
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
