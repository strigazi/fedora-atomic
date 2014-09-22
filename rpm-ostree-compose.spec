Summary: Compose an ostree, from rpms, and make images from it
Name: rpm-ostree-compose
Version: 0.1
Release: 1
License: LGPLv2+
URL: https://fedorahosted.org/fedora-atomic/
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Requires: rpm-ostree
Requires: ostree

Requires: lorax >= 21.21-0

Requires: imagefactory
Requires: imagefactory-plugins-TinMan

BuildArch: noarch

# ??
# Requires: squid 

%description
This tool will use rpm-ostree to compose an ostree for a list of rpms against a
specified set of repos. and will then create installable ISOs and cloud VM
images from that.

%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/%{_sbindir}
cp -a compose/treecompose $RPM_BUILD_ROOT/%{_sbindir}/rpm-ostree-compose

%define roc_srcdir %{_prefix}/share/rpm-ostree-compose/src
mkdir -p $RPM_BUILD_ROOT/%{roc_srcdir}
cp -a \
 fedora-atomic-base.json \
 fedora-atomic-docker-host.json \
 fedora-rawhide-cloud-atomic.ks \
 fedora-rawhide.repo \
 fedora-rawhide.tdl \
 fedora-rawhide-vagrant-atomic.ks \
 lorax-embed-repo.tmpl \
 $RPM_BUILD_ROOT/%{roc_srcdir}

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc TODO.md
%{_sbindir}/rpm-ostree-compose
%{roc_srcdir}

%changelog
* Fri Sep 19 2014 James Antill <james@and.org> - 0.1-0
- Initial build.

