#!/bin/bash
set -eo pipefail
################
NAME=awscli
MAJORVERSION=2
MINORVERSION=3.1
VERSION="${MAJORVERSION}.${MINORVERSION}"
RELEASE=1
ARCH="noarch"
DISTTAG="el8"
PACKAGENAME="${NAME}"
VENDOR="Private FPM project"
AUTHOR="Elia Pinto <pinto.elia@gmail.com>"
LICENSE="ASL 2.0 and MIT"
################
INPUT="${NAME}v${MAJORVERSION}.zip"
URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
################
# XXXX
# No automatic curl download here
# curl "$URL" -o "$INPUT"
################
#
SUMMARY="The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell. "
PREFIX=/opt/sddc
BINDIR=${PREFIX}/bin
AWSDIR=${PREFIX}/aws-cli
MAINTAINER="Private FPM project"
##########
trap '/usr/bin/rm -rf "$TMPDIR_INSTALL" "$TMPDIR_BUILD" "$TMPFILE_AFTER_INSTALL" "$TMPFILE_AFTER_REMOVE" "$TMPFILE_CHANGELOG"' EXIT ERR
tempdir_install() {
    local tempprefix="${0##*/}"
    mktemp -d /tmp/"${tempprefix}".XXXXXX
}
tempdir_buildir() {
    local tempprefix="${0##*/}"
    mktemp -d /tmp/"${tempprefix}".XXXXXX
}
tempfile_script() {
    local tempprefix="${0##*/}"
    mktemp  /tmp/"${tempprefix}".XXXXXX
}
tempfile_changelog() {
    local tempprefix="${0##*/}"
    mktemp  /tmp/"${tempprefix}".XXXXXX
}
TMPDIR_INSTALL="$(tempdir_install)"
TMPDIR_BUILD="$(tempdir_buildir)"
unzip -d "$TMPDIR_INSTALL" $INPUT
TMPFILE_AFTER_INSTALL="$(tempfile_script)"
TMPFILE_AFTER_REMOVE="$(tempfile_script)"
TMPFILE_CHANGELOG="$(tempfile_changelog)"
cat <<EOF>"$TMPFILE_CHANGELOG"
* $(LANG=C date "+%a %b %d %Y") ${AUTHOR} - ${VERSION}-${RELEASE}
- First Release. 
EOF
cat <<EOF>"$TMPFILE_AFTER_INSTALL"
/bin/ln -s $AWSDIR/v$MAJORVERSION/${VERSION} $AWSDIR/v$MAJORVERSION/current 
/bin/ln -s $AWSDIR/v$MAJORVERSION/current/bin/aws $BINDIR/aws
/bin/ln -s $AWSDIR/v$MAJORVERSION/current/bin/aws_completer $BINDIR/aws_completer
EOF
cat <<EOF>"$TMPFILE_AFTER_REMOVE"
/bin/rm -f $BINDIR/aws
/bin/rm -f $BINDIR/aws_completer
/bin/rm -f $AWSDIR/v$MAJORVERSION/current
EOF
################
# install to 
# BUILDIDR
################
"${TMPDIR_INSTALL}"/aws/install -i "$TMPDIR_BUILD"/${AWSDIR} -b "$TMPDIR_BUILD"/$BINDIR
################
# XXXX 
# fpm doesn't rebuild sym link
################
/usr/bin/rm -f "$TMPDIR_BUILD"/$BINDIR/*
/usr/bin/rm -rf "$TMPDIR_BUILD"/$AWSDIR/v$MAJORVERSION/current


/usr/bin/rm -f "${PACKAGENAME}"*.deb
#
# Add "-e" to fpm for editing SPEC in place
#
fpm -s dir -t deb  -n ${NAME} -v ${VERSION} --iteration ${RELEASE} -a ${ARCH} -m "${MAINTAINER}" --url ${URL} --description "${SUMMARY}" --after-install "$TMPFILE_AFTER_INSTALL" --after-remove "$TMPFILE_AFTER_REMOVE" --vendor "$VENDOR" --license "$LICENSE" --deb-changelog "$TMPFILE_CHANGELOG" -C "$TMPDIR_BUILD"
