#!/usr/bin/env bash

set -xeuo pipefail

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1265295
echo 'Storage=persistent' >> /etc/systemd/journald.conf

# Work around https://github.com/systemd/systemd/issues/4082
find /usr/lib/systemd/system/ -type f -exec sed -i -e '/^PrivateTmp=/d' -e '/^Protect\(Home\|System\)=/d' {} \;

# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
KEEPLANG=en_US
find /usr/share/locale -mindepth  1 -maxdepth 1 -type d -not -name "${KEEPLANG}" -exec rm -rf {} +
localedef --list-archive | grep -a -v ^"${KEEPLANG}" | xargs localedef --delete-from-archive
cp -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive
