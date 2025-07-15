#!/usr/bin/env pwsh

#========================================================================
# TECH+記事の掲載処理を行います
#========================================================================

#========================================================================
# 掲載処理
#========================================================================
# 掲載するかどうかを確認
Add-Type -Assembly System.Windows.Forms
$Answer = [System.Windows.Forms.MessageBox]::Show(
	'掲載しますか？',
	'掲載確認',
	'YesNo',
	'Question');

# 掲載する場合には掲載ボタンをクリック
Switch	($Answer)
{
	'Yes' {
		$Element = Get-SeElement 				`
			-By XPath 					`
			-Value '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[1]/div[2]/input[2]'
		Invoke-SeClick -Element $Element -Action Click
		# 確認ダアログでOKボタンをクリック
		SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

		# 掲載ボタンを確実に押すために数秒待機
		Start-Sleep 3

		# 掲載を確認するために企画・掲載一覧を表示
		$IchiranPath = 'manage.news.mynavi.jp/admin/projects/index_techplus'
		Set-SeUrl -Url https://${BasicUser}:$BasicPassword@$IchiranPath

		# 掲載一覧を確認するための一時停止用ダイアログ
		$Answer = [System.Windows.Forms.MessageBox]::Show(
			'「掲載承認待ち」になっていることを確認してください。',
			'掲載確認',
			'OK',
			'Asterisk');
	}
	'No' {
	}
}
