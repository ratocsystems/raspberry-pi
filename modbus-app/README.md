# Raspberry Pi Modbusスレーブアプリケーション

- [概要](#概要)
- [機能](#機能)
- [動作環境](#動作環境)
- [準備](#準備)
  - [シリアル通信ポート](#シリアル通信ポート)
  - [Modbusスレーブアプリケーションの設定](#Modbusスレーブアプリケーションの設定)
- [アプリケーションの実行](#アプリケーションの実行)
- [Modbus仕様について](#Modbus仕様について)
- [Modbusクライアントアプリケーション](#Modbusクライアントアプリケーション)

## 概要

Raspberry Pi Modbusスレーブアプリケーションは、Raspberry PiをModbusスレーブとして動作させるアプリケーションです。
Modbusからの制御対象として、Raspberry Piに搭載した下記の製品が対象としています。

* [RPi-GP10](https://github.com/ratocsystems/rpi-gp10) Raspberry-Pi I2C絶縁型デジタル入出力ボード
* [RPi-GP40](https://github.com/ratocsystems/rpi-gp40) Raspberry-Pi SPI絶縁型アナログ入力ボード


## 機能

- Modbusスレーブとして動作
- Modbus/TCP、Modbus/ASCII、Modbus/RTUに対応
- RPi-GP10: デジタル入力の取得、デジタル出力への設定
- RPi-GP10: トリガー入力の割り込み検知によるデジタル入力値の取得
- RPi-GP40: AD値の取得
- RPi-GP40: AD値のしきい値アラーム機能


## 動作環境

下記の環境にて動作することを確認しています。

- Rasbian GNU/Linux 9.6 (stretch)
- Python v3.5.3

Pythonライブラリ

- pymodbus v2.1.0
- pyserial v3.4
- pyserial-asyncio v0.4
- Twisted v18.9.0
- RPi.GPIO v0.6.5
- smbus2 v0.2.1
- spidev v3.2


## 準備

### シリアル通信ポート

シリアル通信を使用する場合は、シリアル通信モジュールが必要となります。
下記では、REX-USB70を使用した例です。

1. REX-USB70をUSBケーブルを接続します

1. ドライバのロード
    ```
    $ sudo modprobe ftdi_sio
    ```

1. ドライバをREX-USB70への対応付け
    ```
    $ sudo sh -c "echo 0584 b080 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id
    ```

1. ドライバが認識されてシリアルポートデバイスが作成されたことを確認
    ```
    $ ls /dev/ttyUSB*
    /dev/ttyUSB0
    ```

### Modbusスレーブアプリケーションの設定

config.ini.exampleをconfig.iniへコピーして、必要があれば設定を変更します。

1. protocol [rtu | ascii | tcp]

    Modbusの通信プロトコルを選択します。

1. debug [True | False]

    Modbusスレーブアプリケーション動作時のデバッグログを出力します。

1. host

    Modbus/TCPを使用するときの待ち受けアドレスを指定します。

1. port

    Modbus/TCPを使用するときの待ち受けポートを指定します。

1. device

    Modbus/ASCII, Modbus/RTUを使用するときのシリアルポートデバイスを指定します。

1. baudrate

    シリアル通信のボーレートを指定します。

1. enable [True | False]

    RPi-GP10, RPi-GP40の使用の有無を設定します。同時使用にも対応しています。

1. deviceid [1 - 247]

    Modbusのスレーブアドレスを指定します。

1. slave

    RPi-GP10のI2Cスレーブアドレスを設定します。

1. strobe [12 | 14]

    RPi-GP10のストローブ出力端子のGPIO番号を指定します。

1. trigger [13 | 15]

    RPi-GP10のトリガー入力端子のGPIO番号を指定します。

1. pin_output [12 | 14]

    RPi-GP40のデジタル出力端子GPIO番号を指定します。

1. pin_input [13 | 15]

    RPi-GP40のデジタル/アラーム入力端子GPIO番号を指定します。


## アプリケーションの実行

```
$ python3 main.py
Modbus Slave Application for Raspberry Pi v1.00
Protocol: RTU
Device: /dev/ttyUSB0
Baudrate: 9600
RPi-GP10 : True
  ID: 1
RPi-GP40 : True
  ID: 2
```

アプリケーションを終了するときは、CTRL-Cで終了します。


## Modbus仕様について

RPi-GP10とRPi-GP40のModbus通信仕様は、別途[PDFファイル](./doc)の参照お願いします。


## Modbusクライアントアプリケーション

このスレーブアプリケーションに対して、Raspberry-PiでModbusクライアント動作をするための参考用[クライアントツール](./Client)です。

