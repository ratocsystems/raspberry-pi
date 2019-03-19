#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   Raspberry-pi 
#   "GP40_demo.py"
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
#import smbus            #I2C制御用
import spidev           #SPI制御用
import RPi.GPIO as GPIO #GPIO制御用
import json


# グローバル変数
rstr = ["±10V","±5V","±2.5V","±1.25V","±0.5V","0-10V","0-5V","0-2.5V","0-1.25V","0-20mA","NONE"]   # レンジ文字列
chn  = [      0,     1,       2,        3,      11,      5,     6,       7,       15,       6,     0]   # レンジ選択レジスタへ書き込む値のテーブル
chu  = [  0x800, 0x800,   0x800,    0x800,   0x800,  0x000, 0x000,   0x000,    0x000,   0x000, 0x000]   # 実値変換減算値 0x800:バイポーラ 0x000:ユニポーラ
chm  = [   5.00,  2.50,    1.25,    0.625,  0.3125,   2.50,  1.25,   0.625,   0.3125,    5.00,   0.0]   # 実値変換乗算値 1LSB[mV](/[uA])
chr  = [0,0,0,0,0,0,0,0]         # ch0-7の入力レンジ初期値

  # サーバーURL
url="http://192.168.66.121:10080/"    # テスト用サーバー
#url="http://ec2-13-113-194-215.ap-northeast-1.compute.amazonaws.com/"   # デモ運用AWSサーバー


# RPi-GP40初期設定
def init_GP40():   
    GPIO.setmode(GPIO.BCM)                                # Use Broadcom pin numbering
    GPIO.setup(27,   GPIO.OUT, initial=GPIO.HIGH )        # RPi-GP40絶縁電源ON
    GPIO.setup(DOUT, GPIO.OUT, initial=GPIO.LOW )         # DOUT端子出力設定 LOW (=OFF:オープン)
    GPIO.setup(DIN,  GPIO.IN,  pull_up_down=GPIO.PUD_OFF) # DIN端子入力設定
    time.sleep(0.5)                                       # 電源安定待ち

# 指定chのレンジ選択レジスタ値を設定
def set_adrange(ch, r):
    wdat = [((5+ch)<<1)|1, r, 0x00, 0x00]     # chの入力レンジ設定
    rdat = spi.xfer2(wdat)

# 指定chのレンジ選択レジスタ値を取得
def get_adrange(ch):
    wdat = [((5+ch)<<1)|0, 0x00, 0x00, 0x00]  # chの入力レンジ取得
    rdat = spi.xfer2(wdat)
    return rdat[2]

# 指定chのAD変換データ取得
def get_addata(ch):
    wdat = [0xc0+(ch<<2), 0x00, 0x00, 0x00]   # ch'ch'をAD変換する
    rdat = spi.xfer2(wdat)                    # ch指定
    rdat = spi.xfer2(wdat)                    # ADデータ取得
    adat = (rdat[2]<<4)+(rdat[3]>>4)          # AD変換値
    return adat

