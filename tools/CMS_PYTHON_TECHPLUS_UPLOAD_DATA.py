#!/usr/bin/env python3

import os
import subprocess
import time

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.alert import Alert
from selenium.webdriver.support.select import Select
from selenium.webdriver.support import expected_conditions as EC

#========================================================================
# TECH+記事データをCMSへアップロードする
#========================================================================
def doit(driver,
         YdFilePath = 'typescript.yd'):

    #========================================================================
    # 入稿フローを実施
    #========================================================================
    # 更新ボタンをクリック
    print('更新ボタンをクリックします。')
    Element = driver.find_element(By.XPATH, '//*[@id="new_project"]/div[1]/div[2]/input[1]')
    Element.click()
    # 確認ダイアログでOKボタンをクリック
    Alert(driver).accept()
    
    # ページ再描画完了まで待機
    time.sleep(20)
    #
    #    # 当初は次の方法で待機処理を行ったが待機してくれなかった。
    #    # 原因は不明。このため上記スリープ処理で代替している。
    #    # スリープ処理では確実に動作させるために無駄に長めに待つ
    #    # ことになるが、ここで処理が失敗するよりはマシなのでこの
    #    # ようにしてある。これ以上短い時間には変更しない方が無難。
    #    #
    #    from selenium.webdriver.support.ui import WebDriverWait
    #    wait = WebDriverWait(driver, 5)
    #    失敗: wait.until(EC.presence_of_all_elements_located)
    # 
    #    from selenium.webdriver.support.ui import WebDriverWait
    #    wait = WebDriverWait(driver, 5)
    #    失敗: wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@class="head_link_4"]/div/div[1]')))
    
    # 素材入稿ボタンをクリック
    print('素材入稿ボタンをクリックします。')
    Element = driver.find_element(By.XPATH, '//*[@class="head_link_4"]/div/div[1]')
    #XXX 2023/05/30の朝までは以下のコードで動作したが、夕方には動作しなく
    #XXX なったので上記のように書き換え。
    #XXX Element = driver.find_element(By.XPATH, '//*[@id="head_link_4"]/div/div[1]')
    Element.click()
    # 確認ダイアログでOKボタンをクリック
    Alert(driver).accept()

    # ページ読み込み完了まで待機
    time.sleep(1)

    # 画像ファイルの選択
    print('画像ファイルを選択します。')
    Element = driver.find_element(By.XPATH, '//*[@id="admin_other_files_zip_form_zip_file"]')
    Element.send_keys(os.environ["HOME"] + '/Desktop/images.zip')
    
    # 画像をアップロード
    print('画像をアップロードします。')
    Element = driver.find_element(By.XPATH, '//*[@id="new_admin_other_files_zip_form"]/div/div[3]/div/div/input')
    Element.click()
    
    # 企画編集へ戻る
    print('企画編集へ戻ります。')
    Element = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/section[2]/div[2]/form[2]/div/div[1]/div[1]/input[1]')
    Element.click()
    # 確認ダイアログでOKボタンをクリック
    Alert(driver).accept()
    
    # ページ読み込み完了まで待機
    time.sleep(1)

    # 本文入稿ボタンをクリック
    print('本文入稿ボタンをクリックします。')
    #XXX 2023/05/30の朝までは以下のコードで動作したが、夕方には動作しなく
    #XXX なったので上記のように書き換え。
    #XXX Element = driver.find_element(By.XPATH, '//*[@id="head_link_4"]/div/div[2]')
    Element = driver.find_element(By.XPATH, '//*[@class="head_link_4"]/div/div[2]')
    Element.click()
    # 確認ダイアログでOKボタンをクリック
    Alert(driver).accept()
    
    # ページ読み込み完了まで待機
    time.sleep(1)

    # 本文を変数に格納
    cmd = 'cat typescript.yd'
    proc = subprocess.Popen(
        cmd, shell = True,
        stdin = subprocess.PIPE,
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE)
    out, err = proc.communicate()
    FileContent = out.decode("utf-8", "strict")

    # 本文を入稿
    print('本文を入稿します。')
    Element = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[3]/div[2]/div[5]/div/textarea')
    Element.send_keys(FileContent)
    
    # HTMLへ変換
    print('HTMLへ変換します。')
    Element = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[3]/div[2]/div[2]/div[2]/input')
    Element.click()
    
    # 企画編集へ戻る
    print('企画編集へ戻ります。')
    Element = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/section[2]/div/form/div[1]/div[1]/input[1]')
    Element.click()
    # 確認ダイアログでOKボタンをクリック
    Alert(driver).accept()
    
    # ページ読み込み完了まで待機
    time.sleep(1)

    # プレビュー(SP)を実行
    print('プレビュー(SP)を実行します。')
    Element = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/section[2]/div[2]/form/div[1]/div[2]/a[1]')
    Element.click()
