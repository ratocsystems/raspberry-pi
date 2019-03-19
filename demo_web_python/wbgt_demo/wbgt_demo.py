#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   Raspberry-pi 
#   "wbgt_demo.py"
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
import serial           # Serial通信(SubGigUSBドングル通信用)
import binascii
import json
import numpy            # array用

# グローバル変数

  # サーバーURL
url="http://192.168.66.121:10080/"    # テスト用サーバー
#url="http://ec2-13-113-194-215.ap-northeast-1.compute.amazonaws.com/"   # デモ運用AWSサーバー


# 有線LAN(eth0)のMACアドレス取得
def getMAC(interface='eth0'):
    # Return the MAC address of the specified interface
    try:
        str = open('/sys/class/net/%s/address' %interface).read()
    except:
        str = "00:00:00:00:00:00"
    return str[0:17]

ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=20, 
                     parity = serial.PARITY_NONE,
                     stopbits = serial.STOPBITS_ONE,
                     bytesize = serial.EIGHTBITS )
CR= 13    #0x0d
LF= 10    #0x0a
tx_crlf = bytes([ CR, LF ])
tx_cr = bytes([ CR ])

#  Send and Receive on Wi-SUN 

def wisun_tx_cmd( cmd ):
    ser.write( cmd )
    ser.write(tx_crlf)
    return

def wisun_tx_cmd_wolf( cmd ):       # tx command with <CR> for ROPT, WOPT
    ser.write( cmd )
    ser.write(tx_cr)
    return

def wisun_tx_cmd_wocrlf( cmd ):      # tx command without <CR><LF> for SKSENDTO
    ser.write( cmd )
    #ser.write(tx_crlf)
    return

def wisun_rcv_eb():
    rcv_echo= ser.readline()
    return rcv_echo

def wisun_rcv_data():
    rcv_data = ser.readline()
    return rcv_data

def wisun_rcv_ack():
    rcv_ack = ser.readline()
#    print( 'ACK; ', end=' ')
#    print( rcv_ack )
    if rcv_ack[0:2] == b'OK':
        rtn_cd = 0
    else:
        rtn_cd = 1
    return rtn_cd
   


# -------------------------------------------
#    Rohm BP35C2 USB Wi-SUN Dongle initialize
# -------------------------------------------

def bp35c2_init():

#    Disable echo-back mode.  After Power-ON reset, Echo back mode is 'ON' in defaul.t
    cmd = b'SKSREG SFE 0'
    wisun_tx_cmd( cmd )
    rcv_echo = wisun_rcv_eb()           # get last echo back
#    print( 'Echo back : ', end=' ' )
#    print( rcv_echo )

    if rcv_echo == '':
        print( 'BP35C2 is not found ! ')  # FTDI USB timeout error --> Fatal error! BP35C2がない
        exit()

    if rcv_echo[0:4] != b'OK\r\n':             # BP35C2 is already in No-Echo back mode
        rtn_cd = wisun_rcv_ack()
#        print( 'Return Code : ', end=' ' )
#        print( rtn_cd )

        if rtn_cd != 0:
            print( 'BP35C2 command error')
            exit()

#  Set ch.33 on 922,5NHz

    cmd = b'SKSREG S2 21'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode
#    print( 'SKSREG S2 Return Code : ', end=' ' )
#    print( rtn_cd )

    if rtn_cd != 0:
        print( 'BP35C2 command error')
        exit()

#  Set Rcv_RSSI for ERXUDP Event

    cmd = b'SKSREG SA2 1'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode
#    print( 'SKSREG SA2 Return Code : ', end=' ' )
#    print( rtn_cd )

    if rtn_cd != 0:
        print( 'BP35C2 command error')
        exit()

#  Set PAN ID

    cmd = b'SKSREG S3 1234'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode
#    print( 'SKSREG S3 Return Code : ', end=' ' )
#    print( rtn_cd )

    if rtn_cd != 0:
        print( 'BP35C2 command error')
        exit()

