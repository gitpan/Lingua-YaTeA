use Module::Build;

# my $class = Module::Build->subclass(code => <<'EOF');
# sub process_dat_files {
#     my $self = shift;
#     ... locate and process *.dat files,
#     ... and create something in blib/lib/
#     }
# EOF
 
my $class = Module::Build->subclass(
				    class => "Module::Build::Custom",
code => <<'SUBCLASS' );

sub ACTION_install {
    my $self = shift;
    $self->SUPER::ACTION_install;
    warn "\nDon't forget to set the variables CONFIG_REP and LOCALE_REP in the configuration file yatea.rc to the right path if necessary.\n\n";
}
SUBCLASS

my $build = $class->new
    (
     module_name => 'Lingua::YaTeA',
     dist_version_from => 'lib/Lingua/YaTeA.pm',
     license => 'gpl',
     requires => {'perl' => '5.005',
		  Parse::Yapp => 0,
		  Getopt::Long => 0,
		  File::Compare => 0,
		  Data::Dumper => 0, 
		  Pod::Usage => 0,
		  Config::General => 2.
		  },

#      $build->add_build_element('dat');
#      $build->create_build_script;


     installdirs => 'core',
     conf_files => {'etc/yatea/yatea.rc' => 'conf/yatea/yatea.rc'},
     share_files => {'share/doc/YaTeA/affichage.fig' => 'share/doc/YaTeA/affichage.fig',
		     'share/doc/YaTeA/alvis.sty' => 'share/doc/YaTeA/alvis.sty',
		     'share/doc/YaTeA/analyseDefinis.fig' => 'share/doc/YaTeA/analyseDefinis.fig',
		     'share/doc/YaTeA/AnalyseProgressive.fig' => 'share/doc/YaTeA/AnalyseProgressive.fig',
		     'share/doc/YaTeA/analyseSSDefinis.fig' => 'share/doc/YaTeA/analyseSSDefinis.fig',
		     'share/doc/YaTeA/ArchitectureDescrYatea.tex' => 'share/doc/YaTeA/ArchitectureDescrYatea.tex',
		     'share/doc/YaTeA/chargementPatrons.fig' => 'share/doc/YaTeA/chargementPatrons.fig',
		     'share/doc/YaTeA/chargementTAtt.fig' => 'share/doc/YaTeA/chargementTAtt.fig',
		     'share/doc/YaTeA/ChercheIlots.fig' => 'share/doc/YaTeA/ChercheIlots.fig',
		     'share/doc/YaTeA/ct.fig' => 'share/doc/YaTeA/ct.fig',
		     'share/doc/YaTeA/DataDescrYatea.tex' => 'share/doc/YaTeA/DataDescrYatea.tex',
		     'share/doc/YaTeA/decoupage.fig' => 'share/doc/YaTeA/decoupage.fig',
		     'share/doc/YaTeA/DTD/yatea.dtd' => 'share/doc/YaTeA/DTD/yatea.dtd',
		     'share/doc/YaTeA/endogenous.fig' => 'share/doc/YaTeA/endogenous.fig',
		     'share/doc/YaTeA/entreeLex.fig' => 'share/doc/YaTeA/entreeLex.fig',
		     'share/doc/YaTeA/exogenous.fig' => 'share/doc/YaTeA/exogenous.fig',
		     'share/doc/YaTeA/foret.fig' => 'share/doc/YaTeA/foret.fig',
		     'share/doc/YaTeA/FuntionDescrYatea.tex' => 'share/doc/YaTeA/FuntionDescrYatea.tex',
		     'share/doc/YaTeA/generalExtracteur.fig' => 'share/doc/YaTeA/generalExtracteur.fig',
		     'share/doc/YaTeA/gnms.fig' => 'share/doc/YaTeA/gnms.fig',
		     'share/doc/YaTeA/ilot.fig' => 'share/doc/YaTeA/ilot.fig',
		     'share/doc/YaTeA/Makefile.in' => 'share/doc/YaTeA/Makefile.in',
		     'share/doc/YaTeA/pat_decomp.fig' => 'share/doc/YaTeA/pat_decomp.fig',
		     'share/doc/YaTeA/PlaceInsert.fig' => 'share/doc/YaTeA/PlaceInsert.fig',
		     'share/doc/YaTeA/samples/pmid10788508-v2.genia2.xml' => 'share/doc/YaTeA/samples/pmid10788508-v2.genia2.xml',
		     'share/doc/YaTeA/SatureEtMAJ.fig' => 'share/doc/YaTeA/SatureEtMAJ.fig',
		     'share/doc/YaTeA/TAtt.fig' => 'share/doc/YaTeA/TAtt.fig',
		     'share/doc/YaTeA/TechnicalDocYatea.bbl' => 'share/doc/YaTeA/TechnicalDocYatea.bbl',
		     'share/doc/YaTeA/TechnicalDocYatea.tex' => 'share/doc/YaTeA/TechnicalDocYatea.tex',
		     'share/doc/YaTeA/transfig.tex' => 'share/doc/YaTeA/transfig.tex',
		     'share/doc/YaTeA/UserManualForTechDoc.tex' => 'share/doc/YaTeA/UserManualForTechDoc.tex',
		     'share/doc/YaTeA/Yatea_Classes_Config.fig' => 'share/doc/YaTeA/Yatea_Classes_Config.fig',
		     'share/doc/YaTeA/Yatea_Classes_Process.fig' => 'share/doc/YaTeA/Yatea_Classes_Process.fig',
		     'share/doc/YaTeA/Yatea_user_manual.tex' => 'share/doc/YaTeA/Yatea_user_manual.tex',
		     'share/YaTeA/config/EN/ChunkingExceptions' => 'share/YaTeA/config/EN/ChunkingExceptions',
		     'share/YaTeA/config/EN/ChunkingFrontiers' => 'share/YaTeA/config/EN/ChunkingFrontiers',
		     'share/YaTeA/config/EN/CleaningExceptions' => 'share/YaTeA/config/EN/CleaningExceptions',
		     'share/YaTeA/config/EN/CleaningFrontiers' => 'share/YaTeA/config/EN/CleaningFrontiers',
		     'share/YaTeA/config/EN/ForbiddenStructures' => 'share/YaTeA/config/EN/ForbiddenStructures',
		     'share/YaTeA/config/EN/LGPmapping' => 'share/YaTeA/config/EN/LGPmapping',
		     'share/YaTeA/config/EN/LinguisticConfiguration' => 'share/YaTeA/config/EN/LinguisticConfiguration',
		     'share/YaTeA/config/EN/Options' => 'share/YaTeA/config/EN/Options',
		     'share/YaTeA/config/EN/ParsingPatterns' => 'share/YaTeA/config/EN/ParsingPatterns',
		     'share/YaTeA/config/EN/TagSet' => 'share/YaTeA/config/EN/TagSet',
		     'share/YaTeA/config/FR/ChunkingExceptions' => 'share/YaTeA/config/FR/ChunkingExceptions',
		     'share/YaTeA/config/FR/ChunkingFrontiers' => 'share/YaTeA/config/FR/ChunkingFrontiers',
		     'share/YaTeA/config/FR/CleaningExceptions' => 'share/YaTeA/config/FR/CleaningExceptions',
		     'share/YaTeA/config/FR/CleaningFrontiers' => 'share/YaTeA/config/FR/CleaningFrontiers',
		     'share/YaTeA/config/FR/CoordPatterns' => 'share/YaTeA/config/FR/CoordPatterns',
		     'share/YaTeA/config/FR/ForbiddenStructures' => 'share/YaTeA/config/FR/ForbiddenStructures',
		     'share/YaTeA/config/FR/LinguisticConfiguration' => 'share/YaTeA/config/FR/LinguisticConfiguration',
		     'share/YaTeA/config/FR/mapping.TT2Lexter' => 'share/YaTeA/config/FR/mapping.TT2Lexter',
		     'share/YaTeA/config/FR/Options' => 'share/YaTeA/config/FR/Options',
		     'share/YaTeA/config/FR/ParsingPatterns' => 'share/YaTeA/config/FR/ParsingPatterns',
		     'share/YaTeA/config/FR/TagSet' => 'share/YaTeA/config/FR/TagSet',
		     'share/YaTeA/locale/EN/Messages' => 'share/YaTeA/locale/EN/Messages',
		     'share/YaTeA/locale/FR/Messages' => 'share/YaTeA/locale/FR/Messages',
		     'share/YaTeA/samples/bootstrap.testified' => 'share/YaTeA/samples/bootstrap.testified',
		     'share/YaTeA/samples/corpus.ttg' => 'share/YaTeA/samples/corpus.ttg',
		     'share/YaTeA/samples/environment_EN.TT' => 'share/YaTeA/samples/environment_EN.TT',
		     'share/YaTeA/samples/pmid10788508-v2.1l' => 'share/YaTeA/samples/pmid10788508-v2.1l',
		     'share/YaTeA/samples/pmid10788508-v2.TT' => 'share/YaTeA/samples/pmid10788508-v2.TT',
		     'share/YaTeA/samples/sampleEN.ttg' => 'share/YaTeA/samples/sampleEN.ttg',
		     'share/YaTeA/samples/termes_environnement.ttg' => 'share/YaTeA/samples/termes_environnement.ttg',
		     'share/YaTeA/samples/termes_environnement.txt' => 'share/YaTeA/samples/termes_environnement.txt',
		     'share/YaTeA/samples/termlist' => 'share/YaTeA/samples/termlist',
		     'share/YaTeA/samples/termlist.TT' => 'share/YaTeA/samples/termlist.TT',
		     'share/YaTeA/samples/termsEnvironment.ttg' => 'share/YaTeA/samples/termsEnvironment.ttg',
		     'share/YaTeA/samples/termsEnvironment.txt' => 'share/YaTeA/samples/termsEnvironment.txt',
		     'share/YaTeA/samples/termsPhB.termsgt' => 'share/YaTeA/samples/termsPhB.termsgt',
		     'share/YaTeA/samples/transcript-epure-Genia.bootstrap' => 'share/YaTeA/samples/transcript-epure-Genia.bootstrap',
		     'share/YaTeA/yatea.conf' => 'share/YaTeA/yatea.conf',
		 },
     );

$build->install_base_relpaths( conf => 'etc' );
$build->prefix_relpaths('site', conf => 'etc' );
$build->prefix_relpaths('core', conf => 'etc' );
$build->prefix_relpaths('vendor', conf => 'etc' );
$build->add_build_element('conf');

$build->install_base_relpaths( share => 'share' );
$build->prefix_relpaths('site', share => 'share' );
$build->prefix_relpaths('core', share => 'share' );
$build->prefix_relpaths('vendor', share => 'share' );
$build->add_build_element('share');

$build->create_build_script;

