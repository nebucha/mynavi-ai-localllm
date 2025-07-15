# Copyright (c) 2002-2007,2009,2010,2013,2018,2021-2026 ONGS Inc.
# All rights reserved.
#
# This software may be used, modified, copied, and distributed, in
# both source and binary form provided that the above copyright and
# these terms are retained. Under no circumstances is the author
# responsible for the proper functioning of this software, nor does
# the author assume any responsibility for damages incurred with its
# use.

# author: Daichi GOTO (daichi@ongs.co.jp)
# first edition: Mon Sep 15 18:59:43 2003

include	./../mk/win.vars.mk
include	./../mk/win.apps.mk

#=========================================================================
# toolsのスクリプトをコマンドパスに追加
#=========================================================================
PATH:=	./../tools/:$(PATH)

#=========================================================================
# ディレクトリ名などを変数に設定
#=========================================================================
DIR_NAME:=	$(shell basename $$(pwd))
TARGET_NAME:=	$(shell ${ECHO} $(DIR_NAME) | sed 's/^[^-]*-//')

#=========================================================================
# 操作系ターゲット
#=========================================================================
all:		html gpt
all-with-yd:	html yd text gpt

# 利用するエディタによって処理を切り分け
ifeq	($(DEFAULT_EDITOR),$(VIM))
include	./../mk/win.base.mk-nvim
else
include	./../mk/win.base.mk-code
endif

html:	$(TYPESCRIPT_HTMLOUT)

text:	$(TYPESCRIPT_TEXTOUT)

yd:	$(TYPESCRIPT_YDOUT)

gpt:	$(TYPESCRIPT_GPTOUT)

.xml.html:
	$(GLSD-DOC2HTML) $< 						> $@
	touch	-r	 $<						  $@

.xml.txt:
	$(GLSD-DOC2TEXT) $< 						> $@
	touch	-r	 $<						  $@

.xml.yd:
	$(GLSD-DOC2YD)	 $< 						> $@
	touch	-r	 $<						  $@

$(TYPESCRIPT_GPTOUT): $(TYPESCRIPT_XML_FILE)
	cat	./../template/gpt-order-proofreading			> $@
	echo	''							>>$@
	$(GLSD-DOC2TEXT) $< 						|\
	tail	+5							|\
	grep	-v '^　　'						|\
	grep	-v '^    '						|\
	grep	-E -v '^(コード)|(画像):'				|\
	grep	-E -v '^[A-Z]+:'					|\
	grep	-v '^|'							|\
	uniq								>>$@
	touch	-r	 $<						$@
	@# 記事生成用命令の出力
	@$(ECHO)
	@$(ECHO) ----
	@cat	./../template/gpt-order-article-writing
	@cat	$(TYPESCRIPT_XML_FILE)					|\
	grep	-Po '\[SRC:\Khttps?://[^]]+'

clean:
	rm -f 	$(TYPESCRIPT_HTMLOUT) 					\
		$(TYPESCRIPT_TEXTOUT) 					\
		$(TYPESCRIPT_YDOUT) 					\
		$(TYPESCRIPT_GPTOUT)					\
		$(TYPESCRIPT_IMAGESZIP) 				\
		$(PKG_NAME) 
