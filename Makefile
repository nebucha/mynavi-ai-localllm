# Copyright (c) 2005-2014,2020,2021-2024 ONGS Inc.
# All rights reserved.
#
# This software may be used, modified, copied, and distributed, in
# both source and binary form provided that the above copyright and
# these terms are retained. Under no circumstances is the author
# responsible for the proper functioning of this software, nor does
# the author assume any responsibility for damages incurred with its
# use.

# author: Daichi GOTO (daichi@ongs.co.jp)

.include "mk/vars.mk"
.include "mk/apps.mk"

all:	pull

# 利用するエディターによって処理を切り分け
.if defined(DEFAULT_EDITOR) && ${DEFAULT_EDITOR} == "nvim"
.include "mk/Makefile-nvim"
.else
.include "mk/Makefile-code"
.endif

#=========================================================================
# ツールコマンドを変数に設定
#=========================================================================
DBDIR=			./../database-orgs/
GET_INFO=		${DBDIR}/tools/get_info

GENERATOR=		./tools/MAKE_TYPESCRIPT
POSTGENERATOR=		./tools/MAKE_TYPESCRIPT_POSTTREATMENT
ENGAGE_NEW_TYPESCRIPT=	./tools/ENGAGE_NEW_TYPESCRIPT
CHECKCOST=		./tools/CHECKCOST

GET_GETSUMATSU_MAIL= 	./tools/gen_getsumatsu_mail

#=========================================================================
# 記事ディレクトリー名を設定
#=========================================================================
.if	defined(name)
NAME!=	echo	$$(date +%Y%m%d)-${name}
.endif

#=========================================================================
# 新規記事作成
#=========================================================================
add:	pull
	@if	[ -n "${name}" ];					 \
	then								 \
		${ENGAGE_NEW_TYPESCRIPT} 				 \
			name=${name} 					 \
			url="${url}"					 \
			title="${title}";				 \
	fi

addhontai:
	mkdir	-p ${NAME}/images
	@cat	template/Makefile					|\
	sed	-e "s/USER/${USER_FULLNAME_ROMA} (${USER_EMAILADDRESS})/"\
		-e "s/DATE/\$$$$(${ECHO} Date)\$$/"			 \
		-e "s/REVISION/\$$$$(${ECHO} Revision)\$$/"		 \
									 > ${NAME}/Makefile
	@cat	template/Makefile.win					|\
	sed	-e "s/USER/${USER_FULLNAME_ROMA} (${USER_EMAILADDRESS})/"\
		-e "s/DATE/\$$$$(${ECHO} Date)\$$/"			 \
		-e "s/REVISION/\$$$$(${ECHO} Revision)\$$/"		 \
									 > ${NAME}/Makefile.win
	${GENERATOR} "${url}" ${NAME} "${title}"			 > ${NAME}/typescript.xml || true
	${POSTGENERATOR} ${NAME} ${url}
	@cd	${NAME};						 \
		${MAKE}	;						 \
		${MAKE}	url="${url}" view > /dev/null;		 	 \
		${MAKE}	url="${url}" view-screenshot > /dev/null;
	${MAKE}	addhontai2 name=${NAME}

#=========================================================================
# 操作系ターゲット
#=========================================================================
pull:
	git	stash || true
	git	pull
	git	stash apply || true

push-after-post: clean
	git	add $$(ls | tail -200 | grep '^[0-9]')
	git	commit -m 'POST URI added' && git push || true

postlist:
	@ls								|\
	tail	-200							|\
	grep	'^[0-9]'						|\
	while	read dir;						 \
	do								 \
		grep	-H 'ST:\]' $${dir}/typescript.xml;		 \
	done								|\
	cut	-f1 -d:							|\
	while	read file;						 \
	do								 \
		echo	-n "$$file      "				|\
		cut	-f1 -d/;					 \
		grep	-E '^   <title><p>' "$$file"			|\
		sed	's/[ ]*<[a-z\/]*>//g';				 \
		echo	"";						 \
	done

clean:
	for	dir in	$$(ls | grep -E "${TYPESCRIPT_DIRPATTERN}");	\
	do								\
		cd	$$dir;						\
		${MAKE}	clean;						\
		cd	..;						\
	done

money:
	@${CHECKCOST}

#=========================================================================
# デスク用機能
#=========================================================================
update_dic:	pull
	mv	${HOME}/dic.txt						\
		template/dic-google-japanese-ime-shortcuts.txt
	git	add template/dic-google-japanese-ime-shortcuts.txt
	git	commit -m updated
	git	push
	@echo	"========================================================="
	@${ECHONL} "短縮名辞書更新時刻: "
	@date	-r template/dic-google-japanese-ime-shortcuts.txt
	@echo	"========================================================="

update_misc:	pull
	date								> template/updated_misc
	git	add template/updated_misc
	git	commit -m updated
	git	push
	@echo	"========================================================="
	@${ECHONL} "misc      更新時刻: "
	@date	-r template/updated_misc
	@echo	"========================================================="

update_glsd:	pull
	date								> template/updated_glsd
	git	add template/updated_glsd
	git	commit -m updated
	git	push
	@echo	"========================================================="
	@${ECHONL} "拡張glsd  更新時刻: "
	@date	-r template/updated_glsd
	@echo	"========================================================="

update_mncms:	pull
	date								> template/updated_mncms
	git	add template/updated_mncms
	git	commit -m updated
	git	push
	@echo	"========================================================="
	@${ECHONL} "拡張mncms 更新時刻: "
	@date	-r template/updated_mncms
	@echo	"========================================================="

