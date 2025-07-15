#!/usr/bin/env python3

import os
import time
import subprocess

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.select import Select

#========================================================================
# CMSでTECH+ニュース記事の初期値を設定
#========================================================================
def doit(driver,
         NameWriter = '後藤大地',
         NameApprover = '今林敏子',
         NameChannel = '企業IT',
         NameCategory = 'セキュリティ',
         PaymentDivision = 'コンテンツ開発1課',
         PriceText = '',
         PriceImage = '',
         Series = True):

    #========================================================================
    # 執筆者およびカテゴリを変更
    #========================================================================
    if 'takasyou' == os.environ['USER']:
        NameWriter = '杉山貴章'
        NameCategory = '開発/エンジニア'

    #========================================================================
    # 記事から必要データを抽出
    #========================================================================
    cmd = "grep title= typescript.yd | sed s/title=// | tr -d '\n'"
    proc = subprocess.Popen(
        cmd, shell = True,
        stdin = subprocess.PIPE,
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE)
    out, err = proc.communicate()
    Title = out.decode("utf-8", "strict")

    cmd = "grep SRC:http typescript.xml | sed 's/  <p>\\[SRC://' | sed 's,]</p>,,' | tr -d '\n'"
    proc = subprocess.Popen(
        cmd, shell = True,
        stdin = subprocess.PIPE,
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE)
    out, err = proc.communicate()
    URL = out.decode("utf-8", "strict")

    cmd = "grep '|photo_' typescript.yd | sed s/title=// | wc -l | awk '{print $1}' | tr -d '\n'"
    proc = subprocess.Popen(
        cmd, shell = True,
        stdin = subprocess.PIPE,
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE)
    out, err = proc.communicate()
    NumberOfImages = int(out.decode("utf-8", "strict"))

    TotalPriceImage = PriceImage * NumberOfImages

    #========================================================================
    # 必要項目を設定
    #========================================================================
    # 企画・掲載名を設定
    print('企画・掲載名を設定します。')
    Element = driver.find_element(By.ID, 'project_name')
    Element.send_keys(Title)
    
    # 承認者を設定
    print('承認者を設定します。')
    Element = driver.find_element(By.ID, 'project_approved_edited_admin_user_id')
    select = Select(Element)
    select.select_by_visible_text(NameApprover)
    
    # 即時公開チェックを設定
    print('即時公開チェックを設定します。')
    # 連載とニュース/レポートで「即時掲載フラグ」のXPathが異なるため 処理を
    # 切り分ける。
    if Series:
        Element = driver.find_element(By.XPATH,
                                      '//*[@id="head_link_2"]/div[2]/div[2]/div/label/div')
    else:
        Element = driver.find_element(By.XPATH,
                                      '//*[@id="head_link_2"]/div[2]/div[1]/div/label/div')
    Element.click()
    
    # チャンネルを設定
    if not Series:
        print('チャンネルを設定します。')
        Element = driver.find_element(By.ID, 'project_editing_index_item_attributes_channel_id')
        select = Select(Element)
        select.select_by_visible_text(NameChannel)
    
    # カテゴリを設定
    if not Series:
        print('カテゴリを設定します。')
        Element = driver.find_element(By.ID, 'project_editing_index_item_attributes_category_id')
        select = Select(Element)
        select.select_by_visible_text(NameCategory)
    
    # コメントを設定
    if URL:
        print('コメントを設定します。')
        Element = driver.find_element(By.ID, 'project_comment')
        Element.send_keys(URL)
    
    # 支払部門を設定
    print('支払部門を設定します。')
    Element = driver.find_element(By.ID, 'project_payment_division_id')
    select = Select(Element)
    select.select_by_visible_text(PaymentDivision)
    
    # 本文支払先を設定
    print('本文支払先を設定します。')
    Element = driver.find_element(By.ID, 'project_project_payees_attributes_0_author_id')
    select = Select(Element)
    select.select_by_visible_text(NameWriter)
    
    # 本文金額を設定
    print('本文金額を設定します。')
    Element = driver.find_element(By.ID, 'project_project_payees_attributes_0_price')
    Element.send_keys(PriceText)
    
    # 画像支払先を設定
    print('画像支払先を設定します。')
    Element = driver.find_element(By.ID, 'project_project_payees_attributes_1_author_id')
    select = Select(Element)
    select.select_by_visible_text(NameWriter)
    
    # 画像金額を設定
    print('画像金額を設定します。')
    Element = driver.find_element(By.ID, 'project_project_payees_attributes_1_price')
    Element.send_keys(TotalPriceImage)