# 指定間隔と回数でch0-7のAD変換実行と結果データをpostする
def post_adc(intv, cnt):                     # intv:表示間隔[sec] cnt:表示回数[回]
    for i in range(cnt):                      # 指定回数繰り返し
        utctime = datetime.datetime.now(datetime.timezone.utc)  # UTC形式現在時刻を取得
        date = utctime.astimezone().isoformat()                 # ISO8601形式(usecあり)変換し、測定時刻とする
        dt_gp40["item"]["data"][0]["date"] = date               # 測定日時
        dt_gp40["item"]["data"][0]["beginning"] = beginning     # 開始日時
        for adc in range(8):                  # ch0-7
            dt_gp40["item"]["data"][0]["ads"][adc]["channel"] = adc     # ch番号 0-7
            if( chr[adc]>8 ):                 # 無効chなら、
                print("%8s ch%d:        [---]" % 
                    (rstr[chr[adc]], adc) )   # AD変換なし
                dt_gp40["item"]["data"][0]["ads"][adc]["value"] = "0"     # 無効(0)
                dt_gp40["item"]["data"][0]["ads"][adc]["range"] = "0"     # 無効(±10Vレンジ)
            else:                             # 有効chなら、
                adat = get_addata(adc)        # ch'adc'をAD変換する
                volt = (adat-chu[chr[adc]])*chm[chr[adc]]/1000  # 入力レンジでの実値算出 = (AD変換値-減算値)x乗算値
                print("%8s ch%d:%8.4f[%03X]" % 
                    (rstr[chr[adc]], adc, volt, adat) )         # 結果表示
                dt_gp40["item"]["data"][0]["ads"][adc]["value"] = "%d" % (adat)     # AD値
                dt_gp40["item"]["data"][0]["ads"][adc]["range"] = "%d" % (chr[adc]) # 入力レンジ
        r = requests.post( url_gp40, data=json.dumps(dt_gp40), headers=hed )    # post
        print( r )                        # postレスポンスコード表示
        if( cnt>1 ):                      # 複数回なら、
            print("%5d/%d" %(i+1, cnt))   # 回数表示
        if( i<(cnt-1) ):
            time.sleep(intv)              # 表示間隔待ち
            sys.stdout.write("\033[10F")  # カーソルを10行上に移動
            sys.stdout.flush()
    print("")

# 有線LAN(eth0)のMACアドレス取得
def getMAC(interface='eth0'):
    # Return the MAC address of the specified interface
    try:
        str = open('/sys/class/net/%s/address' %interface).read()
    except:
        str = "00:00:00:00:00:00"
    return str[0:17]

