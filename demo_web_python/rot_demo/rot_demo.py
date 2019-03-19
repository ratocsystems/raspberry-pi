#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   Raspberry-pi 
#   "rot_demo.py"
#   2018/09/12 R1.0
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

# RPi-GP90初期化
def init_GP90():   
    GPIO.setmode(GPIO.BCM)                                # Use Broadcom pin numbering
    GPIO.setup(27,   GPIO.OUT, initial=GPIO.HIGH )        # RPi-GP90絶縁電源ON
    time.sleep(0.5)                                       # 電源安定待ち

# 有線LAN(eth0)のMACアドレス取得
def getMAC(interface='eth0'):
    # Return the MAC address of the specified interface
    try:
        str = open('/sys/class/net/%s/address' %interface).read()
    except:
        str = "00:00:00:00:00:00"
    return str[0:17]

# 計測データをpostする
def rot_post():
    dt_rot["item"]["data"][0]["rpm"] =   "%.1f" % (rpm)        # 回転数
    dt_rot["item"]["data"][0]["angle"] = "%.1f" % (angle)      # 角度
    dt_rot["item"]["data"][0]["date"] = date                   # 測定日時
    dt_rot["item"]["data"][0]["beginning"] = beginning         # 開始日時
#    print( "======" )
#    print( url_rot )
#    print( dt_rot )
    print( "%4d: pdata=%04X, angle=%.1f / rpm=%.1f / No.=%d" % (recode, pdata, angle, rpm, rnum[pdata>>1]) )
    r = requests.post( url_rot, data=json.dumps(dt_rot), headers=hed )
    print( r )
#    print( "======" )

# 位相カウント値の読み込みと絶対値変換
def get_pdata():
    pd = i2c.read_word_data(pccadrs, 0x06)    # ch0 カウントデータ(位相カウント値)を読み込み
#    print( "pdata=%04X" % (pdata) )
    if( pd & 0x8000 ):                        # bit15が'1'なら、
        pd = (rlen*2)-((~pd + 1) & 0xFFFF)    # 2の補数
    return pd


###############################
# メイン
###############################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                prog='iotdemo.py',          #プログラムファイル名
                usage='CM3MB IoT ルーレットデモプログラム', #使用方法
                description='引数なし',
                epilog=     '--------------------------------------------------------------------------',
                add_help=True,
                )

    interval = 0                # 表示間隔 0:1回 1～1000[秒]

    try:
    
        # RaspberryPi I2C機能設定
        i2c  = smbus.SMBus(1)       # RPi-GP90はI2C1を使用
        pwmadrs = 0x40              # PWMコントローラ    PCA9685 I2Cアドレス 0x40 (A3～A0)
        pccadrs = 0x30              # パルスカウント制御 STM32F0 I2Cアドレス 0x30

        url_rot = url+"rotations.json"                         # 回転データ
        dt_rot = {
            "type": "rotation", 
            "item": {
              "machine": { "mac": "11:22:33:44:55:66" }, 
              "data": [ 
                { "rpm": 22.2, "angle": 22.5, "date": "2018-09-11T10:43:17+0900", "beginning": "2018-09-11T10:43:17+0900" }
              ]
            }
          }
        dt_rot["item"]["machine"]["mac"] = getMAC( "eth0" )    # 有線LAN側のMACアドレス取得

        hed = {'content-type': 'application/json'}             # HTTPヘッダー

        # ルーレットの番号テーブル
        rnum = [ 0,26,3,35,12,28,7,29,18,22,9,31,14,20,1,33,16,24,5,10,23,8,30,11,36,13,27,6,34,17,25,2,21,4,19,15,32 ]
        rlen = len(rnum)

        # RPi-GP90初期化
        init_GP90()

        print( "IoT ルーレットデモプログラム" )
        key = 1

        while( key != 0 ):
            i = input( "D:ルーレットデモ  0:終了 > " )
            if( len(i) == 0 ):
                continue
            key = int(i,16)
            if( key == 0 ):         # '0'なら、
                break               # プログラム終了
            # IoTデモ
            while( key == 0x0d ):   # 'D'なら、ルーレットデモ開始
                print( "ルーレットのA相をPIA0とPIA1, B相をPIB0とPIB1, Z相をPIA3に接続してください。" )
                print( "ルーレットが回転すると指定間隔で測定を開始し、停止すると計測を終了します。" )
                i = input( "計測周期(1-300)[sec] 0:戻る > " )
                if( len(i) == 0 ):
                    continue
                intval = int(i,10)
                if( intval < 1 ):
                    break
                i2c.write_word_data( pccadrs, 0x06, 0x0000 )     # ch0 カウンタクリア
                i2c.write_word_data( pccadrs, 0x0E, 0x0000 )     # ch1 カウンタクリア
                i2c.write_word_data( pccadrs, 0x16, 0x0000 )     # ch2 カウンタクリア
                i2c.write_word_data( pccadrs, 0x1E, 0x0000 )     # ch3 カウンタクリア
                i2c.write_word_data( pccadrs, 0x00, 0x308F )     # Pulse-ch0 位相カウンタ, PIA-1 Z相 'L'でリセット
                i2c.write_word_data( pccadrs, 0x08, 0x4045 )     # Pulse-ch1 周期測定(低速回転用)
                i2c.write_word_data( pccadrs, 0x18, 0x4045 )     # Pulse-ch3 周期測定(高速回転用)
                tcnts = 0                    # 測定開始判定用計測データ更新カウンタ
                while( 1 ):
                    time.sleep( 0.5 )
                    event = i2c.read_word_data(pccadrs, 0x20)    # イベントデータを読み込み
                    if( event & 0x0001 ):    # 位相カウンタの更新があれば、
                        if( tcnts == 1 ):    # レコード開始のために、先頭データ用の、
                            utctime = datetime.datetime.now(datetime.timezone.utc) # UTC形式現在時刻を取得
                        tcnts+=1
                    else:
                        tcnts = 0
                    if( tcnts < 3 ):         # 3回連続(1秒間)して更新がなければ、
                        continue             # 更新待ちへ

                    print( url_rot )
                    print( "計測中(CTRL+C:中断)...." )

                    recode = 0
                    pdata = get_pdata()      # ch0 カウントデータ(位相カウント値)を読み込み
                    pdata2 = pdata

                    rpm = 0                  # 先頭データは 0[rpm]
                    angle = 360*pdata/(rlen*2)   # 角度[deg] = (360/(37*2))*pdata
