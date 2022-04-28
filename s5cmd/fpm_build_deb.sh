#!/bin/bash
NAME=s5cmd
VERSION=1.4.0
RELEASE=1
ARCH="x86_64"
PACKAGENAME="${NAME}-${VERSION}-${RELEASE}.deb"
PACKAGENAME="${NAME}"
INPUT=${NAME}_${VERSION}_Linux-64bit.tar.gz
URL="https://github.com/peak/s5cmd/releases/download/v${VERSION}/"
SUMMARY="s5cmd is a very fast S3 and local filesystem execution tool."
PREFIX=/opt/sddc
BINDIR=${PREFIX}/bin
SBINDIR=${PREFIX}/sbin
MAINTAINER="Private FPM project"
LICENSE="MIT"
VENDOR="Private FPM Project"
AUTHOR="Elia Pinto <pinto.elia@gmail.com>"
DEFATTRFILE=755
##########
trap 'rm -rf ${TMPDIR} ${TMPFILE_CHANGELOG}' EXIT
tempdir() {
    tempprefix=${0##*/}
    mktemp -d /tmp/${tempprefix}.XXXXXX
}
tempfile_changelog() {
    local tempprefix="${0##*/}"
    mktemp  /tmp/"${tempprefix}".XXXXXX
}
TMPDIR="$(tempdir)"
TMPFILE_CHANGELOG="$(tempfile_changelog)"
cat <<EOF>"$TMPFILE_CHANGELOG"
* $(LANG=C date "+%a %b %d %Y") ${AUTHOR} - ${VERSION}-${RELEASE}
- First Release. 
EOF
tar -C $TMPDIR -zxf $INPUT
rm -f "${PACKAGENAME}"*.deb
fpm -s dir -t deb  -n ${NAME} -v ${VERSION} --iteration ${RELEASE} -a ${ARCH} -m "${MAINTAINER}" --rpm-summary "${SUMMARY}" --deb-changelog "$TMPFILE_CHANGELOG" --description "${SUMMARY}" --rpm-defattrfile "$DEFATTRFILE" --url "${URL}" --vendor "$VENDOR" --license "$LICENSE" -C $TMPDIR s5cmd=${BINDIR}/${NAME}
