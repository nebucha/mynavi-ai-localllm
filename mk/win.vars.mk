# Copyright (c) 2007,2010,2011,2013,2016,2019,2021,2023,2025 ONGS Inc.
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

FROM_EMAILADDRESS=		grep.ongs@gmail.com

ifeq ($(USERNAME),daichi)
USER_FULLNAME_KANJI=		後藤大地
USER_FULLNAME_ROMA=		Daichi GOTO
USER_EMAILADDRESS=		$(FROM_EMAILADDRESS)
endif

ifeq ($(USERNAME),takasyou)
USER_FULLNAME_KANJI=		杉山貴章
USER_FULLNAME_ROMA=		Takaaki SUGIYAMA
USER_EMAILADDRESS=		takasyou@gmail.com
endif

ifeq ($(USERNAME),sasaki)
#USER_FULLNAME_KANJI=		佐々木宜文
#USER_FULLNAME_ROMA=		Yoshifumi SASAKI
#USER_EMAILADDRESS=		sasaki@ongs.co.jp
USER_FULLNAME_KANJI=		後藤大地
USER_FULLNAME_ROMA=		Daichi GOTO
USER_EMAILADDRESS=		$(FROM_EMAILADDRESS)
endif

ifeq ($(USERNAME),mo)
USER_FULLNAME_KANJI=		後藤大地
USER_FULLNAME_ROMA=		Daichi GOTO
USER_EMAILADDRESS=		$(FROM_EMAILADDRESS)
endif

EDITOR_EMAILADDRESS=		imabayashi.toshi@mynavi.jp,to.imaba@gmail.com
EDITOR_NAME=			MYNAVI.JP

DIR_NAME=			$$(basename $(CURDIR))
PKG_NAME=			$(DIR_NAME).tgz

MAIL_SUBJECT=			$(EDITOR_NAME):_$(DIR_NAME)
LIMITSIZEOFMAIL=		7340032

TYPESCRIPT_XML_FILE=		typescript.xml
TYPESCRIPT_HTMLOUT=		$(TYPESCRIPT_XML_FILE:.xml=.html)
TYPESCRIPT_TEXTOUT=		$(TYPESCRIPT_XML_FILE:.xml=.txt)
TYPESCRIPT_YDOUT=		$(TYPESCRIPT_XML_FILE:.xml=.yd)
TYPESCRIPT_GPTOUT=		$(TYPESCRIPT_XML_FILE:.xml=.gpt)

TYPESCRIPT_IMAGESZIP=		images.zip

TYPESCRIPT_DIRPATTERN=		[0-9]{8}-.*
TYPESCRIPT_DIRSAMPLE=		$$(date +%Y%m%d)-hogemoge
TYPESCRIPT_MAILCHECK_FILE=	.sendmail-done
TYPESCRIPT_CMSCHECK_FILE=	.cms-done
TYPESCRIPT_TMPCHECK_FILE=	.temp-working
TYPESCRIPT_UPDCHECK_FILE=	.update-done
TYPESCRIPT_TIMESTAMP_FILE=	.timestamp
TYPESCRIPT_BUILDLOCK_FILE=	.build-lock
TYPESCRIPT_BUILDPID_FILE=	.build.pid
YEAR=				$$(date +%Y)

SUFFIXES			= .xml .html .txt .yd
.SUFFIXES: $(SUFFIXES)

news_win_vars_mk_first: all

USER_FULLNAME_KANJI:
	@echo	$(USER_FULLNAME_KANJI)
