use 5.008004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => Lingua::YaTeA::YaTeA,
    VERSION_FROM      => 'lib/Lingua/YaTeA/YaTeA.pm', # finds $VERSION
    PREREQ_PM         => { Parse::Lex => 0,
		           Getopt::Long => 0,
			   File::Compare => 0,
                           Data::Dumper => 0, 
                           Pod::Usage => 0,
                           Config::General => 2.30
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lingua/YaTeA/YaTeA.pm', # retrieve abstract from module
       AUTHOR         => 'Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>') : ()),
    EXE_FILES    => [ 'bin/yatea'],
#     UNINSTALL => '$(PERLRUN) -MExtUtils::Install -e \'uninstall({@ARGV});\'',
    
);

sub MY::postamble {
    return <<'MAKE_FRAG';
config :: config_$(INSTALLDIRS)

lib/Lingua/YaTeA/Config.pm.orig : 
	  cp lib/Lingua/YaTeA/Config.pm lib/Lingua/YaTeA/Config.pm.orig 

config_site :: lib/Lingua/YaTeA/Config.pm.orig
	ABSPWD_PREFIX=`$(PERLRUN) -M"Cwd 'abs_path'" -e 'print abs_path('\''$(SITEPREFIX)'\'');'` ; \
	cat lib/Lingua/YaTeA/Config.pm.orig | sed "s|@ROOT@|$$ABSPWD_PREFIX|" > lib/Lingua/YaTeA/Config.pm

config_perl :: lib/Lingua/YaTeA/Config.pm.orig
	ABSPWD_PREFIX=`$(PERLRUN) -M"Cwd 'abs_path'" -e 'print abs_path('\''$(PERLPREFIX)'\'');'` ; \
	cat lib/Lingua/YaTeA/Config.pm.orig | sed "s|@ROOT@|$$ABSPWD_PREFIX|" > lib/Lingua/YaTeA/Config.pm

config_vendor :: 
	ABSPWD_PREFIX=`$(PERLRUN) -M"Cwd 'abs_path'" -e 'print abs_path('\''$(VENDORPREFIX)'\'');'` ; \
	cat lib/Lingua/YaTeA/Config.pm.orig | sed "s|@ROOT@|$$ABSPWD_PREFIX|" > lib/Lingua/YaTeA/Config.pm

install :: 
	$(CP) -a share $(PREFIX)
	$(NOECHO) if [ -z "$(DESTDIR)" ] ; then \
	    if [ "$(PREFIX)" == "/usr" -o "$(PREFIX)" == "/usr/local" ] ; then \
	        $(ECHO) "Coping etc/yatea in /etc" ;\
		$(CP) -a etc/yatea /etc ; \
	    else \
	        $(ECHO) "Coping etc/yatea in $(PREFIX)/etc" ;\
		$(CP) -a etc/yatea $(PREFIX)/etc ; \
	    fi \
	else \
	    $(ECHO) "Coping etc/yatea in $(DESTDIR)/etc" ;\
	    $(CP) -a etc/yatea $(DESTDIR)/etc ; \
	fi

clean ::
	-$(MV) lib/Lingua/YaTeA/Config.pm.orig lib/Lingua/YaTeA/Config.pm $(DEV_NULL)

MAKE_FRAG
}


