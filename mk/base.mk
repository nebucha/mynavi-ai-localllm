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

.include "vars.mk"
.include "apps.mk"

#=========================================================================
# ディレクトリ名などを変数に設定
#=========================================================================
DIR_NAME!=	basename $$(pwd)
TARGET_NAME!=	${ECHO} ${DIR_NAME} | sed 's/^[^-]*-//'

#=========================================================================
# 操作系ターゲット
#=========================================================================
all:		html gpt
all-with-yd:	html yd text gpt

# 利用するエディタによって処理を切り分け
.if defined(DEFAULT_EDITOR) && ${DEFAULT_EDITOR} == "nvim"
.include "base.mk-nvim"
.else
.include "base.mk-code"
.endif

html:	${TYPESCRIPT_HTMLOUT}

text:	${TYPESCRIPT_TEXTOUT}

yd:	${TYPESCRIPT_YDOUT}

gpt:	${TYPESCRIPT_GPTOUT}

.xml.html:
	${GLSD-DOC2HTML} "${<}" 					> "${@}"
	touch	-r	 "${<}"						  "${@}"
	chmod	644 	 						  "${@}"

.xml.txt:
	${GLSD-DOC2TEXT} "${<}" 					> "${@}"
	touch	-r	 "${<}"						  "${@}"
	chmod	644 	 						  "${@}"

.xml.yd:
	${GLSD-DOC2YD} 	 "${<}" 					> "${@}"
	touch	-r	 "${<}"						  "${@}"
	chmod	644 	 						  "${@}"

${TYPESCRIPT_GPTOUT}: ${TYPESCRIPT_XML_FILE}
	cat	./../template/gpt-order-proofreading			> $@
	@${ECHO} ''							>>$@
	@${GLSD-DOC2TEXT} "${TYPESCRIPT_XML_FILE}"			|\
	tail	+5							|\
	grep	-v '^　　'						|\
	grep	-v '^    '						|\
	grep	-E -v '^(コード)|(画像):'				|\
	grep	-E -v '^[A-Z]+:'					|\
	grep	-v '^|'							|\
	uniq								>>$@
	touch	-r "${TYPESCRIPT_XML_FILE}"				"${@}"
	chmod	644	 						"${@}"
	@# 記事生成用命令の出力
	@${ECHO}
	@${ECHO} ----
	@cat	./../template/gpt-order-article-writing
#	@cat	${TYPESCRIPT_XML_FILE}					|\
#	ggrep	-Po '\[SRC:\Khttps?://[^]]+'

clean:
	@rm -f 	${TYPESCRIPT_HTMLOUT} 					\
		${TYPESCRIPT_TEXTOUT}					\
		${TYPESCRIPT_YDOUT}					\
		${TYPESCRIPT_GPTOUT}					\
		${TYPESCRIPT_IMAGESZIP}					\
		index.top.jpg						\
		${PKG_NAME}