#  Set Beacon receiver mode.  Srart as Cordinater mode

    cmd = b'SKSREG S15 1'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode
#    print( 'SKSREG S15 Return Code : ', end=' ' )
#    print( rtn_cd )

    if rtn_cd != 0:
        print( 'BP35C2 command error')
        exit()

#  Set SKPARAM

    cmd = b'SKPARAM 1 1 3'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode
#    print( 'SKSREG S2 Return Code : ', end=' ' )
#    print( rtn_cd )

    if rtn_cd != 0:
        print( 'BP35C2 command error')
        exit()

#  Set Data format of ERXUDP

    cmd = b'ROPT'                     # get current OPT mode
    wisun_tx_cmd_wolf( cmd )

    rcv_data = ser.read(6)            # 'OK 00'<CR>
#    print( 'ROPT mode:', end=' ' )
#    print( rcv_data )

    if rcv_data[0] == b'O':     # 'O'?
        if rcv_data != b"OK 01\r":
            cmd = b'WOPT 01'
            wisun_tx_cmd_wolf( cmd )           # without <LF>
            rtn_cd = ser.read(3)               # without <LF>

#  Set Waiting port for UDP


    cmd = b'SKUDPPORT 4 0100'
    wisun_tx_cmd( cmd )

    rtn_cd = wisun_rcv_ack()           # BP35C2 is already in No-Echo back mode

#   Get IPV6 information
#
    cmd = b'SKINFO'
    wisun_tx_cmd( cmd )

    rcv_data = wisun_rcv_data()
#    print( 'Receive data:', end=' '  )
#    print( rcv_data )
    
    if rcv_data[0] == b'S':                # commnd echo backだったら　続けてEINFOを読み出す 
        rcv_data == wisun_rcv_data()
#        print( "Receive data : ", end=' ' )
#        print( rcv_data )

    rtn_cd = wisun_rcv_ack()              # OK<CRLF> ?
    if rtn_cd != 0:
       print( 'SKINFO command error' )

    return



#   センサーデバイスをScanしてそれぞれのMACアドレスを集める

def wisun_scan_device():

    cmd = b'SKSCAN 2 00000001 6 0'
    wisun_tx_cmd( cmd )
    rcv_data = wisun_rcv_data()     # SCAN Commandに対してまずBP35C2から'OK\r\n'が返される。
#    print( 'SKSCAN ACK :', end=' ' )
#    print( rcv_data )

    lpctr = 0
    for lpctr in range(10):
        rcv_echo= ser.readline()
#        print( '-----#', end=' ' )
#        print( lpctr+1 )
#        print( 'Event ACK:', end=' ' )
#        print( rcv_echo )

        if rcv_echo[0:5] != b'EVENT':
            return lpctr

        ack_num = rcv_echo[6:8]
#        print( 'ack_num : ', ack_num )

        if ack_num == b'22':
            return lpctr

        if ack_num == b'20':
            for cnt in range(8):
                rcv_echo= ser.readline()
#                print( 'Receive data :', end=' ' ) 
#                print( cnt + 1, end=' ')
#                print( rcv_echo )

                if rcv_echo[2:6] == b'Addr':
                    mac_adrs[lpctr] = rcv_echo[7:23]
                    print('デバイス番号', lpctr+1, 'Address:', mac_adrs[lpctr])
    lpctr = 10
    return lpctr

# Get temp and convert from binHex to int.

def get_tmp_int( temp_H, temp_L ):
    th1 = temp_H + temp_L
    th2 = binascii.unhexlify( th1 )
    th3 = int.from_bytes( th2, byteorder = 'big' )
    #print( th3 / 10 , '度' )
    return th3

# Get Date snf Timetemp and convert from binHex to int.