ifeq	($(REMOVE_AFTER_GETIMG),YES)
	rm -f	$(HOME)/Desktop/$(TYPESCRIPT_IMAGESZIP) 		\
		$(HOME)/Desktop/*jpg					\
		$(HOME)/Desktop/*png 					\
		$(HOME)/Desktop/$(PKG_NAME)
endif

upload: 
ifneq	($(wildcard $(TYPESCRIPT_BUILDPID_FILE)), $(TYPESCRIPT_BUILDPID_FILE))
	$(MAKE)	clean all-with-yd
endif
ifneq	($(wildcard $(TYPESCRIPT_IMAGESZIP)), $(TYPESCRIPT_IMAGESZIP))
	$(MAKE)	all-with-yd
endif
	cp	$(TYPESCRIPT_IMAGESZIP)					\
		$(HOME)/Desktop/

#edit:

pull:
	git	stash || true
	git	pull --no-rebase
	git	stash apply || true

add-and-push: clean pull
	git	add .
	if	git commit -m "$(msg)";					\
	then								\
		git	push;						\
		$(MAKE)	diff;						\
	fi

push:	
	$(MAKE)	add-and-push msg="push done"

push-and-notify:
	$(MAKE)	add-and-push msg="==> Do chk (${TARGET_NAME})"

#=========================================================================
# 画像ファイル取得ターゲット
#=========================================================================
getimg:
	cd	images; 						 \
	if	cp $(HOME)/Desktop/*[Gg] ./ 2> /dev/null;		 \
	then								 \
	 	i=1;							 \
	 	ls	-tr						|\
	 	grep	-E "(0.*raw.*)|(スクリーン.*)|(Screen.*)|(IMG.*)|(PNG.*)" |\
	 	while	read img;					 \
	 	do							 \
			mv	"$$img" "IMG.$${img##*.}";		 \
	 		gm	convert "IMG.$${img##*.}" "$$(printf %03draw.jpg $$i)"; \
	 		rm	"IMG.$${img##*.}";			 \
	 		i=$$((1 + $$i));				 \
	 	done;							 \
	 	if	[ "YES" = $(REMOVE_AFTER_GETIMG) ];		 \
	 	then							 \
	 		rm 	-f $(HOME)/Desktop/0*raw*;		 \
	 		rm 	-f $(HOME)/Desktop/スクリーン*;		 \
	 		rm 	-f $(HOME)/Desktop/Screen*;		 \
	 		rm 	-f $(HOME)/Desktop/IMG*;		 \
	 		rm 	-f $(HOME)/Desktop/PNG*;		 \
	 	fi;							 \
	fi
	$(MAKE)	imagelist
	rm -f	$(TYPESCRIPT_UPDCHECK_FILE)

#=========================================================================
# 画像ファイル編集ターゲット
#=========================================================================
editimg:
	cd	images; 						\
	$(IMGEDITOR)

#=========================================================================
# ビルド系ターゲット
#=========================================================================
#build:

build-lock:
	@touch	$(TYPESCRIPT_BUILDLOCK_FILE)

build-unlock:
	@rm -f	$(TYPESCRIPT_BUILDLOCK_FILE)

#=========================================================================
# リスト生成ターゲット
#=========================================================================
imagelist:
	( for	target in 						 \
		$$(findcmd images -type f -name "*pg" | sortcmd | uniq); \
	do 								 \
		cleantxt=$$(echo $$target);				 \
		$(ECHO) ;						 \
		$(ECHONL) '  <p><import caption="" id="';		 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHONL) '" ref="';					 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHO)   '" type="image/jpeg" /></p>';			 \
	done								 \
	) 								|\
	$(COPYTOSTDERR)							|\
	$(TEXTCOPY)

commandlist:
	( for	target in 						 \
		$$(findcmd commands -type f | sortcmd | uniq);		 \
	do 								 \
		cleantxt=$$(echo $$target);				 \
		$(ECHO) ;						 \
		$(ECHONL) '  <p><import caption="" id="';		 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHONL) '" ref="';					 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHO)   '" type="text/command-prompt" encoding="UTF-8" /></p>'; \
	done								 \
	) 								|\
	$(COPYTOSTDERR)							|\
	$(TEXTCOPY)

sourcelist:
	( for	target in 						 \
		$$(findcmd sources -type f | sortcmd | uniq);		 \
	do 								 \
		cleantxt=$$(echo $$target);				 \
		$(ECHO) ;						 \
		$(ECHONL) '  <p><import caption="" id="';		 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHONL) '" ref="';					 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHO)   '" type="text/sourcecode" encoding="UTF-8" /></p>'; \
	done								 \
	) 								|\
	$(COPYTOSTDERR)							|\
	$(TEXTCOPY)

tablelist:
	( for	target in 						 \
		$$(findcmd tables -type f | sortcmd | uniq);		 \
	do 								 \
		cleantxt=$$(echo $$target);				 \
		$(ECHO) ;						 \
		$(ECHONL) '  <p><import caption="" id="';		 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHONL) '" ref="';					 \
		$(ECHONL) $${cleantxt};					 \
		$(ECHO)   '" type="text/tsv" encoding="UTF-8" /></p>'; \
	done								 \
	) 								|\
	$(COPYTOSTDERR)							|\
	$(TEXTCOPY)

#=========================================================================
# リスト生成短縮名ターゲット
#=========================================================================
il:	imagelist

cl:	commandlist

sl:	sourcelist

tl:	tablelist

#=========================================================================
# 閲覧系ターゲット
#=========================================================================
DIRPATH=	$$(echo $(CURDIR) | sed 's,c/,C:/,')
view:	html
	$(HTMLBROWSER) file://$(DIRPATH)/$(TYPESCRIPT_HTMLOUT)

view-yd: yd
	$(YDBROWSER) file://$(DIRPATH)/$(TYPESCRIPT_YDOUT)

view-gpt: gpt
	$(HTMLBROWSER) file://$(DIRPATH)/$(TYPESCRIPT_GPTOUT)

view-screenshot: html
	$(SCREENSHOTBROWSER) file://$(DIRPATH)/$(TYPESCRIPT_HTMLOUT)

view-katakana:
	cd	..							;\
	$(MAKE)	$@

katakana:
	cd	..							;\
	$(MAKE)	$@

open:
	url=$$(	grep	-F '[POST:' $(TYPESCRIPT_XML_FILE)		|\
	    	grep	-o 'http[^]]*');				 \
	$(HTMLBROWSER) $${url}

twitter:
	url=$$(	grep	-F '[POST:' $(TYPESCRIPT_XML_FILE)		|\
	    	grep	-o 'http[^]]*');				 \
	$(HTMLBROWSER) https://twitter.com/search?q=$${url}

#=========================================================================
# CMS入稿用ターゲット
#=========================================================================
cms:	pull upload
	@#================================================================
	@# タイトルチェック
	@#================================================================
	@echo	-n "タイトルチェック: "
	@if	grep '<title><p></p></title>' $(TYPESCRIPT_XML_FILE)	> /dev/null 2>&1; \
	then								\
		echo	"FAILED";					\
		false	;						\
	else								\
		echo	"OK";						\
	fi
	@#================================================================
	@# リードチェック
	@#================================================================
	@echo	-n "リードチェック: "
	@if	grep '\[LEAD:\]' $(TYPESCRIPT_XML_FILE)	> /dev/null 2>&1; \
	then								\
		echo	"FAILED";					\
		false	;						\
	else								\
		echo	"OK";						\
	fi
	@#================================================================
	@# CMSへ自動入稿
	@#================================================================
	@echo	"CMS自動入稿処理"
	CMS_POWERSHELL_TECHPLUS_NEW_NEWS.ps1
	$(ECHO)	'<!-- cms done -->'					>>\
		$(TYPESCRIPT_XML_FILE)
	$(MAKE)	add-and-push msg="|-- cms done (${TARGET_NAME})"

#=========================================================================
# メール入稿用ターゲット 
#=========================================================================
package: clean all
	$(MAKE)	build-lock
	tar	zcf "../$(PKG_NAME)" -C .. "$(DIR_NAME)"
	mv	"../$(PKG_NAME)" ./
	$(MAKE)	build-unlock

mail:	package
	@$(MAILSIZECHECK)
	$(MAKE)
	cp	$(PKG_NAME) $(HOME)/Desktop/
	@echo	==========================================================
	@cat	../template/mailbody					|\
	sed	-e "s/EDITOR_NAME/$(EDITOR_NAME)/g"			 \
		-e "s/USER_FULLNAME_KANJI/$(USER_FULLNAME_KANJI)/g"	 \
		-e "s/USER_EMAILADDRESS/$(USER_EMAILADDRESS)/g"		 \
		-e "s/'/\'/g" 						|\
        tee	/dev/stderr						|\
	$(TEXTCOPY)
	@echo	==========================================================
	@echo
	$(MUACOMPOSER) 							\
		-To	$(EDITOR_EMAILADDRESS)				\
		-Cc	"$(EDITOR_EMAILADDRESS_CC)"			\
		-Subject $(MAIL_SUBJECT)				\
		-Attachment C:\\Users\\$(USERNAME)\\Desktop\\$(PKG_NAME)\
		-BodyFromClip
	@$(ECHONL) "sendmail successed? [y] = "; 			\
		read	ans; 						\
		case	"$${ans}" in 					\
		""|y|Y) 						\
			;; 						\
		esac
	$(MAKE)	build-unlock
	$(MAKE)	clean

#=========================================================================
# デスク用機能
#=========================================================================
#check:

push-and-reply:
	$(ECHO)	'<!-- check done -->'					>>\
		$(TYPESCRIPT_XML_FILE)
	$(MAKE)	add-and-push msg="<-- cms please (${TARGET_NAME})"

search-on-mynavi:
	url='https://news.mynavi.jp/freeword_techplus?utf8=%E2%9C%93&q='; \
	$(HTMLBROWSER)	"$${url}${keyword}"

#=========================================================================
# ユーティリティ
#=========================================================================
diff:	diff1

diff1:
	rep=$$(	git	remote -v					|\
	    	head	-1						|\
		awk	'{print $$2}'					|\
		cut	-f2 -d:						|\
		sed	's/[.]git//');					 \
	id=$$(	git	log -- typescript.xml				|\
		grep	'^commit'					|\
		head	-1						|\
		awk	'{print $$2}');					 \
	url=https://github.com/$${rep}/commit/$${id};			 \
	$(HTMLBROWSER) 	$${url}

diff2:
	rep=$$(	git	remote -v					|\
	    	head	-1						|\
		awk	'{print $$2}'					|\
		cut	-f2 -d:						|\
		sed	's/[.]git//');					 \
	id=$$(	git	log -- typescript.xml				|\
		grep	'^commit'					|\
		tail	+2						|\
		head	-1						|\
		awk	'{print $$2}');					 \
	url=https://github.com/$${rep}/commit/$${id};			 \
	$(HTMLBROWSER) 	$${url}

diff3:
	rep=$$(	git	remote -v					|\
	    	head	-1						|\
		awk	'{print $$2}'					|\
		cut	-f2 -d:						|\
		sed	's/[.]git//');					 \
	id=$$(	git	log -- typescript.xml				|\
		grep	'^commit'					|\
		tail	+3						|\
		head	-1						|\
		awk	'{print $$2}');					 \
	url=https://github.com/$${rep}/commit/$${id};			 \
	$(HTMLBROWSER) 	$${url}
