# Raspberry-Pi向けアプリケーション

Raspberry-Pi用の拡張ボードを使用した各種アプリケーションプログラムです。

## 対象製品
対象の製品は下記としています。

- [RPi-GP10](https://github.com/ratocsystems/rpi-gp10) Raspberry-Pi I2C絶縁型デジタル入出力ボード
- [RPi-GP40](https://github.com/ratocsystems/rpi-gp40) Raspberry-Pi SPI絶縁型アナログ入力ボード

## アプリケーション
- Raspberry Pi Modbusスレーブアプリ
  [modbus-app](https://github.com/ratocsystems/raspberry-pi/modbus-app) Raspberry PiをModbusスレーブデバイスとして動作するPythonアプリケーションです。
- Raspberry Pi グラウドWEBアプリ
  [demo_web_app](https://github.com/ratocsystems/raspberry-pi/demo_web_app) Raspberry PiクラウドWEBアプリケーションは、Raspberry Piに搭載した弊社製品から取得したデータをデータベースへ格納しウェブブラウザからデータを確認することができるデモアプリです。
  [demo_web_python](https://github.com/ratocsystems/raspberry-pi/demo_web_python) 取得したデータをクラウドWEBアプリが動作するサーバーへPOSTするRaspberry Pi用のPythonプログラムです。