def get_time_date():
    yy1 = senser_data[17:19] + senser_data[15:17]
    yy2 = get_int( yy1 )
    mm1 = senser_data[13:15]
    mm2 = get_int( mm1 )
    dd1 = senser_data[11:13]
    dd2 = get_int( dd1 )
    hh1 = senser_data[9:11]
    hh2 = get_int( hh1 )
    mn1 = senser_data[7:9]
    mn2 = get_int( mn1 )
    dt_tm = str( 2000+yy2 ) +'/'+ str(mm2) +'/'+ str(dd2) +' '+ str(hh2) +';'+ str(mn2 )
    return dt_tm


def get_int( dt1 ):
    dt2 = binascii.unhexlify( dt1 )
    dt3 = int.from_bytes( dt2, byteorder = 'big' )
    return dt3

# 現在時刻（＋指定秒数）取得
def get_datetime_now( dly ):
    d = datetime.datetime.now()
    d = d + datetime.timedelta(seconds=dly)    # 現在時刻＋指定秒数
    date1 = d.timetuple()
#    print( d )
#    print( date1 )
    yy1 = date1.tm_year % 100   # 年 下2桁
    mm1 = date1.tm_mon
    dd1 = date1.tm_mday
    hh1 = date1.tm_hour
    mn1 = date1.tm_min
    ss1 = date1.tm_sec
    wd1 = date1.tm_wday + 1     # 1=月 ... 7=日
    dtb = ss1.to_bytes(1,'big')+mn1.to_bytes(1,'big')+hh1.to_bytes(1,'big')+dd1.to_bytes(1,'big')+mm1.to_bytes(1,'big')+yy1.to_bytes(1,'big')+wd1.to_bytes(1,'big')

#    print( dtb )

    return dtb

"""
# 乾球温度dgd[℃]と相対湿度RH hpd[%] から、相対湿度表より湿球温度算出
def get_wet(dgd,hpd):
    dgw = dgd                  # dgw: 湿球温度[℃]
    if( 0<=dgd<=60 ):
        dgw = dgd - 15.0       # 温度差がテーブル外だった場合用に最大値で減算
        i = int( dgd/2 )       # i = 相対湿度表の乾球温度軸
        for j in range(15):    # j = 相対湿度表の温度差(0～14=1～15℃)
            dt0 = float(hum_ary[i,j])        # 判定基準湿度
            if( i>=30 ):       # 乾球温度がテーブル最大の場合
                dt2 = dt0
            else:
                dt2 = float(hum_ary[i+1,j])  # 判定基準湿度　乾球＋2℃
            if( j==0 ):        # 温度差が1℃の場合
                dt1 = 100.0
                dt3 = 100.0
            else:
                dt1 = float(hum_ary[i,j-1])  # 判定基準湿度　湿球-1℃
                if( i>=30 ):   # 乾球温度がテーブル最大の場合
                    dt3 = dt1
                else:
                    dt3 = float(hum_ary[i+1,j-1])  # 判定基準湿度　乾球＋2℃,湿球-1℃
            dmul = (dgd - (float(i)*2.0))/2.0    # 乾球温度線形補正値
            dta = (dt2-dt0)*dmul+dt0             # 相対湿度下限線形補正値
            dtb = (dt3-dt1)*dmul+dt1             # 相対湿度上限線形補正値
            if( dtb>hpd>=dta ):
                dgw = dgd-( float(j+1)-((hpd-dta)/(dtb-dta)) ) # 湿球温度算出
                break
    return( dgw )
"""

# 乾球温度dgd[℃]と乾球と湿球の差dif[℃]と気圧prs[hPa]と風wind 1:有,0:無 から、相対湿度を算出
def get_hum(dgd,dif,prs,wind):
    if(wind):
        kmul = 0.000662   # 通風時の係数
    else:
        kmul = 0.0008     # 無風時の係数
    hpd =((6.11*10**(7.5*(dgd-dif)/((dgd-dif)+237.3)))-kmul*prs*(dif))/(6.11*10**(7.5*dgd/(dgd+237.3)))*100  # 相対湿度計算
    if( hpd<0.0 ):
        hpd = 0.0
    return( hpd )