redate:	pull
	@ls 								|\
	tail	-200 							|\
	grep	'^[0-9]'						|\
	while	read dir; 						 \
	do 							 	 \
		grep	-H 'ST:\]' $${dir}/typescript.xml; 	 	 \
	done 								|\
	cut	-f1 -d/							|\
	awk	'{print $$1,$$1}'					|\
	sed	-E 's/[0-9]{8}/'$$(date -d "1 mon" "+%Y%m25")'/'	|\
	awk	'{print "git mv "$$2" "$$1}'
	@${ECHO}	;						 \
	${ECHONL} "redate now? [y] = ";					 \
	read	ans;							 \
	case	"$${ans}" in						 \
	""|y|Y)								 \
		ls 							|\
		tail	-200 						|\
		grep	'^[0-9]'					|\
		while	read dir; 					 \
		do 						 	 \
			grep	-H 'ST:\]' $${dir}/typescript.xml; 	 \
		done 							|\
		cut	-f1 -d/						|\
		awk	'{print $$1,$$1}'				|\
		sed	-E 's/[0-9]{8}/'$$(date -d "1 mon" "+%Y%m25")'/'|\
		awk	'{print "git mv "$$2" "$$1}'			|\
		sh;							 \
		git 	commit -m redated;				 \
		git	push;						 \
		;;							 \
	esac

#=========================================================================
# コンテンツ開発2課　請求書メール作成
#=========================================================================
mail-cd1ka:
	@echo	==========================================================
	@cat	template/mailbody-seikyu-cd1ka				|\
	sed	-e "s/YEAR/$$(date +%Y)/g"				 \
		-e "s/MONTH/$$(date +%m)/g"				 \
		-e "s/'/\'/g"						|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY} 
	@echo	==========================================================
	@echo
	${MUACOMPOSER}							 \
		-f	${FROM_EMAILADDRESS}				 \
		-t	mn-seikyu@mynavi.jp				 \
		-c	imabayashi.toshi@mynavi.jp 			 \
		-s	"【マイナビ】$$(date +%m)月25日締めマイナビニュース コンテンツ開発1課　請求書ほか" \
		-A	${HOME}/desktop/請求書.pdf,${HOME}/desktop/請求明細.pdf,${HOME}/desktop/納品書.pdf,${HOME}/desktop/納品明細.pdf \
		-C							 &

#=========================================================================
# コンテンツ開発2課　月末報告メール
#=========================================================================
mail-cd1ka-getsumatsu:
	@echo	==========================================================
	@${GET_GETSUMATSU_MAIL}						|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY} 
	@echo	==========================================================
	@echo
	${MUACOMPOSER}							 \
		-f	${FROM_EMAILADDRESS}				 \
		-t	imabayashi.toshi@mynavi.jp			 \
		-s	"【オングス】:$$(date +%Y年%m月)分ニュース執筆状況について" \
		-C							 &

#=========================================================================
# TECH+推進課　請求書メール作成
#=========================================================================
mail-tech+:
	@echo	==========================================================
	@cat	template/mailbody-seikyu-tech+				|\
	sed	-e "s/YEAR/$$(date +%Y)/g"				 \
		-e "s/MONTH/$$(date +%m)/g"				 \
		-e "s/'/\'/g"						|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY} 
	@echo	==========================================================
	@echo
	${MUACOMPOSER}							 \
		-f	${FROM_EMAILADDRESS}				 \
		-t	mn-seikyu@mynavi.jp				 \
		-c	ito.masako.ap@mynavi.jp,hayashi.yukie.ui@mynavi.jp \
		-s	"【マイナビ】$$(date +%m)月25日締めマイナビニュース TECH+推進課　請求書ほか" \
		-A	${HOME}/Desktop/請求書.pdf,${HOME}/Desktop/請求明細.pdf,${HOME}/Desktop/納品書.pdf,${HOME}/Desktop/納品明細.pdf \
		-C							 &

#=========================================================================
# B2C制作2　請求書メール作成
#=========================================================================
mail-b2c:
	@echo	==========================================================
	@cat	template/mailbody-seikyu-b2c				|\
	sed	-e "s/YEAR/$$(date +%Y)/g"				 \
		-e "s/MONTH/$$(date +%m)/g"				 \
		-e "s/'/\'/g"						|\
	${COPYTOSTDERR}							|\
	${TEXTCOPY} 
	@echo	==========================================================
	@echo
	${MUACOMPOSER}							 \
		-f	${FROM_EMAILADDRESS}				 \
		-t	mn-seikyu@mynavi.jp				 \
		-c	imabayashi.toshi@mynavi.jp			 \
		-s	"【マイナビ】$$(date +%m)月25日締めマイナビニュース B2C 制作2　請求書ほか" \
		-A	${HOME}/Desktop/請求書.pdf,${HOME}/Desktop/請求明細.pdf,${HOME}/Desktop/納品書.pdf,${HOME}/Desktop/納品明細.pdf \
		-C							 &

#=========================================================================
# 企業データ操作
#=========================================================================
search:
	@${GET_INFO} ${entry}

#=========================================================================
# ユーティリティ
#=========================================================================
rmlast:
	@dir=$$(ls -trF | grep -E '^[0-9]{8}-' | tail -1 | tr -d '/');	\
	${ECHO};							\
	${ECHONL} "remove $${dir}? [y] = ";				\
	read	ans;							\
	case	"$${ans}" in						\
	""|y|Y)								\
		git	rm -rf "$${dir}";				\
		git	commit -m 'removed';				\
		git	push;						\
		;;							\
	esac