#                   date = utctime.replace(microsecond=0).astimezone().isoformat()  # ISO8601形式(usecなし)変換し、測定開始時刻とする
                    date = utctime.astimezone().isoformat()                         # ISO8601形式(usecあり)変換し、測定開始時刻とする
                    beginning = date

                    recode += 1
                    rot_post()               # 先頭のデータ 0[rpm] をpost

                    tcnte = 0                # 測定終了判定用計測データ更新カウンタ
                    while( tcnte<2 ):        # 2回連続(2秒間)更新がなければ、測定開始待ちへ
                        utctime = datetime.datetime.now(datetime.timezone.utc)           # UTC形式現在時刻を取得
                        pdata = get_pdata()      # ch0 カウントデータ(位相カウント値)を読み込み
                        tsdata = i2c.read_word_data(pccadrs, 0x1A)   # ch3 キャプチャデータ(Z相 高速 周期測定値)を読み込み
                        tfdata = i2c.read_word_data(pccadrs, 0x0A)   # ch1 キャプチャデータ(A相 低速 周期測定値)を読み込み
                        event = i2c.read_word_data(pccadrs, 0x20)    # イベントデータを読み込み
#                        print( "tsdata=%04X, tfdata=%04X" % (tsdata, tfdata) )
                        if( tfdata == 0 ):       # 0除算対策
                            rpm = 0
                        else:
                            rpm = 60000000/(tfdata*50*rlen)   # 回転数(高速用)[rpm] = 60[s]/(tdata*50[us]*37スリット)
                        if( tfdata < 100 ):      # 低速回転の場合、精度向上のため位相パルスの周期測定値を使う。
                            if( tsdata == 0 ):   # 0除算対策
                                rpm = 0
                            else:
                                rpm = 60000000/(tsdata*50)    # 回転数(低速用)[rpm] = 60[s]/(tdata*50[us])
                        angle = 360*pdata/(rlen*2)            # 角度[deg] = (360/(37*2))*pdata
                        if( (event & 0x0001) == 0 ):  # 位相カウンタの更新がなければ、
                            rpm = 0                   # 回転数を 0[rpm] とする。
                            tcnte+=1
                        else:                         # 更新があれば、
                            tcnte = 0                 # 更新カウンタクリア。

                        pdata2 = pdata
#                       date = utctime.replace(microsecond=0).astimezone().isoformat()  # ISO8601形式(usecなし)変換
                        date = utctime.astimezone().isoformat()                         # ISO8601形式(usecあり)変換

                        recode += 1
                        rot_post()            # 測定データをpost

                        time.sleep(intval)    # 指定インターバル待ち
                    print( "回転停止しました。" )

    except KeyboardInterrupt:       # CTRL-C キーが押されたら、
         print( "中断しました" )    # 中断
#    except Exception:               # その他の例外発生時
#         print( "エラー" )          # エラー
    GPIO.output(27, False)          # RPi-GP90の絶縁電源OFF
    GPIO.cleanup()
    sys.exit()