# 乾球温度dgd[℃]と相対湿度RH hpd[%]と気圧prs[hPa]と風wind 1:有,0:無  から、湿球温度算出
def get_wet2(dgd,hpd,prs,wind):
    dgw = dgd                  # dgw: 湿球温度[℃]
    if( 0<=dgd<=60 ):
        dgw = dgd - 15.0       # 温度差が想定外だった場合用に最大値で減算
        for j in range(15):    # j = 相対湿度表の温度差(0～14=1～15℃)
            dt0 = get_hum(dgd,float(j+1),prs,wind)
            dt1 = get_hum(dgd,float(j),prs,wind)
            if( dt1>hpd>=dt0 ):
                dgw = dgd-( float(j+1)-((hpd-dt0)/(dt1-dt0)) ) # 湿球温度算出
                break
    return( dgw )




###############################
# メイン
###############################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                prog='wbgt_demo.py',          #プログラムファイル名
                usage='CM3MB IoT WBGTデモプログラム', #使用方法
                description='引数なし',
                epilog=     '--------------------------------------------------------------------------',
                add_help=True,
                )

    interval = 0                # 表示間隔 0:1回 1～1000[秒]
    """
    # 相対湿度[%]表 (室内・無風)
    hum_ary = numpy.array([   
        #   1,    2,    3,    4,    5,    6,    7,    8,    9,   10,   11,   12,   13,   14,   15 ← 乾球温度と湿球温度の差[℃]
        [79.7, 59.8, 40.4, 21.3,  2.6,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 0 ↓乾球温度[℃]
        [81.6, 63.6, 46.0, 28.8, 12.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 2
        [83.2, 66.8, 50.9, 35.3, 20.0,  5.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 4
        [84.6, 69.6, 55.0, 40.8, 26.9, 13.3,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 6
        [85.8, 72.1, 58.7, 45.6, 32.9, 20.5,  8.4,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 8
        [86.9, 74.2, 61.8, 49.8, 38.1, 26.6, 15.5,  4.7,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 10
        [87.8, 76.0, 64.5, 53.4, 42.6, 32.0, 21.8, 11.8,  2.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],  # 12
        [88.6, 77.6, 66.9, 56.5, 46.5, 36.7, 27.2, 18.0,  9.0,  0.2,  0.0,  0.0,  0.0,  0.0,  0.0],  # 14
        [89.3, 79.0, 69.0, 59.3, 49.9, 40.8, 32.0, 23.4, 15.0,  6.9,  0.0,  0.0,  0.0,  0.0,  0.0],  # 16
        [90.0, 80.2, 70.8, 61.8, 52.9, 44.4, 36.1, 28.1, 20.3, 12.7,  5.4,  0.0,  0.0,  0.0,  0.0],  # 18
        [90.5, 81.3, 72.5, 63.9, 55.6, 47.6, 39.8, 32.3, 25.0, 17.9, 11.0,  4.3,  0.0,  0.0,  0.0],  # 20
        [91.0, 82.3, 73.9, 65.8, 58.0, 50.4, 43.1, 35.9, 29.1, 22.4, 15.9,  9.7,  3.6,  0.0,  0.0],  # 22
        [91.4, 83.2, 75.2, 67.5, 60.1, 52.9, 45.9, 39.2, 32.7, 26.4, 20.3, 14.4,  8.7,  3.1,  0.0],  # 24
        [91.8, 83.9, 76.3, 69.0, 61.9, 55.1, 48.5, 42.1, 36.0, 30.0, 24.2, 18.6, 13.2,  8.0,  2.9],  # 26
        [92.2, 84.6, 77.4, 70.4, 63.6, 57.1, 50.8, 44.7, 38.8, 33.2, 27.7, 22.4, 17.3, 12.3,  7.5],  # 28
        [92.5, 85.3, 78.3, 71.6, 65.1, 58.9, 52.8, 47.0, 41.4, 36.0, 30.8, 25.7, 20.8, 16.1, 11.6],  # 30
        [92.8, 85.8, 79.1, 72.7, 66.5, 60.5, 54.7, 49.1, 43.8, 38.6, 33.6, 28.7, 24.1, 19.6, 15.2],  # 32
        [93.0, 86.3, 79.9, 73.7, 67.7, 61.9, 56.4, 51.0, 45.8, 40.9, 36.1, 31.4, 27.0, 22.6, 18.5],  # 34
        [93.3, 86.8, 80.6, 74.6, 68.8, 63.2, 57.9, 52.7, 47.7, 42.9, 38.3, 33.9, 29.6, 25.4, 21.4],  # 36
        [93.5, 87.2, 81.2, 75.4, 69.8, 64.4, 59.3, 54.3, 49.5, 44.8, 40.4, 36.1, 31.9, 27.9, 24.1],  # 38
        [93.7, 87.6, 81.8, 76.2, 70.7, 65.5, 60.5, 55.7, 51.0, 46.5, 42.2, 38.1, 34.1, 30.2, 26.5],  # 40
        [93.9, 88.0, 82.3, 76.8, 71.6, 66.5, 61.7, 57.0, 52.5, 48.1, 43.9, 39.9, 36.0, 32.3, 28.7],  # 42
        [94.0, 88.3, 82.8, 77.5, 72.4, 67.5, 62.7, 58.2, 53.8, 49.5, 45.5, 41.6, 37.8, 34.2, 30.7],  # 44
        [94.2, 88.6, 83.2, 78.1, 73.1, 68.3, 63.7, 59.3, 55.0, 50.9, 46.9, 43.1, 39.4, 35.9, 32.5],  # 46
        [94.3, 88.9, 83.7, 78.6, 73.8, 69.1, 64.6, 60.3, 56.1, 52.1, 48.2, 44.5, 40.9, 37.5, 34.2],  # 48
        [94.5, 89.2, 84.1, 79.1, 74.4, 69.8, 65.4, 61.2, 57.1, 53.2, 49.4, 45.8, 42.3, 39.0, 35.7],  # 50
        [94.6, 89.4, 84.4, 79.6, 75.0, 70.5, 66.2, 62.1, 58.1, 54.3, 50.6, 47.0, 43.6, 40.3, 37.2],  # 52
        [94.7, 89.7, 84.8, 80.1, 75.5, 71.1, 66.9, 62.9, 59.0, 55.2, 51.6, 48.2, 44.8, 41.6, 38.5],  # 54
        [94.8, 89.9, 85.1, 80.5, 76.0, 71.7, 67.6, 63.7, 59.8, 56.2, 52.6, 49.2, 45.9, 42.8, 39.7],  # 56
        [94.9, 90.1, 85.4, 80.9, 76.5, 72.3, 68.3, 64.4, 60.6, 57.0, 53.5, 50.2, 47.0, 43.9, 40.9],  # 58
        [95.0, 90.3, 85.7, 81.2, 77.0, 72.8, 68.9, 65.1, 61.4, 57.8, 54.4, 51.1, 48.0, 44.9, 42.0]]) # 60
    """

    try:

        hight = 0.0         # 標高[m]
        prs_hight = 1013.0*(1.0-0.0065*hight/(20.0+0.0065*hight+273.15))**5.257   # 気圧[hPa] 標高から概算の気圧を算出

        url_wbg = url+"wbgts.json"                             # WBGT指標データ
        dt_wbg = {
            "type": "wbgt", 
            "item": {
              "machine": { "mac": "11:22:33:44:55:66" }, 
              "data": [ 
                { "black": 22.2, "dry": 22.5, "wet": 19.9, "humidity": 47.1, "wbgt_data": 20.62, "date": "2018-09-11T10:43:17+0900", "beginning": "2018-09-11T10:43:17+0900" }
              ]
            }
          }
        dt_wbg["item"]["machine"]["mac"] = getMAC( "eth0" )    # 有線LAN側のMACアドレス取得

        hed = {'content-type': 'application/json'}             # HTTPヘッダー

        print( "IoT WBGTデモプログラム" )

        #time.sleep(1)
        print( 'Hi, Wi-SUN device. 熱中症警報システム Prototype Rev.1' ) 
        #ack = input('Ready ?')

        bp35c2_init()                # init. Rohm BP35C2 USB Wi-SUN Dongle

        modes = [' ', '室内/無風', '室内/通風', '室外']
        modem = 1

        key = 1

        while( key != 0 ):
            print( "1:WBGTデモ  2:計測モード変更[%s],気圧%.0f[hPa]" % (modes[modem], prs_hight), end=' ' )
            i = input( " > " )
            if( len(i) == 0 ):
                continue
            key = int(i,16)
            if( key == 0 ):         # '0'なら、
                break               # プログラム終了


            # IoTデモ
            while( key==1 ):        # '1' なら、デモ
                
                # Start SCAN
                print( '温度測定センサボックスのボタンを押してください' ) 
                ack = input('Ready ?')
                
                mac_adrs = [0,0,0,0,0,0,0,0,0,0]       # Senser_Device MAC address table
                ipv6_adrs = [0,0,0,0,0,0,0,0,0,0]      # Senser_Device IPV6 address table
                # thermo_name = ['黒球温度', '乾球温度', '相対湿度', 'Tank1', 'Tank2','Tank3','Tank4','Tank5','Tank6','Tank7']
                idnum = 0                         # センサー番号 [黒球, 乾球, 湿球]
                
                lpctr = wisun_scan_device()

                if lpctr == 0:
                    print( 'センサーデバイスを検出できませんでした。もう一度、' )
                    continue
                
                print( lpctr, end=' ' )
                print( '台のセンサーデバイスを検出しました。' )
                
                
                print( "黒球温度計デバイス番号 (1-%d) 0:再検索 " % lpctr, end=' ' )
                i = input( "> " )
                if( len(i)==0 ):
                    idnum = -1
                else:
                    idnum = int(i,10) - 1
                if( idnum < 0 ):
                    continue

                #  IPV6 addressに変換する
                ipv6_cnvcmd = b'SKLL64 ' + mac_adrs[idnum]
