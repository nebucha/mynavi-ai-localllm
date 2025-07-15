#!/usr/bin/env pwsh

#========================================================================
# TECH+記事データをCMSへアップロードする
#========================================================================

#========================================================================
# 引数を処理
#========================================================================
Param(
        [String]$YdFilePath = "typescript.yd"
)

#========================================================================
# 入稿フローを実施
#========================================================================
# 更新ボタンをクリック
'更新ボタンをクリックします。'
$Element = Get-SeElement -By XPath -Value '//*[@id="new_project"]/div[1]/div[2]/input[1]'
Invoke-SeClick -Element $Element -Action Click
# 確認ダアログでOKボタンをクリック
SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

# ページ再描画完了まで待機
Wait-SeElement -By XPath -Value '//*[@class="head_link_4"]/div/div[1]' 	`
	-Condition ElementToBeClickable -Timeout 5

# 素材入稿ボタンをクリック
'素材入稿ボタンをクリックします。'
$Element = Get-SeElement -By XPath -Value '//*[@class="head_link_4"]/div/div[1]'

Invoke-SeClick -Element $Element -Action Click
# 確認ダイアログでOKボタンをクリック
SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

# ページ読み込み完了まで待機
sleep 3

# ファイルの選択をクリック
'ファイルの選択ボタンをクリックします。'
$Element = Get-SeElement -By XPath -Value '//*[@id="admin_other_files_zip_form_zip_file"]'
if ($true) {
	#----------------------------------------------------------------
	# ファイル選択を自動で行う場合
	#----------------------------------------------------------------
	Invoke-SeKeys -Element $Element -Keys ${env:HOME}
	# ※ Microsoft Edgeは上記方法で送り込んだパスを処理しない。
	
	# ファイル選択ダイアログが表示されフォーカスが移るまで待機。
	sleep 1
	
	# .NET経由で表示されるファイルダイアログにパスの入力と選択を行う
	add-type -AssemblyName System.Windows.Forms
	# USERNAMEは引数で指定できるようにする。環境変数HOMEはUSERNAMEの
	# 変更の影響を受けるため、影響を受けないHOMEDRIVEとHOMEPATHを使う。
	$IMGFILE = $env:HOMEDRIVE + $env:HOMEPATH + "\Desktop\images.zip"
	[System.Windows.Forms.SendKeys]::SendWait($IMGFILE + "`n")
} else {
	#----------------------------------------------------------------
	# ファイル選択を手動で行う場合
	#----------------------------------------------------------------
	Invoke-SeKeys -Element $Element -Keys ${env:HOME}\Desktop\images.zip
	# ※ Microsoft Edgeは上記方法で送り込んだパスを処理しないため、
	# 表示されるファイル選択ダイアログから人が手動でファイルを選択する
	# 必要がある。
	
	# ファイルの選択を待ちます。
	Add-Type -Assembly System.Windows.Forms
	$Answer = [System.Windows.Forms.MessageBox]::Show(
		'画像ファイルを選択したらOKを押してください。',
		'画像ファイルの選択',
		'OK',
		'Asterisk');
}

# 2024/01/12 後藤 <- 小澤依頼
# 処理が早くてうまくいかないことがある可能性があるので、スリープ
sleep 1 

# 画像をアップロード
'画像をアップロードします。'
$Element = Get-SeElement -By XPath -Value '//*[@id="new_admin_other_files_zip_form"]/div/div[3]/div/div/input'
Invoke-SeClick -Element $Element -Action Click

# 企画編集へ戻る
'企画編集へ戻ります。'
$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div[2]/form[2]/div/div[1]/div[1]/input[1]'
$Count=1
while	(-Not $Element)
{
	# 画像ファイルを選択しアップロードを実施しても処理が失敗することがある。
	# キャプションが長すぎるなど画像ファイル形式に不備が原因のこともあれば、
	# 原因が不明なこともある。
	# アップロードに失敗した場合には、「TECH+企画編集へ戻る」の要素が取得できずに
	# $Elementが$Nullになることがわかっている。このため、ここで再びファイルの
	# 選択を行い問題を回避できるようにする。
	'画像ファイルの選択に失敗しました。再度画像ファイルを選択してください。'

	'ファイルの選択ボタンをクリックします。'
	$Element = Get-SeElement -By XPath -Value '//*[@id="admin_other_files_zip_form_zip_file"]'
	Invoke-SeKeys -Element $Element -Keys ${env:HOME}\Desktop\images.zip

	# ファイルの選択を待ちます。
	$Answer = [System.Windows.Forms.MessageBox]::Show(
		'画像ファイルを選択したらOKを押してください。',
		'画像ファイルの選択',
		'OK',
		'Asterisk');

	# 画像をアップロード
	'画像をアップロードします。'
	$Element = Get-SeElement -By XPath -Value '//*[@id="new_admin_other_files_zip_form"]/div/div[3]/div/div/input'
	Invoke-SeClick -Element $Element -Action Click

	# 企画編集へ戻るためのボタンを取得
	$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div[2]/form[2]/div/div[1]/div[1]/input[1]'

	# 5回トライしてダメだったら終了する
	if	($Count -eq 5)
	{
		'画像ファイルの選択に失敗しました。プログラムを終了します。'
		Exit
	}
	$Count++
}
Invoke-SeClick -Element $Element -Action Click
# 確認ダイアログでOKボタンをクリック
SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

# ページ読み込み完了まで待機
sleep 1

# 本文入稿ボタンをクリック
'本文入稿ボタンをクリックします。'
$Element = Get-SeElement -By XPath -Value '//*[@class="head_link_4"]/div/div[2]'
Invoke-SeClick -Element $Element -Action Click
# 確認ダイアログでOKボタンをクリック
SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

# ページ読み込み完了まで待機
sleep 1

# 本文を入稿
'本文を入稿します。'
# Expand-Tab function from https://www.itprotoday.com/powershell/expanding-tabs-spaces-powershell
function Expand-Tab
{
	param([UInt32] $TabWidth = 8)
	process {
		$line = $_
		while ($True) {
			$i = $line.IndexOf([Char] 9)
			if ($i -eq -1) {
				break
			}
			if ($TabWidth -gt 0) {
				$pad = " " * ($TabWidth - ($i % $TabWidth))
			} else {
				$pad = ""
			}
			$line = $line -replace "^([^\t]{$i})\t(.*)$", "`$1$pad`$2"
		}
		$line
	}
}
$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[3]/div[2]/div[5]/div/textarea'
# タブは入力することができないので空白に変換する
Get-Content $YdFilePath | Expand-Tab > ${YdFilePath}'.spaces'
$FileContent = Get-Content -Raw ${YdFilePath}'.spaces'
Remove-Item ${YdFilePath}'.spaces'

# 変換後の本文を入力する
Invoke-SeKeys -Element $Element -Keys $FileContent

# HTMLへ変換
'HTMLへ変換します。'
$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[3]/div[2]/div[2]/div[2]/input'
Invoke-SeClick -Element $Element -Action Click

# 企画編集へ戻る
'企画編集へ戻ります。'
$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div/form/div[1]/div[1]/input[1]'
Invoke-SeClick -Element $Element -Action Click
# 確認ダイアログでOKボタンをクリック
SeShouldHave -Alert -PassThru | Clear-SeAlert -Action Accept

# ページ読み込み完了まで待機
sleep 1

# プレビュー(SP)を実行
'プレビュー(SP)を実行します。'
$Element = Get-SeElement -By XPath -Value '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[1]/div[2]/a[1]'
Invoke-SeClick -Element $Element -Action Click
