# クラウドデモWEBアプリ用 WBGT:暑さ指数 Pythonプログラム

クラウドデモWEBアプリ用 WBGT(暑さ指数) の使用方法について説明します。  
プログラムファイルは`wbgt_demo.py`です。  

  
***
### PythonプログラムファイルをGitHubからダウンロード  
GitHubからPythonファイルをダウンロードします。
1. wbgt_demo.pyをダウンロード
    ```
    $ wget https://github.com/ratocsystems/raspberry-pi/raw/master/demo_web_app/python/wbgt_demo.py  
    ```  

1. `ls`コマンドを実行してダウンロードされていることを確認します。
    ```
    $ ls  
    wbgt_demo.py
    ```
  
***
## Pythonプログラムファイルについて
  
`wbgt_demo.py`  

[品温センサー](http://www.ratocsystems.com/products/subpage/smamoni/moromi1_kousei.html)を使用して、黒球温度,乾球温度,相対湿度を測定し、湿球温度,暑さ指数を算出します。
HTTPのPOST通信によりJSON形式にて測定/算出データを送信するPythonデモプログラムです。  
Raspberry PiのUSBポートに装着したSub-GHz USBアダプターREX-USBSG1を経由して、品温センサーREX-SGPTS1から測定データを取得します。

