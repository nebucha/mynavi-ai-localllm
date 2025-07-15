# Copyright (c) 2007,2009,2010,2011,2013,2019,2021,2024 ONGS Inc.
# All rights reserved.
#
# This software may be used, modified, copied, and distributed, in
# both source and binary form provided that the above copyright and
# these terms are retained. Under no circumstances is the author
# responsible for the proper functioning of this software, nor does
# the author assume any responsibility for damages incurred with its
# use.

# author: Daichi GOTO (daichi@ongs.co.jp)
# first edition: Mon Jul 16 20:27:53 2007

HOST!=		hostname -s

GLSD-DOC2HTML=	glsd2html
GLSD-DOC2TEXT=	glsd2txt
GLSD-DOC2YD=	glsd2mn

MAKE=		make
ECHO=		echo
ECHONL=		echo	-n
BUILDSYSTEM=	ydmklp	${PWD} > /dev/null 2>&1 &

HTMLBROWSER=	mac	open
YDBROWSER=	mac	open
SCREENSHOTBROWSER=mac screenshotbrowser1200x800
TEXTCOPY=	mac	pbcopy
COPYTOSTDERR=	tee	/dev/stderr
MUACOMPOSER=	mac	mail
MAILSIZECHECK=								\
	if	[ ${LIMITSIZEOFMAIL} -lt 				\
			$$(ls -l *tgz | awk '{print $$5}') ];		\
	then								\
		${ECHO} "*** Size is over.";				\
		false;							\
	fi

# Image
IMGEDITOR=	open

# Editor
VSC=		open	-a 'Visual Studio Code'
VIM!=		which	nvim || true
.if ${VIM} == ""
VIM!=		which	vim || true
.endif
.if ${VIM} == ""
VIM=		vi
.endif
XMLEDITOR=	${VIM}	+"/title" +"call cursor(getline('.'), 14)"

# Mac
.if ${MAC} == "YES"
ECHO=		/bin/echo
ECHONL=		/bin/echo -n
MUACOMPOSER=	mail
.endif

# Hyper-V
.if ${IF} == "hn0"
TEXTCOPY=	win	clip
HTMLBROWSER=	win	msedge
MUACOMPOSER=	win	mail
SCREENSHOTBROWSER=	win screenshotbrowser1200x800
.endif