.if	${REMOVE_AFTER_GETIMG} == "YES"
. if	${MAC} == "YES"
	@rm -f	${HOME}/Desktop/${TYPESCRIPT_IMAGESZIP}			\
		${HOME}/Desktop/*jpg					\
		${HOME}/Desktop/*png					\
		${HOME}/Desktop/${PKG_NAME}

. else
	ssh 	virthost rm '$${HOME}'/Desktop/${TYPESCRIPT_IMAGESZIP} || true
	ssh 	virthost rm '$${HOME}'/Desktop/\*jpg || true
	ssh 	virthost rm '$${HOME}'/Desktop/\*png || true
	ssh 	virthost rm '$${HOME}'/Desktop/${PKG_NAME} || true
. endif
.endif

upload: 
.if	!exists(${.CURDIR}/${TYPESCRIPT_BUILDPID_FILE})
	make	clean all-with-yd
.endif
.if	!exists(${.CURDIR}/${TYPESCRIPT_IMAGESZIP})
	make	all-with-yd
.endif
.if	${MAC} == "YES"
	cp	${TYPESCRIPT_IMAGESZIP}					\
		${HOME}/Desktop/
.else
	scp	${TYPESCRIPT_IMAGESZIP} 				\
		virthost:'$${HOME}'/Desktop/
.endif

#edit:

pull:
	git	stash || true
	git	pull --no-rebase
	git	stash apply || true

add-and-push: clean pull
	git 	add .
	if	git commit -m "${msg}";					\
	then								\
		git	push;						\
		${MAKE}	diff;						\
	fi

push:	
	${MAKE}	add-and-push msg="push done"

push-and-notify:
	${MAKE}	add-and-push msg="==> Do chk (${TARGET_NAME})"

#=========================================================================
# 画像ファイル取得ターゲット
#=========================================================================
getimg:
	cd	images;							 \
	if	if	[ "YES" = "${MAC}" ];				 \
		then							 \
			cp	${HOME}/Desktop/*g 			 \
				./ || true;				 \
		else							 \
			result="false";					 \
			scp	-p virthost:'$${HOME}'/Desktop/0\*g \
				./ && result="true" || true;		 \
			scp	-p virthost:'$${HOME}'/Desktop/IMG\*g 	 \
				./ && result="true" || true;		 \
			scp	-p virthost:'$${HOME}'/Desktop/Screen\*g \
				./ && result="true" || true;		 \
			scp	-p virthost:'$${HOME}'/Desktop/スクリーン\*g \
				./ && result="true" || true;		 \
			$${result};					 \
		fi;							 \
	then								 \
		i=1;							 \
		ls	-tr						|\
		grep	-E "(0.*raw.*)|(スクリーン.*g)|(Screen.*g)|(IMG.*g)"	|\
		while	read img;					 \
		do							 \
			gm	convert					 \
				"$$img" 				 \
				"$$(printf %03draw.jpg $$i)";		 \
			rm	"$$img";				 \
			i=$$((1 + $$i));				 \
		done;							 \
		if	[ "YES" = ${REMOVE_AFTER_GETIMG} ];		 \
		then							 \
			if	[ "YES"  = "${MAC}" ];			 \
			then						 \
				rm	-f ${HOME}/Desktop/*g || true;	 \
			else						 \
				ssh	virthost 			 \
					rm -f '$${HOME}'/Desktop/\*g;	 \
			fi;						 \
		fi;							 \
	fi
	make	imagelist
	rm	-f ${TYPESCRIPT_UPDCHECK_FILE}

#=========================================================================
# 画像ファイル編集ターゲット
#=========================================================================
editimg:
	cd	images;							\
	${IMGEDITOR} 0*.jpg

#=========================================================================
# ビルド系ターゲット
#=========================================================================
#build:

build-lock:
	@touch	${TYPESCRIPT_BUILDLOCK_FILE}

build-unlock:
	@rm -f	${TYPESCRIPT_BUILDLOCK_FILE}

#=========================================================================
# リスト生成ターゲット
#=========================================================================
imagelist:
	( for	target in 						 \
		$$(find images -type f -name "*.jpg" | sort | uniq);	 \
	do								 \
		${ECHO} ;						 \
		${ECHONL} '  <p><import caption="" id="';		 \
		${ECHONL} $${target};					 \
		${ECHONL} '" ref="';					 \
		${ECHONL} $${target};					 \
		${ECHO}	'" type="image/jpeg"/></p>';			 \
	done								 \
	)								|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY} || true

commandlist:
	( for	target in 						 \
		$$(find commands -type f | sort | uniq); 		 \
	do								 \
		${ECHO} ;						 \
		${ECHONL} '  <p><import caption="" id="';		 \
		${ECHONL} $${target};					 \
		${ECHONL} '" ref="';					 \
		${ECHONL} $${target};					 \
		${ECHONL} '" type="text/command-prompt"';		 \
		${ECHO} ' encoding="UTF-8" /></p>';			 \
	done								 \
	)								|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY}

sourcelist:
	( for	target in 						 \
		$$(find sources -type f | sort | uniq);			 \
	do								 \
		${ECHO} ;						 \
		${ECHONL} '  <p><import caption="" id="';		 \
		${ECHONL} $${target};					 \
		${ECHONL} '" ref="';					 \
		${ECHONL} $${target};					 \
		${ECHONL} '" type="text/sourcecode"';			 \
		${ECHO}	' encoding="UTF-8" /></p>';			 \
	done								 \
	)								|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY}

csvlist:
	( for	target in 						 \
		$$(find csvs -type f | sort | uniq);			 \
	do								 \
		${ECHO} ;						 \
		${ECHONL} '  <p><import caption="" id="';		 \
		${ECHONL} $${target};					 \
		${ECHONL} '" ref="';					 \
		${ECHONL} $${target};					 \
		${ECHONL} '" type="text/csv"';				 \
		${ECHO} ' encoding="UTF-8" /></p>';			 \
	done								 \
	)								|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY}

tablelist:
	( for	target in 						 \
		$$(find tables -type f | sort | uniq);			 \
	do \
		${ECHO} ;						 \
		${ECHONL} '  <p><import caption="" id="';		 \
		${ECHONL} $${target};					 \
		${ECHONL} '" ref="';					 \
		${ECHONL} $${target};					 \
		${ECHONL} '" type="text/tsv"';				 \
		${ECHO} ' encoding="UTF-8" /></p>';			 \
	done								 \
	)								|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY}

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
view:	html
.if	${VIAHTTPSERVER} == "YES"
	${HTMLBROWSER} "http://${HTTPSERVER}/${.CURDIR:S,${HOME}/Documents/,,}/${TYPESCRIPT_HTMLOUT}"
.else
	${HTMLBROWSER} "file://${.CURDIR}/${TYPESCRIPT_HTMLOUT}"
.endif

view-yd: yd
.if	${VIAHTTPSERVER} == "YES"
	${HTMLBROWSER} "http://${HTTPSERVER}/${.CURDIR:S,${HOME}/Documents/,,}/${TYPESCRIPT_YDOUT}"
.else
	${YDBROWSER} "file://${.CURDIR}/${TYPESCRIPT_YDOUT}"
.endif

view-gpt: gpt
.if	${VIAHTTPSERVER} == "YES"
	${HTMLBROWSER} "http://${HTTPSERVER}/${.CURDIR:S,${HOME}/Documents/,,}/${TYPESCRIPT_GPTOUT}"
.else
	${HTMLBROWSER} "file://${.CURDIR}/${TYPESCRIPT_GPTOUT}"
.endif

view-screenshot: html
.if	${VIAHTTPSERVER} == "YES"
	${SCREENSHOTBROWSER} "http://${HTTPSERVER}/${.CURDIR:S,${HOME}/Documents/,,}/${TYPESCRIPT_HTMLOUT}" || true
.else
	${SCREENSHOTBROWSER} "file://${.CURDIR}/${TYPESCRIPT_HTMLOUT}" || true &
.endif

view-katakana:
	cd	..							;\
	${MAKE}	$@

katakana:
	cd	..							;\
	${MAKE}	$@

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
	@${ECHONL}	"タイトルチェック: "
	@if	grep '<title><p></p></title>' $(TYPESCRIPT_XML_FILE)	> /dev/null 2>&1; \
	then								\
		${ECHO}	"FAILED";					\
		false	;						\
	else								\
		${ECHO}	"OK";						\
	fi
	@#================================================================
	@# リードチェック
	@#================================================================
	@${ECHONL}	"リードチェック: "
	@if	grep '\[LEAD:\]' $(TYPESCRIPT_XML_FILE)	> /dev/null 2>&1; \
	then								\
		${ECHO}	"FAILED";					\
		false	;						\
	else								\
		${ECHO}	"OK";						\
	fi
	@#================================================================
	@# CMSへ自動入稿
	@#================================================================
	# Python Seleniumモジュールをインストールしておく必要がある
	# ため、実行前に確認して必要があればインストールする。
	@if	[ -z "$(pip3 list | grep ^selenium)" ];			\
	then								\
		${ECHO}	'Seleniumモジュールをインストールします。';	\
		${ECHO}	'----------------------------------------';	\
		pip3	install --break-system-packages selenium;	\
		${ECHO}	'----------------------------------------';	\
		${ECHO}	'Seleniumモジュールをインストール完了。';	\
	fi
	@${ECHO}	"CMS自動入稿処理"
	env	PATH=./../tools:"$${PATH}"				\
		CMS_PYTHON_TECHPLUS_NEW_NEWS.py
	${ECHO}	'<!-- cms done -->'					>>\
		${TYPESCRIPT_XML_FILE}
	${MAKE}	add-and-push msg="|-- cms done (${TARGET_NAME})"

#=========================================================================
# メール入稿用ターゲット 
#=========================================================================
package: clean all
	${MAKE}	build-lock
	tar	zcf "../${PKG_NAME}" -C .. "${DIR_NAME}"
	mv	"../${PKG_NAME}" ./
	${MAKE}	build-unlock

mail:	package
	# XXX 要動作確認
	@${MAILSIZECHECK}
	${MAKE}
.if	${MAC} == "YES"
	cp	${PKG_NAME} 						 \
		${HOME}/Desktop/
.else
	scp	"${PKG_NAME}" 						 \
		virthost:'$${HOME}'/Desktop/
.endif
	@${ECHO} =========================================================
	@cat	../template/mailbody					|\
	sed	-e "s/EDITOR_NAME/${EDITOR_NAME}/g"			 \
		-e "s/USER_FULLNAME_KANJI/${USER_FULLNAME_KANJI}/g"	 \
		-e "s/USER_EMAILADDRESS/${USER_EMAILADDRESS}/g"		 \
		-e "s/'/\'/g"						|\
        ${COPYTOSTDERR}							|\
	${TEXTCOPY}
	@${ECHO} =========================================================
	@${ECHO}
	
# Mac
.if	${MAC} == "YES"
	${MUACOMPOSER}							\
		-t "${EDITOR_EMAILADDRESS}"				\
		-c "${EDITOR_EMAILADDRESS_CC}"				\
		-s "${MAIL_SUBJECT}"					\
		-A ${HOME}/Desktop/${PKG_NAME}				\
		-C							&
	
# Hyper-V
.elif	${IF} == "hn0"
	${MUACOMPOSER} \
		to=${EDITOR_EMAILADDRESS},cc=${EDITOR_EMAILADDRESS_CC},subject=${MAIL_SUBJECT},attachment='$${HOME}\Desktop\'${PKG_NAME}
	
# Parallels Desktop
.elif	${IF} == "vtnet0"
	${MUACOMPOSER} \
		to=${EDITOR_EMAILADDRESS},cc=${EDITOR_EMAILADDRESS_CC},subject=${MAIL_SUBJECT},attachment='$${HOME}/Desktop/'${PKG_NAME}
	
# VMware Fusion
.elif	${IF} == "vmx0"
	${MUACOMPOSER} \
		to=${EDITOR_EMAILADDRESS},cc=${EDITOR_EMAILADDRESS_CC},subject=${MAIL_SUBJECT},attachment='$${HOME}/Desktop/'${PKG_NAME}
.endif
	@${ECHONL} "sendmail successed? [y] = ";			\
		read	ans;						\
		case	"$${ans}" in					\
		""|y|Y)							\
			;;						\
		esac
	${MAKE} build-unlock
	${MAKE} clean

#=========================================================================
# Sample for Mail.app:
#=========================================================================
# ${MUACOMPOSER}							\
# 	to="${EDITOR_EMAILADDRESS}"				\
# 	cc="${USER_EMAILADDRESS}"				\
# 	sender="${USER_EMAILADDRESS}"				\
# 	subject="${MAIL_SUBJECT}"				\
# 	attach="'$${HOME}'/Desktop/${PKG_NAME}"			\
# 	body=""
# .endif

#=========================================================================
# デスク用機能
#=========================================================================
#check:

push-and-reply: 
	${ECHO}	'<!-- check done -->'					>>\
		${TYPESCRIPT_XML_FILE}
	${MAKE}	add-and-push msg="<-- Do cms (${TARGET_NAME})"

search-on-mynavi:
	url='https://news.mynavi.jp/freeword_techplus?utf8=%E2%9C%93&q='; \
	${HTMLBROWSER}	"$${url}${keyword}"

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
	${HTMLBROWSER} 	$${url}

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
	${HTMLBROWSER} 	$${url}

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
	${HTMLBROWSER} 	$${url}
