%define _prefix_path opt/axsh
%define _tiny_web_example_git_uri git://github.com/axsh/tiny_web_example.git
%define oname tiny-web-example

%define release_id 1.daily
%{?build_id:%define release_id %{build_id}}
%{?repo_uri:%define _tiny_web_example_git_uri %{repo_uri}}

Summary: Tiny Web Example.
Name: %{oname}
Version: 0.0.1
Release: %{release_id}%{?dist}
License: see https://github.com/axsh/tiny_web_example/blob/master/README.md
Group: Development/Languages
URL: http://example.jp/
Source0: %{_vdc_git_uri}
Prefix: /%{_prefix_path}

BuildRequires: mysql-devel

Requires: nginx
Requires: mysql-server


%description
Tiny Web Example

%prep
[ -d %{name}-%{version} ] && rm -rf [ -d %{name}-%{version} ]
git clone %{_tiny_web_example_git_uri} %{name}-%{version}
cd %{name}-%{version}
[ -z "%{build_id}" ] || {
  build_id=%{build_id}
  git checkout ${build_id##*git}
  unset build_id
} && :

%setup -T -D

%build
RUBYDIR=/usr/bin/ruby rpmbuild/rules build

%install
[ -d ${RPM_BUILD_ROOT} ] && rm -rf ${RPM_BUILD_ROOT}
mkdir -p ${RPM_BUILD_ROOT}/%{prefix}/%{oname}

components="
  frontend
  webapi
"
for component in ${components}; do
  rsync -aHA --exclude=".git/*" --exclude="*~" --exclude="*/cache/*.gem" --exclude="*/cache/bundler/git/*" `pwd`/${component} ${RPM_BUILD_ROOT}/%{prefix}/%{oname}/
done
unset components

[ -d ${RPM_BUILD_ROOT}/etc ] || mkdir -p ${RPM_BUILD_ROOT}/etc
rsync -aHA `pwd`/contrib/etc/default  ${RPM_BUILD_ROOT}/etc
rsync -aHA `pwd`/contrib/etc/init     ${RPM_BUILD_ROOT}/etc
rsync -aHA `pwd`/contrib/etc/%{oname} ${RPM_BUILD_ROOT}/etc

mkdir -p ${RPM_BUILD_ROOT}/var/log/%{oname}

%clean
RUBYDIR=/usr/bin/ruby rpmbuild/rules clean
rm -rf $RPM_BUILD_ROOT

%post
/sbin/chkconfig mysqld on

%files
%defattr(-,root,root,-)
%{prefix}/%{oname}
%dir /etc/%{oname}
%dir /var/log/%{oname}
%config(noreplace) /etc/default/tiny-web-example-webapi
%config(noreplace) /etc/default/tiny-web-example-webapp
%config(noreplace) /etc/init/tiny-web-example-webapi.conf
%config(noreplace) /etc/init/tiny-web-example-webapp.conf
%config(noreplace) /etc/tiny-web-example/unicorn-common.conf
%config(noreplace) /etc/tiny-web-example/webapi.conf
%config(noreplace) /etc/tiny-web-example/webapp.yml
