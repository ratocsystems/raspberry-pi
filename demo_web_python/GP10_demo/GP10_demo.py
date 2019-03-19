#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   Raspberry-pi 
#   "GP10_demo.py"
#   2019/03/01 R1.0
#   RATOC Systems, Inc. Osaka, Japan
#

import sys
import os
import time
import datetime
import argparse
import math
import requests
import smbus            #I2C制御用
import RPi.GPIO as GPIO #GPIO制御用
import json


# グローバル変数

  # サーバーURL
url="http://192.168.66.121:10080/"    # テスト用サーバー
#url="http://ec2-13-113-194-215.ap-northeast-1.compute.amazonaws.com/"   # デモ運用AWSサーバー

# RPi-GP10初期化
def init_GP10():   
    GPIO.setmode(GPIO.BCM)                          # Use Broadcom pin numbering
    GPIO.setup(27, GPIO.OUT, initial=GPIO.HIGH )    # GP10 絶縁電源ON
    GPIO.setup(STB, GPIO.OUT, initial=GPIO.LOW )    # STB出力設定 LOW (オープン)
    GPIO.setup(TRG, GPIO.IN, pull_up_down=GPIO.PUD_OFF)  # TRG入力設定
    time.sleep(0.5)                                 # 電源安定待ち
    i2c.write_byte_data(adrs, 0x04, 0x00)           # ポート0極性設定 反転なし
    i2c.write_byte_data(adrs, 0x05, 0xFF)           # ポート1極性設定 反転あり
    i2c.write_byte_data(adrs, 0x06, 0x00)           # ポート0方向設定 出力
    i2c.write_byte_data(adrs, 0x07, 0xFF)           # ポート1方向設定 入力

# 有線LAN(eth0)のMACアドレス取得
def getMAC(interface='eth0'):
    # Return the MAC address of the specified interface
    try:
        str = open('/sys/class/net/%s/address' %interface).read()
    except:
        str = "00:00:00:00:00:00"
    return str[0:17]

# 指定間隔と回数でデジタル入力データをpostする
def post_di(intv, cnt):                 # intv:間隔[sec] cnt:回数[回]
    for i in range(cnt):                                        # 指定回数繰り返し
        din = i2c.read_byte_data(adrs, 0x01)                    # ポート1入力 データ読み込み
        utctime = datetime.datetime.now(datetime.timezone.utc)  # UTC形式現在時刻を取得
        date = utctime.astimezone().isoformat()                 # ISO8601形式(usecあり)変換し、測定時刻とする
        dt_gp10["item"]["data"][0]["di"] =  "%d" % (din)        # デジタル入力
        dt_gp10["item"]["data"][0]["date"] = date               # 測定日時
        dt_gp10["item"]["data"][0]["beginning"] = beginning     # 開始日時
        print( "%4d: DIN=%d" % (i+1, din) )
        r = requests.post( url_gp10, data=json.dumps(dt_gp10), headers=hed )    # post
        print( r )                      # postレスポンスコード表示
        time.sleep(intv)                # post間隔待ち


###############################
# メイン
###############################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                prog='GP10_demo.py',          #プログラムファイル名
                usage='メニュー形式でRPi-GP10を制御します', #使用方法
                description='引数を指定することで直接実行が可能です',
                epilog=     '--------------------------------------------------------------------------',
                add_help=True,
                )
    #引数
    parser.add_argument('-t', '--time',  metavar='[T]'   , nargs=1, \
                        help='[T]= デジタル入力間隔(0,1-1000)[秒]を指定 0:TRGで入力 例: -t 1')
    parser.add_argument('-c', '--cnt',  metavar='[C]'   , nargs=1, \
                        help='[C]= デジタル入力回数(1-1000)[回]を指定 例: -c 100')
    args = parser.parse_args()  # 引数確認

    try:
        interval = 0                # 表示間隔 0:1回 1～1000[秒]

        # 引数取得
        if( args.time ):            # デジタル入力間隔
            interval = int(args.time[0],10)
        if( args.cnt ):             # デジタル入力回数
            cnt = int(args.cnt[0],10)
    
        # RaspberryPi I2C機能設定
        i2c=smbus.SMBus(1)      # RPi-GP10はI2C1を使用
        adrs=0x20               # TCA9535 I2Cアドレス 0x20 (RA1～RA6)
        STB=14                  # STB出力 GPIO14(JP7:Default) / GPIO12(JP8)
        TRG=15                  # TRG入力 GPIO15(JP5:Default) / GPIO13(JP6)

        url_gp10 = url+"gp10s.json"                         # RPi-GP10(デジタル入力)データ
        dt_gp10 = {             # JSON形式変換用辞書型定義
            "type": "gp10", 
            "item": {
                "machine": { "mac": "11:22:33:44:55:66" }, 
                "data": [ 
                    { "di": 255, "date": "2018-09-11T10:43:17+0900", "beginning": "2018-09-11T10:43:17+0900" }
                ]
            }
        }
        dt_gp10["item"]["machine"]["mac"] = getMAC( "eth0" )    # 有線LAN側のMACアドレス取得

        hed = {'content-type': 'application/json'}              # HTTPヘッダー

        print( "RPi-GP10 WEBアプリデモプログラム" )

        # RPi-GP10初期化
        init_GP10()

        utctime = datetime.datetime.now(datetime.timezone.utc)  # UTC形式現在時刻を取得
        date = utctime.astimezone().isoformat()                 # ISO8601形式(usecあり)変換し、測定開始時刻とする
        beginning = date

        # 引数による直接実行形式
        if( interval != 0 ):        # 引数指定があれば、
            post_di(interval, cnt)  # interval間隔でcnt回デジタル入力値をpostする
            GPIO.output(27, False)  # RPi-GP10の絶縁電源OFF
            GPIO.cleanup()
            sys.exit()              # プログラム終了

        # 引数なしのメニュー実行形式
        while True:
            # メニュー表示
            menu = input("a:単一デジタル入力, b:連続デジタル入力, e:終了 >")
            c = int(menu, 16)

            # 'a' 単一デジタル入力
            if( c==10 ):            
                post_di(0, 1)     # 間隔0で1回デジタル入力値をpostする

            # 'b' 連続デジタル入力
            if( c==11 ):            
                i = input(" 連続デジタル入力 間隔 1-1000[秒] >")
                interval = int(i)
                i = input(" 連続デジタル入力 回数 1-1000[回] >")
                cnt = int(i)
                post_di(interval, cnt) # interval間隔でcnt回デジタル入力値をpostする

            # 'e' 終了
            if( c==14 ):            
                break

    # 例外処理
    except KeyboardInterrupt:       # CTRL-C キーが押されたら、
         print( "中断しました" )    # 中断
    except Exception:               # その他の例外発生時
         print( "エラー" )          # エラー
    GPIO.output(27, False)          # RPi-GP10の絶縁電源OFF
    GPIO.cleanup()
    sys.exit()                      # プログラム終了
