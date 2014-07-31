#!/bin/bash
# Copyright (C) 2014 Colin Walters <walters@verbum.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

set -e
set -x

taskdir=$(mktemp -d)

. $(dirname $0)/config.sh

origrev=$(ostree --repo=${OSTREE_REPO} rev-parse ${REF} 2>/dev/null || true)
rpm-ostree compose tree --repo=${OSTREE_REPO} --cachedir=${RPMOSTREE_CACHEDIR} ${SRCDIR}/${OSNAME}-${TREENAME}.json
newrev=$(ostree --repo=${OSTREE_REPO} rev-parse ${REF})
if test x${origrev} != ${newrev}; then
    echo "${REF} => ${newrev}"
    $(dirname $0)/create-disks.sh
else
    echo "${REF} is unchanged at ${origrev}"
fi