#                print('ipv6_cnvcmd : ', ipv6_cnvcmd )
                wisun_tx_cmd( ipv6_cnvcmd )
                rcv_ipv6_adrs = ser.readline()
                ipv6_adrs[idnum] = rcv_ipv6_adrs[0:39]
#                print('IPV6 address #', cntr, ipv6_adrs[idnum] )
                cmd = b'SKADDNBR '+ ipv6_adrs[idnum] + b' ' + mac_adrs[idnum]
                # print('SKADDNBR : ', cmd )
                wisun_tx_cmd( cmd )
                rcv_ack = ser.readline()
                # print('SKADDNBR ststus : ', rcv_ack )

                # A1 1分間強制パワーオン
                cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 0004 ' + b'\xaa\x02\xa1\x01'
                # print( cmd )
                wisun_tx_cmd_wocrlf( cmd )

                # A3 現在時刻、年月日の設定
                dtim = get_datetime_now( 0 )
                # print( dtim )
                # time.sleep( 1 )
                cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 000A ' + b'\xaa\x08\xa3' + dtim
                # print( cmd )
                wisun_tx_cmd_wocrlf( cmd )

                # A4 ウェイクアップ設定  60秒間隔 250ms
                cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 0005 ' + b'\xaa\x03\xa4\x3c\x19'
                # print( cmd )
                wisun_tx_cmd_wocrlf( cmd )

                print( "1分間隔でレコード数60で計測中..." )

                recode = 0
                
                while True:
                    #lpctr = 0
                    #for lpctr in range(10):
                    rcv_echo= ser.readline()
                    # print( 'Received :', end=' ' )
                    # print( rcv_echo )
                
                    if rcv_echo[0:6] == b'ERXUDP':
                        # print( 'Senser Data : ', end = ' ')
                        senser_data = rcv_echo[125:172]
                        # print( senser_data )
                
                        dtlength=senser_data[3:5]
                        if dtlength == b'15':
                            # 乾球温度
                            box_temp_L = senser_data[21:23]
                            box_temp_H = senser_data[23:25]
                        #    print( 'Temp in Box : ', box_temp_H, box_temp_L )
                            box_temp = get_tmp_int( box_temp_H, box_temp_L )
                            # 相対湿度
                            box_temp_L = senser_data[25:27]
                            box_temp_H = senser_data[27:29]
                        #    print( 'Humidity in Box : ', box_temp_H, box_temp_L )
                            box_humi = get_tmp_int( box_temp_H, box_temp_L )
                            # 黒球温度
                            box_temp_L = senser_data[17:19]
                            box_temp_H = senser_data[19:21]
                        #    print( 'Temp in Box : ', box_temp_H, box_temp_L )
                            black_ball_temp = get_tmp_int( box_temp_H, box_temp_L )
                            #mac_adrs_cur = rcv_echo[97:113]
                            #print('ERXUDP 発信元 Device', ' MACAddress:', mac_adrs_cur)
                            #idnum = mac_adrs.index( mac_adrs_cur, 0 )

                            #print( time_and_date, end=' ' )        # 現在時刻は測定データからではなく、システムから、
                            utctime = datetime.datetime.now(datetime.timezone.utc)   # UTC形式現在時刻を取得
                            date = utctime.astimezone().isoformat()                  # ISO8601形式(usecあり)変換
                            if( recode == 0 ):            # レコードの先頭なら、
                                beginning = date          # 開始時刻とする。

                            black = black_ball_temp/10                # 黒球温度 tb[℃]
                            dry = box_temp/10                         # 乾球温度 td[℃]
                            humidity = box_humi/10                    # 相対湿度 rh[%]
                            # wet = get_wet( dry, humidity )            # 湿球温度 tw[℃]
                            wet = get_wet2( dry, humidity, prs_hight, modem-1 )    # 湿球温度 tw[℃]
                        #    sr = 0      # 全天日射量(kW/m2)
                        #    ws = 0      # 平均風速(m/s)  ↓小野ら(2014) の式
                        #    wbgt_data = 0.735*dry+0.0374*humidity+0.00292*dry*humidity+7.619*sr-0.0572*ws-4.064
                            if( modem==3 ):   # 屋外
                                wbgt_data = 0.7*wet+0.2*black+0.1*dry     # WBGT=0.7×湿球温度Tw＋0.2×黒球温度Tg＋0.1×乾球温度Ta
                            else:             # 室内
                                wbgt_data = 0.7*wet+0.3*black             # WBGT=0.7×湿球温度Tw＋0.3×黒球温度Tg

                            dt_wbg["item"]["data"][0]["black"] = "%.1f" % (black)         # 黒球温度
                            dt_wbg["item"]["data"][0]["dry"] = "%.1f" % (dry)             # 乾球温度
                            dt_wbg["item"]["data"][0]["wet"] = "%.1f" % (wet)             # 湿球温度
                            dt_wbg["item"]["data"][0]["humidity"] = "%.1f" % (humidity)   # 相対湿度
                            dt_wbg["item"]["data"][0]["wbgt_data"] = "%.1f" % (wbgt_data) # WBGT
                            dt_wbg["item"]["data"][0]["date"] = date                   # 測定日時
                            dt_wbg["item"]["data"][0]["beginning"] = beginning         # 開始日時
                            # print( "======" )
                            # print( url_wbg )
                            # print( dt_wbg )
                            # print( "======" )

                            recode += 1

                            print( "%4d: 黒球温度 %.1f[℃], 乾球温度 %.1f[℃], 湿球温度 %.1f[℃], 相対湿度 %.1f[％], WBGT %.1f[℃]" %
                                ( recode, black, dry, wet, humidity, wbgt_data ) )
                            r = requests.post( url_wbg, data=json.dumps(dt_wbg), headers=hed )
                            print( r )
                            
                            if( recode >= 60 ):     # 60レコードで１連のデータとする
                                recode = 0

                        if dtlength == b'02':
                            cmd_cd1 = senser_data[5:7]
                            if cmd_cd1 == b'38':           # detect and get Beacon from Senser Device
                                # print(' Beacon(0x38) を検知しました ')
                                mac_adrs_cur = rcv_echo[97:113]
                                # print('ERXUDP_Beacon 発信元 Device', ' MACAddress:', mac_adrs_cur)
                                try:
                                    id = mac_adrs.index( mac_adrs_cur, 0 )
                                except:
                                    id = -1
                                if(idnum != id):   # MACアドレス不一致なら、
                                    continue       # 受信待ちへ。
                
                                #  A8 ワンショット計測実行コマンドを発行する
                                cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 0004 ' + b'\xaa\x02\xA8\x01'
                                # print( cmd )
                                wisun_tx_cmd_wocrlf( cmd )
                                time.sleep( 1 )
                
                
                    if rcv_echo[0:5] == b'EVENT':
                        ack_num = rcv_echo[6:8]
                        # print( 'ack_num : ', ack_num )
                
                        if ack_num == b'20':
                            # print(' Beacon を検知しました ')
                            for cnt in range(8):
                                rcv_echo= ser.readline()
                                # print( 'Receive data :', end=' ' ) 
                                # print( cnt + 1, end=' ')
                                # print( rcv_echo )
                
                                if rcv_echo[2:6] == b'Addr':
                                    mac_adrs_cur = rcv_echo[7:23]
                                    # print('Beacon 発信元 Device', lpctr+1, 'Address:', mac_adrs_cur)
                                    try:
                                        id = mac_adrs.index( mac_adrs_cur, 0 )
                                    except:
                                        id = -1
                            if(idnum != id):    # MACアドレスが不一致なら、
                                continue        #受信街へ待ちへ
                            #  A3 現在時刻、年月日の設定
                            dtim = get_datetime_now( 0 )
                            # print( dtim )
                            time.sleep( 1 )
                            cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 000A ' + b'\xaa\x08\xa3' + dtim
                            # print( cmd )
                            wisun_tx_cmd_wocrlf( cmd )

                            # A4 ウェイクアップ設定  60秒間隔 250ms
                            cmd = b'SKSENDTO 1 ' + ipv6_adrs[idnum] + b' 0E1A 0 0 0005 ' + b'\xaa\x03\xa4\x3c\x19'
                            # print( cmd )
                            wisun_tx_cmd_wocrlf( cmd )

                        elif ack_num == b'21':
                            # print( ' Status code を受信しました  code: ')
                            sts_cd = rcv_echo[51:53]
                            # print( sts_cd, end = ' ' )
                            #if sts_cd == b'00':
                            #    print( '送信完了' )
                            time.sleep( 1 )
                
                # print( 'ここまで' )
                while True:
                    rcv_event = ser.readline()
                #    print( 'Event : ', rcv_event )


            # シリアルデバッガ
            while( key == 2 ):      # '2'なら、計測モード設定
                i = input( " 計測モード 1:室内/無風 2:室内/通風 3:室外  900-1100:気圧変更  0:戻る > " )
                if( len(i) == 0 ):
                    continue
                mm = int(i,10)
                if( mm == 0 ):                       # 0なら初期メニューに戻る
                    break
                if( 1<=mm<=3 ):
                    modem = mm
                if( 900<=mm<=1100 ):
                    prs_hight = float(mm)


    except KeyboardInterrupt:       # CTRL-C キーが押されたら、
         print( "中断しました" )    # 中断
    except Exception:               # その他の例外発生時
         print( "エラー" )          # エラー
    ser.close()
    sys.exit()

