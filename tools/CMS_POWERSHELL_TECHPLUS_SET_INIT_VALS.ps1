#!/usr/bin/env pwsh

#========================================================================
# CMSでTECH+ニュース記事の初期値を設定
#========================================================================

#========================================================================
# 引数を処理
#========================================================================
Param(
	[String]$NameWriter = '後藤大地',
	[String]$NameApprover = '今林敏子',
	[String]$NameChannel = '企業IT',
	[String]$NameCategory = 'セキュリティ',
	[String]$NameShubetsu = 'ニュース',
	[String]$PaymentDivision = 'コンテンツ開発1課',
	[int]$PriceText = 4250,
	[int]$PriceImage = 200,
	[Switch]$Series
)

#========================================================================
# 執筆者およびカテゴリを変更
#========================================================================
if	('takasyou' -eq $env:Username) {
	$NameWriter = '杉山貴章' 
	$NameCategory = '開発/エンジニア'
}

#========================================================================
# レポート/ハウツーの場合には設定を変更
#========================================================================
$cwd = (Get-Location).Path
if ($cwd -like '*-REP') {
	$PriceText = 15000
	$PriceImage = 0
	$NameCategory = '開発/エンジニア'
	$NameShubetsu = 'レポート'
}
if ($cwd -like '*-HOW') {
	$PriceText = 15000
	$PriceImage = 0
	$NameCategory = '開発/エンジニア'
	$NameShubetsu = 'ハウツー'
}
if ($cwd -like '*-EXT') {
	$PriceText = 15000
	$PriceImage = 0
	$NameCategory = '開発/エンジニア'
	$NameShubetsu = 'レポート'
}

#========================================================================
# 記事から必要データを抽出
#========================================================================
$Raw = (Select-String -Pattern title= -Path typescript.yd | Out-String)
$Title = $Raw -replace 'typescript.yd:.:title=', ''

$Raw = (Select-String -Pattern '\[SRC:' -Path typescript.xml | Out-String)
$URL = $Raw -replace 'typescript.xml:.*SRC:', '' -Replace ']</p>',''

$NumberOfImages = (Select-String -Pattern '\|photo_' -Path typescript.yd).Length
$TotalPriceImage = $PriceImage * $NumberOfImages

#========================================================================
# 必要項目を設定
#========================================================================
# 企画・掲載名を設定
'企画・掲載名を設定します。'
$Element = Get-SeElement -By Id -Value project_name
Invoke-SeKeys -Element $Element -Keys $Title

# 承認者を設定
'承認者を設定します。'
$Element = Get-SeElement -By Id -Value project_approved_edited_admin_user_id
Set-SeSelectValue -Element $Element -Value $NameApprover

# 即時公開チェックを設定
'即時公開チェックを設定します。'
# 連載とニュース/レポートで「即時掲載フラグ」のXPathが異なるため 処理を
# 切り分ける。
if	($Series) {
	$Element = Get-SeElement 					`
		-By XPath 						`
		-Value '//*[@id="head_link_2"]/div[2]/div[2]/div/label/div'
} else {
	$Element = Get-SeElement 					`
		-By XPath 						`
		-Value '//*[@id="head_link_2"]/div[2]/div[1]/div/label/div'
}
Invoke-SeClick -Element $Element -Action Click

# チャンネルを設定
'チャンネルを設定します。'
$Element = Get-SeElement -By Id -Value project_editing_index_item_attributes_channel_id
Set-SeSelectValue -Element $Element -Value $NameChannel

# カテゴリーを設定
'カテゴリーを設定します。'
$Element = Get-SeElement -By Id -Value project_editing_index_item_attributes_category_id
Set-SeSelectValue -Element $Element -Value $NameCategory

# 記事種別を設定
'記事種別を設定します。'
$Element = Get-SeElement -By Id -Value project_editing_index_item_attributes_article_type
Set-SeSelectValue -Element $Element -Value $NameShubetsu

# コメントを設定
'コメントを設定します。'
if	("" -ne $URL) {
	$Element = Get-SeElement -By Id -Value project_comment
	Invoke-SeKeys -Element $Element -Keys $URL
}

# 支払部門を設定
'支払部門を設定します。'
$Element = Get-SeElement -By Id -Value project_payment_division_id
Set-SeSelectValue -Element $Element -Value $PaymentDivision

# 本文支払先を設定
'本文支払先を設定します。'
$Element = Get-SeElement -By Id -Value project_project_payees_attributes_0_author_id
Set-SeSelectValue -Element $Element -Value $NameWriter

# 本文金額を設定
'本文金額を設定します。'
$Element = Get-SeElement -By Id -Value project_project_payees_attributes_0_price
Invoke-SeKeys -Element $Element -Keys $PriceText

# 画像支払先を設定
'画像支払先を設定します。'
$Element = Get-SeElement -By Id -Value project_project_payees_attributes_1_author_id
Set-SeSelectValue -Element $Element -Value $NameWriter

# 画像金額を設定
'画像金額を設定します。'
$Element = Get-SeElement -By Id -Value project_project_payees_attributes_1_price
Invoke-SeKeys -Element $Element -Keys $TotalPriceImage