###############################
# メイン
###############################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                prog='GP40_demo.py',          #プログラムファイル名
                usage='メニュー形式でRPi-GP40を制御します', #使用方法
                description='引数を指定することで直接実行が可能です',
                epilog=     '--------------------------------------------------------------------------',
                add_help=True,
                )
    #引数
    parser.add_argument('-r', '--range', metavar='[R]'  , nargs=8, \
                        help='[R]= 0:±10V 1:±5V 2:±2.5V 3:±1.25V 4:±0.5V 5:0-10V 6:0-5V 7:0-2.5V 8:0-1.25V 以外:無効 ' + \
                             'チャンネル0-7の入力レンジ(0-9)を指定 例: -r 0 0 5 5 6 6 6 8')
    parser.add_argument('-t', '--time',  metavar='[T]'   , nargs=1, \
                        help='[T]= AD変換間隔(1-1000)[秒]を指定 例: -t 1')
    parser.add_argument('-c', '--cnt',  metavar='[C]'   , nargs=1, \
                        help='[C]= AD変換回数(1-1000)[回]を指定 例: -c 100')
    args = parser.parse_args()  #引数確認

    interval = 0                # AD間隔 0:1回 1～1000[秒]
    cnt = 1                     # AD回数

    try:
        # 引数取得
        if( args.range ):           # 入力レンジ
            for adc in range(8):
                chr[adc] = int(args.range[adc], 16)
        if( args.time ):            # AD変換間隔
            interval = int(args.time[0],10)
        if( args.cnt ):             # AD変換回数
            cnt = int(args.cnt[0],10)

        # RaspberryPi SPI機能設定
        spi  = spidev.SpiDev()      # RPi-GP40はSPIを使用
        spi.open(0, 0)              #  SPI0, CEN0 でオープン
        spi.mode = 1                #  SPIクロック設定 CPOL=0(正論理), CPHA=1(H->Lでデータ取り込み)
        spi.max_speed_hz = 17000000 #  SPIクロック最大周波数(17MHz指定)
                                    #   ただし、2018年4月時点のカーネル仕樣では、指定値より実周波数が低くなる
                                    #   17MHz→10.5MHz, 10MHz→6.2MHz, 8MHz→5MHz, 28MHz→15.6MHz
        DOUT = 12                   # デジタル出力 GPIO12(JP8:Default) / GPIO14(JP7)
        DIN  = 13                   # デジタル入力 GPIO13(JP6:Default) / GPIO15(JP5)

        url_gp40 = url+"gp40s.json"      # RPi-GP40(デジタル入力)データ
        dt_gp40 = {             # JSON形式変換用辞書型定義
            "type": "gp40", 
            "item": {
                "machine": { "mac": "11:22:33:44:55:66" }, 
                "data": [ 
                    {
                    "ads": [
                        { "channel": 0, "value": 0, "range": 0 },
                        { "channel": 1, "value": 0, "range": 0 },
                        { "channel": 2, "value": 0, "range": 0 },
                        { "channel": 3, "value": 0, "range": 0 },
                        { "channel": 4, "value": 0, "range": 0 },
                        { "channel": 5, "value": 0, "range": 0 },
                        { "channel": 6, "value": 0, "range": 0 },
                        { "channel": 7, "value": 0, "range": 0 }
                        ], "date": "2018-09-11T10:43:17+0900", "beginning": "2018-09-11T10:43:17+0900"
                    }
                ]
            }
        }
        dt_gp40["item"]["machine"]["mac"] = getMAC( "eth0" )    # 有線LAN側のMACアドレス取得

        hed = {'content-type': 'application/json'}              # HTTPヘッダー

        print( "RPi-GP40 WEBアプリデモプログラム" )

        # RPi-GP40初期設定
        init_GP40()

        utctime = datetime.datetime.now(datetime.timezone.utc)  # UTC形式現在時刻を取得
        date = utctime.astimezone().isoformat()                 # ISO8601形式(usecあり)変換し、測定開始時刻とする
        beginning = date

        # 入力レンジ設定
        for adc in range(8):
            if( chr[adc]<=9 ):      # 有効chなら、
                set_adrange(adc, chn[chr[adc]])     # ch'c'の入力レンジ設定

        # 引数による直接実行形式
        if( interval != 0 ):        # 引数指定があれば、
            post_adc(interval,cnt)  # interval間隔でcnt回AD変換値をpostする
            GPIO.output(27, False)  # RPi-GP40の絶縁電源OFF
            GPIO.cleanup()
            sys.exit()              # プログラム終了

        # 引数なしのメニュー実行形式
        while True:

            # 各chの入力レンジ設定値表示
            print("ch:レンジ= 0:%s, 1:%s, 2:%s, 3:%s, 4:%s, 5:%s, 6:%s, 7:%s" % 
                (rstr[chr[0]], rstr[chr[1]], rstr[chr[2]], rstr[chr[3]], rstr[chr[4]], rstr[chr[5]], rstr[chr[6]], rstr[chr[7]]) )

            # メニュー表示
            menu = input("0-7:chレンジ設定, a:単一AD変換, b:連続AD変換, e:終了 >")
            c = int(menu, 16)

            # '0'～'7' ch入力レンジ設定
            if( (c>=0)and(c<=7) ):  
                print("入力レンジ 0:±10V 1:±5V 2:±2.5V 3:±1.25V 4:±0.5V 5:0-10V 6:0-5V 7:0-2.5V 8:0-1.25V a:無効")
                d = input("ch%d 入力レンジ >" % c )
                chr[c] = int(d, 16)
                if( chr[c] <= 8 ):
                    set_adrange(c, chn[chr[c]])     # ch'c'の入力レンジ設定

            # 'a' 単一AD変換
            if( c==10 ):            
                post_adc(0, 1)     # 間隔0で1回AD変換値をpostする

            # 'b' 連続AD変換
            if( c==11 ):            
                i = input(" 連続AD変換 間隔 1-1000[秒] >")
                interval = int(i)
                i = input(" 連続AD変換 回数 1-1000[回] >")
                cnt = int(i)
                post_adc(interval, cnt) # interval間隔でcnt回AD変換値をpostする

            # 'e' 終了
            if( c==14 ):            
                break

    # 例外処理
    except KeyboardInterrupt:       # CTRL-C キーが押されたら、
         print( "中断しました" )    # 中断
    except Exception:               # その他の例外発生時
         print( "エラー" )          # エラー
    GPIO.output(27, False)          # RPi-GP40の絶縁電源OFF
    GPIO.cleanup()
    sys.exit()                      # プログラム終了
