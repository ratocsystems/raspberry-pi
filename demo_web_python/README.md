# クラウドデモWEBアプリ用Pythonプログラム

[クラウドWEBアプリ](https://github.com/ratocsystems/raspberry-pi/demo_web_app)が動作するサーバーへ、取得したデータをPOSTするRaspberry Pi用のPythonプログラムです。

## 対象製品

対象の製品は下記としています。

- [RPi-GP10](https://github.com/ratocsystems/rpi-gp10) Raspberry-Pi I2C絶縁型デジタル入出力ボード
- [RPi-GP40](https://github.com/ratocsystems/rpi-gp40) Raspberry-Pi SPI絶縁型アナログ入力ボード

また、展示会のデモで使用した以下の製品にも対応しています。（参考用）

- ルーレットデモ
  [RPi-GP90](https://github.com/ratocsystems/rpi-gp90) Raspberry-Pi I2C絶縁型パルス入出力ボード
- WBGT(暑さ指数)デモ
  [REX-SGPTS1](http://www.ratocsystems.com/products/subpage/smamoni/moromi1_kousei.html) Sub-GHz PT100品温センサー

## 製品別プログラム
- [GP10_demo](./GP10_demo/README.md)  
  RPi-GP10から取得したデジタルデータをサーバーへPOSTします。
- [GP40_demo](./GP40_demo/README.md)  
  RPi-GP40から取得したアナログデータをサーバーへPOSTします。
- [rot_demo](./rot_demo/README.md)  
  RPi-GP90から取得したルーレット回転数/角度データをサーバーへPOSTします。
- [wbgt_demo](./wbgt_demo/README.md)  
  REX-SGPTS1から取得した温湿度測定値と算出したWBGT(暑さ指数)値をサーバーへPOSTします。
