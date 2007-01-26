package Lingua::YaTeA::OptionSet;
use strict;

use Data::Dumper;



sub new
{
    my ($class) = @_;
    my %default = ("suffix"=>"default");
    my $this = {};
    bless ($this,$class);
    $this->{OPTIONS} = ();
    $this->addOptionSet(\%default);
    return $this;
}


sub addOptionSet
{
    my ($this,$options_set_h,$message_set,$display_language) = @_;
    my $name;
    my $val;
    while (my ($opt,$val) = each (%$options_set_h))
    {
	$this->addOption($opt,$val,$message_set,$display_language);
    }
}

sub addOption
{
    my ($this,$name,$value,$message_set,$display_language) = @_;
    if(! $this->optionExists($name))
    {
	$this->{OPTIONS}->{$name} = Lingua::YaTeA::Option->new($name,$value);
    }
    else
    {
	$this->getOption($name)->update($value,$message_set,$display_language);
    }

}


sub checkCompulsory
{
    my ($this,$comp_list) = @_;
    my @compulsory_options = split (",",$comp_list);
    my $compulsory;
    foreach $compulsory (@compulsory_options)
    {
	if(!defined $this->optionExists($compulsory))
	{	
	    die "You must define option \"" .$compulsory . "\"\n";
	}
    }
}

sub optionExists
{
    my ($this,$name) = @_;
    my $option;
    # foreach $option (@{$this->{OPTIONS}})
#     {
# 	if($option->getName eq $name)
# 	{
# 	    return $option;
# 	}
#     }
    if(defined $this->{OPTIONS}->{$name})
    {
	return $this->{OPTIONS}->{$name};
    }
    return;
}

sub getOption
{
    my ($this,$name) = @_;
    
    if(! return $this->optionExists($name))
    {
	die "Option ". $name . " not defined\n";
    }
}

sub getOptions
{
    my ($this) = @_;
    return $this->{OPTIONS};
}


sub getLanguage
{
    my ($this,$name) = @_;
    return $this->getOption("language")->getValue;
}

sub getChainedLinks
{
    my ($this) = @_;
    if(defined $this->getOption("chained-links"))
    {
	return  1;
    }
    return 0;
}

sub getSentenceBoundary
{
   my ($this,$name) = @_;
   return $this->getOption("SENTENCE_BOUNDARY")->getValue;
}

sub getDocumentBoundary
{
   my ($this,$name) = @_;
   return $this->getOption("DOCUMENT_BOUNDARY")->getValue;
}

sub getParsingDirection
{
   my ($this,$name) = @_;
   return $this->getOption("PARSING_DIRECTION")->getValue;
}

sub MatchTypeValue
{
   my ($this,$name) = @_;
   if ((defined $this->getOption("match-type")) && ($this->getOption("match-type")->getValue() ne "")) {
       return $this->getOption("match-type")->getValue;
   }
   return 0;
}

sub readFromFile
{
    my ($this,$file) = @_;
    my $conf = Config::General->new($file->getPath);
    $this->addOptionSet($conf->{'DefaultConfig'});
    $this->checkMaxLength;
    $conf = undef;
}

sub checkMaxLength
{
    my ($this) = @_;
    if(!$this->optionExists('PHRASE_MAXIMUM_LENGTH'))
    {
	$this->addOption('PHRASE_MAXIMUM_LENGTH',12);
    }
}

sub getMaxLength
{
    my ($this,$name) = @_;
    return $this->getOption("PHRASE_MAXIMUM_LENGTH")->getValue;

}

sub getCompulsory
{
    my ($this,$name) = @_;
    return $this->getOption("COMPULSORY_ITEM")->getValue;

}

sub getSuffix
{
    my ($this,$name) = @_;
    return $this->getOption("suffix")->getValue;

}

sub getDisplayLanguage
{
    my ($this) = @_;
    return $this->getOption("MESSAGE_DISPLAY")->getValue;
}

sub getDefaultOutput
{
    my ($this) = @_;
    return $this->getOption("default_output")->getValue;
}

sub setMatchType
{
    my ($this,$match_type) = @_;
    
    $this->addOption('match-type',$match_type);
}

sub getTermListStyle
{
    my ($this) = @_;
    return $this->getOption("termList")->getValue;
}

sub getTTGStyle
{
    my ($this) = @_;
    return $this->getOption("TTG-style-term-candidates")->getValue;
}

sub getOutputPath
{
    my ($this) = @_;
    return $this->getOption("output-path")->getValue;
}

sub setDefaultOutputPath
{
    my ($this) = @_;
    if(!defined $this->getOption("output-path"))
    {
	$this->addOption("output-path",".");
    }
}

sub disable
{
    my ($this,$option_name,$message_set,$display_language) = @_;
    
    if($this->optionExists($option_name))
    {
	delete($this->{OPTIONS}->{$option_name});
    }
    print STDERR "WARNING: " . $message_set->getMessage('DISABLE_OPTION')->getContent($display_language) . $option_name ." \n";
}

sub enable
{
    my ($this,$option_name,$option_value,$message_set,$display_language) = @_;
    
    if(! $this->optionExists($option_name))
    {
	$this->addOption($option_name,$option_value,$message_set,$display_language);
	print STDERR "WARNING: \"" . $option_name ."\"" . $message_set->getMessage('ENABLE_OPTION')->getContent($display_language);
	if(defined $option_value)
	{
	    print STDERR  "." . $message_set->getMessage('OPTION_VALUE')->getContent($display_language) . "\"". $this->getOption($option_name)->getValue . "\"";
	}
	print STDERR "\n";
    }
   
}


sub handleOptionDependencies
{
    my ($this,$message_set) = @_;
    my %incompatibilities = ('annotate-only' => ["TC-for-BioLG", "debug"]);
    my %necessarily_linked = ('TT-for-BioLG' => ["termino", "match-type:strict"]);
    my $incompatible_option;
    my $necessary_option;
    my @necessary_option;
    my $option;
    my $value;
    


    foreach $option (keys %incompatibilities)
    {
	if ($this->optionExists($option))
	{
	    foreach $incompatible_option (@{$incompatibilities{$option}})
	    {
		if($this->optionExists($incompatible_option))
		{
		    print STDERR "WARNING: \"" . $incompatible_option  . "\" & \"" . $option . "\"" .  $message_set->getMessage('INCOMPATIBLE_OPTIONS')->getContent($this->getDisplayLanguage) . " \n";
		    $this->disable($option,$message_set,$this->getDisplayLanguage);
		    last;
		}
	    }
	}
    }

    foreach $option (keys %necessarily_linked)
    {
	if (($this->optionExists($option)) && ($this->getOption('TT-for-BioLG')->getValue() == 1))
	{
	    foreach $necessary_option (@{$necessarily_linked{$option}})
	    {
		@necessary_option = split (/:/,$necessary_option);
		if(!$this->optionExists($necessary_option[0]))
		{
		    if($necessary_option[0] eq "termino")
		    {
			print STDERR $option . ": " . $message_set->getMessage('TERMINO_NEEDED')->getContent($this->getDisplayLanguage) . " \n";
			die "\n";
		    }
		    else
		    {
			$this->enable($necessary_option[0],$necessary_option[1],$message_set,$this->getDisplayLanguage);
		    }
		}
		else
		{
		    if(defined $necessary_option[1])
		    {
			if($this->getOption($necessary_option[0])->getValue ne $necessary_option[1])
			{
			    $this->getOption($necessary_option[0])->update($necessary_option[1],$message_set,$this->getDisplayLanguage);
			}
		    }
		}
	    }
	}
    }

}

1;
