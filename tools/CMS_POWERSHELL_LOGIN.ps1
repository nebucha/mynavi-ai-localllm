#!/usr/bin/env pwsh

#========================================================================
# マイナビCMSをオープンしてログインする
#========================================================================

#========================================================================
# CMSをオープン(ベーシック認証あり)
#========================================================================
$BasicUser = 'news-cms'
$BasicPassword = 'YjUDs8H9K9Wz'
$BasicPath = 'manage.news.mynavi.jp/admin'

'マイナビCMSを開きます。'
Set-SeUrl -Url https://${BasicUser}:$BasicPassword@$BasicPath
'マイナビCMSオープン完了。'

#========================================================================
# CMSアカウントデータ
#========================================================================
$CmsUser = 'daichi@ongs.co.jp'
$CmsPassword = 'WyvkQBE0qTYYQ'

$uname = (Get-Content typescript.xml | Select-String -SimpleMatch '>杉山貴章<')
if	($uname -ne $null) {
	$env:Username = 'takasyou'
}

if	('takasyou' -eq $env:Username) {
	$CmsUser = 'takasyou@gmail.com'
	$CmsPassword = 'mqVpH2-abDuGVU'
}

#========================================================================
# CMSへログイン
#========================================================================
'マイナビCMSへログインします。'
# ユーザ名入力
$Element = Get-SeElement -By Id -Value admin_user_email
Invoke-SeKeys -Element $Element -Keys $CmsUser

# パスワード入力
$Element = Get-SeElement -By Id -Value admin_user_password
Invoke-SeKeys -Element $Element -Keys $CmsPassword

# ログインボタンをクリック
$Element = Get-SeElement -By Name -Value commit
Invoke-SeClick -Element $Element -Action Click
'マイナビCMSへログイン完了。'
