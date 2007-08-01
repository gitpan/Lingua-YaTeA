use 5.008004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => Lingua::YaTeA,
    VERSION_FROM      => 'lib/Lingua/YaTeA.pm', # finds $VERSION
    PREREQ_PM         => { Parse::Yapp => 0,
		           Getopt::Long => 0,
			   File::Compare => 0,
                           Data::Dumper => 0, 
                           Pod::Usage => 0,
                           Config::General => 2.30
                         }, # e.g., Module::Name => 1.1
    LICENSE           => "gpl",
    INSTALLDIRS     => 'perl',
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lingua/YaTeA.pm', # retrieve abstract from module
       AUTHOR         => 'Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>') : ()),
    EXE_FILES    => [ 'bin/yatea'],
#     UNINSTALL => '$(PERLRUN) -MExtUtils::Install -e \'uninstall({@ARGV});\'',
    
);

sub MY::postamble {
    return <<'MAKE_FRAG';

install :: 
	$(CP) -a share $(PREFIX)
	$(NOECHO) if [ -z "$(DESTDIR)" ] ; then \
	    if [ "$(PREFIX)" == "/usr" -o "$(PREFIX)" == "/usr/local" ] ; then \
	        $(ECHO) "Coping etc/yatea in /etc" ;\
                $(MKPATH) /etc/yatea ; \
		$(CP) -a etc/yatea/* /etc/yatea ; \
	    else \
	        $(ECHO) "Coping etc/yatea in $(PREFIX)/etc" ;\
                $(MKPATH) $(PREFIX)/etc/yatea ; \
		$(CP) -a etc/yatea/* $(PREFIX)/etc/yatea ; \
                $(ECHO) "Please set the variables CONFIG_REP and LOCALE_REP in $(PREFIX)/etc/yatea/yatea.rc to $(PREFIX)/share/..." ;\
	    fi \
	else \
	    $(ECHO) "Coping etc/yatea in $(DESTDIR)/etc" ;\
            $(MKPATH) $(DESTDIR)/etc/yatea ; \
	    $(CP) -a etc/yatea/* $(DESTDIR)/etc/yatea ; \
            $(ECHO) "Please set the variables CONFIG_REP and LOCALE_REP in $(DESTDIR)/etc/yatea/yatea.rc to $(DESTDIR)/share/..." ;\
	fi

MAKE_FRAG
}


