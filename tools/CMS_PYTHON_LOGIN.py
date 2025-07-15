#!/usr/bin/env python3

import os
from selenium import webdriver
from selenium.webdriver.common.by import By

#========================================================================
# マイナビCMSをオープンしてログインする
#========================================================================
def doit(driver):

    #========================================================================
    # CMSをオープン(ベーシック認証あり)
    #========================================================================
    BasicUser = 'news-cms'
    BasicPassword = 'YjUDs8H9K9Wz'
    BasicPath = 'manage.news.mynavi.jp/admin'
    URL = 'https://' + BasicUser + ':' + BasicPassword + '@' + BasicPath

    print('マイナビCMSを開きます。')
    driver.get(URL)
    print('マイナビCMSオープン完了。')

    #========================================================================
    # CMSへログイン
    #========================================================================
    CmsUser = 'daichi@ongs.co.jp'
    CmsPassword = 'WyvkQBE0qTYYQ'

    #========================================================================
    # ログイン者を変更
    #========================================================================
    fd = open('typescript.xml')
    contents = fd.readlines()
    fd.close()
    for line in contents:
        if 0 <= line.find('>杉山貴章<'):
            os.environ['USER'] = 'takasyou'
            break

    if 'takasyou' == os.environ['USER']:
        CmsUser = 'takasyou@gmail.com'
        CmsPassword = 'mqVpH2-abDuGVU'

    print('マイナビCMSへログインします。')

    # ユーザ名入力
    Element = driver.find_element(By.ID, 'admin_user_email')
    Element.send_keys(CmsUser)

    # パスワード入力
    Element = driver.find_element(By.ID, 'admin_user_password')
    Element.send_keys(CmsPassword)

    # ログインボタンをクリック
    Element = driver.find_element(By.NAME, 'commit')
    Element.click()

    print('マイナビCMSへログイン完了。')
