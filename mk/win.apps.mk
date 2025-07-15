# Copyright (c) 2007,2009,2010,2011,2013,2019,2021,2022,2024 ONGS Inc.
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

GLSD-DOC2HTML=	glsd2html
GLSD-DOC2TEXT=	glsd2txt
GLSD-DOC2YD=	glsd2mn

ifeq		($(filter -f Makefile.win,$(MAKE)),)
MAKE+=		-f Makefile.win
endif

ECHO=		echo
ECHONL=		echo	-n
BUILDSYSTEM=	ydmklp	$(CURDIR) > /dev/null 2>&1 &

HTMLBROWSER=	start
YDBROWSER=	start
SCREENSHOTBROWSER=	win	screenshotbrowser1200x800
TEXTCOPY=	clip
TEXTPASTE=	powershell Get-Clipboard
COPYTOSTDERR=	tee	/dev/stderr
MUACOMPOSER=	mail.ps1
MAILSIZECHECK=	if [ $(LIMITSIZEOFMAIL) -lt $$(ls -l *tgz | awk '{print $$5}') ];	\
		then									\
			$(ECHO)	"*** Size is over. Please send it in another way.";	\
			false;								\
		fi

IMGEDITOR=	powershell Start-Process 'shell:AppsFolder\MooiiTech.PhotoScapeX_f5eddttrpssna!MooiiTech.PhotoScapeX' -ArgumentList "(Resolve-Path 001raw.jpg)"

VSC=		code
VIM=		nvim
XMLEDITOR=	$(VIM)