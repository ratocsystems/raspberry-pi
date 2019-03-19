# クラウドデモWEBアプリ用 RPi-GP90 Pythonプログラム

クラウドデモWEBアプリ用(ルーレット)の使用方法について説明します。  
Raspberry Piは'Raspberry Pi3 ModelB'、OSは'Raspbian Stretch with desktop'で説明します。
プログラムファイルは`rot_demo.py`です。  

  
***
### PythonプログラムファイルをGitHubからダウンロード  
GitHubからPythonファイルをダウンロードします。
1. rot_demo.pyをダウンロード
    ```
    $ wget https://github.com/ratocsystems/raspberry-pi/raw/master/demo_web_python/rot_demo/rot_demo.py  
    ```  

1. `ls`コマンドを実行してダウンロードされていることを確認します。
    ```
    $ ls  
    rot_demo.py
    ```
  
***
## Pythonプログラムファイルについて
  
`rot_demo.py`  

RPi-GP90のパルス入力機能を使用して、ルーレットの回転数[rpm]と回転角度[度]を測定し、
HTTPのPOST通信によりJSON形式にて測定データを送信するPythonデモプログラムです。  

対象のルーレットは、汎用的なロータリーエンコーダと同等のパルス信号(A-B-Z相)が出力され、
以下のようにRPi-GP90のパルス計測端子に接続します。  
- A相:PIA0,PIA1
- B相:PIB0,PIB1
- Z相:PIA3

パルス計測設定は以下の３種類を使用します。  
- Pulse-ch0:位相カウンタ(回転角度測定用) A相:PIA0, B相:PIB0, Z相:PIA3  
- Pulse-ch1:周期測定(低速回転数測定用)   A相:PIA1,(B相:PIB1 未使用)  
- Pulse-ch3:周期測定(高速回転数測定用)   Z相:PIA3  
