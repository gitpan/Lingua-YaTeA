package Lingua::YaTeA::ForbiddenStructureAny;
use Lingua::YaTeA::ForbiddenStructure;
use strict;

our @ISA = qw(Lingua::YaTeA::ForbiddenStructure);

sub new
{
    my ($class,$infos_a) = @_;
    my ($form,$reg_exp) = $class->parse($infos_a->[0]);
    my $this = $class->SUPER::new($form);
    bless ($this,$class);
    $this->{ACTION} = $infos_a->[2];
    $this->{SPLIT_AFTER} = $this->setSplitAfter($infos_a);
    $this->{REG_EXP} = $reg_exp;
    return $this;
}



sub setSplitAfter
{
    my ($this,$infos_a) = @_;
    if ($this->{ACTION} eq "split")
    {
	return $infos_a->[3];
    }
    return "";
}

sub parse
{
    my ($class,$string) = @_;
    my @elements = split / /, $string;
    my $element;
    my $forbidden_tag = "\(\\n\\<\\/\?\(FORBIDDEN\|FRONTIER\)\[\^\>\]\+\>\)\*";
    my $reg_exp = "";
    my $form;
    
    foreach $element (@elements){
	$element =~ /^([^\\]+)\\(.+)$/;
	if ($2 eq "IF"){
	    $reg_exp .= $forbidden_tag . "\?\\n" . quotemeta($1)."\\t\[\^\\t\]\+\\t\[\^\\t\]\+" . $forbidden_tag;
	}
	else{
	    if ($2 eq "POS"){
		$reg_exp .= $forbidden_tag . "\?\\n\[\^\\t\]\+\\t" . quotemeta($1)."\\t\[\^\\t\]\+". $forbidden_tag;
	    }
	    else{
		if ($2 eq "LF"){
		    $reg_exp .= $forbidden_tag . "\?\\n\[\^\\t\]\+\\t\[\^\\t\]\+\\t".quotemeta($1). $forbidden_tag;
		}
	    }
	}
	$form .= $1 . " ";
    }
    $reg_exp .= "\\n";
    $form =~ s/ $//;
    return ($form,$reg_exp);
}

sub getAction
{
    my ($this) = @_;
    return $this->{ACTION};
}

sub getRegExp
{
    my ($this) = @_;
    return $this->{REG_EXP};
}

sub getSplitAfter
{
    my ($this) = @_;
    return $this->{SPLIT_AFTER};
}


1;
