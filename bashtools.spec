#Specfile for bashtools

#Inofficial rpm build for opensue 11.0

###############################################################
#Some Words about opensuse 11.0 unofficial                    #
#This is an unofficial build. The opensuse team is neither    #
#responsible nor supports this rpm package. However i allways #
#try to make packages working as mentioned in the opensuse    #
#guidelines.                                                  #
###############################################################

%define _prefix /usr/local/bin
%define _mandir /usr/share/man
%define _docdir /usr/share/doc/packages

Summary: 	a bunch of usefull scripts that makes life with bash easier
Name: 		bashtools
Version: 	0.4.4
Release: 	MP3
License: 	GPL 
Group: 		System/Console
Source: 	%name-%{version}.tar.gz
BuildArch:	noarch
BuildRoot:	%{_tmppath}/build-%{name}-%{version}
Provides:	backupdir bashtools broken-links  clearlogs  clearswap  lockit  
Provides:	logusers  pinger  rescale  rpm-check  unpackrpm  wipefree  zipmore
Requires: 	bash
URL: 		http://propstmatthias.pblaced.net/pub/bashtools
Vendor: 	opensuse 11.0 unofficial
Packager: 	Matthias Propst <penguinuser(at)web.de>
Prefix:		%{_prefix}

%description
Bashtools is a very small project.
The idea originaly was collecting and writing cool shellscripts to improve the work 
with several system tools and extending the functionality of bash.  It was written on 
a openSUSE 10.3 system and therefore most scripts will only run on openSUSE >= 10.3. 

%changelog
* Tue Mar 31 2009 Matthias Propst 0.4.4-MP3
- build newest Version
- changed Distribution to Vendor opensuse 11.0 unofficial
- clean up the specfile and make it more suse-alike

* Mon Jun 09 2008 Matthias Propst 0.2.2-MP2
- inital build release for opensuse 10.3

%prep
%setup -q

%build
#nothing todo here

%install
mkdir -p %{buildroot}%{_prefix}
%__mv Scripts/* %{buildroot}%{_prefix}/
mkdir -p %{buildroot}%{_mandir}/man1
%__mv DOCS/man/bashtools.1.gz %{buildroot}%{_mandir}/man1/
mkdir -p %{buildroot}%{_docdir}/%{name}
%__mv DOCS/Changelog DOCS/README  DOCS/TODO %{buildroot}%{_docdir}/%{name}/



%files
%defattr(-,root,root)
/usr/local/bin/backupdir
/usr/local/bin/bashtools
/usr/local/bin/broken-links
/usr/local/bin/clearlogs
/usr/local/bin/clearswap
/usr/local/bin/lockit
/usr/local/bin/logusers
/usr/local/bin/pinger
/usr/local/bin/rescale
/usr/local/bin/rpm-check
/usr/local/bin/unpackrpm
/usr/local/bin/wipefree
/usr/local/bin/zipmore
%{_mandir}/man1/bashtools.1.gz
%{_docdir}/%{name}/


%clean
rm -rf $RPM_BUILD_ROOT



