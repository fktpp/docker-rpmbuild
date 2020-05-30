#!/bin/bash
# Copyright 2015-2016 jitakirin
# Copyright 2020 fktpp
#
# This file is part of docker-rpmbuild.
#
# docker-rpmbuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# docker-rpmbuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with docker-rpmbuild.  If not, see <http://www.gnu.org/licenses/>.
if [[ ! -z ${VERBOSE} ]]; then
  set -x
fi

set -e

BUILD=true
if [[ $1 == --sh ]]; then
  BUILD=false
  shift
fi

SPEC=$1
if [[ -z ${SPEC} ]]; then
  echo "Usage: docker run [--rm]" \
    "--volume=/path/to/source:/root/rpmbuild" \
    "rpmbuild [--sh] SPECFILE" >&2
  exit 2
fi

if [[ ! -e /root/rpmbuild/SPECS/${SPEC} ]]; then
  cat <<EOF >&2
SPECFILE ${SPEC} not found!!!

Please make sure
1. SPECFILE resides in SOURCE directory
2. SOURCE directory mapped correctly
3. append :z to --volume=/path/to/source:/root/rpmbuild if you have SELINUX activated
EOF
  exit 3
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash ${VERBOSE:+-x} -c ${PRE_BUILDDEP}
fi

# install build dependencies declared in the specfile
if [[ -n ${BUILDDEP} ]]; then
  yum-builddep -y /root/rpmbuild/SPECS/${SPEC}
fi

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec ${SHELL:-/bin/bash} -l
fi

rpmbuild ${VERBOSE:+-v} -bb --clean /root/rpmbuild/SPECS/${SPEC}
