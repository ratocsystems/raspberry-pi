# クラウドデモWEBアプリ用 RPi-GP10 Pythonプログラム

クラウドデモWEBアプリ用 RPi-GP10 Pythonプログラムの使用方法について説明します。  
Raspberry Piは'Raspberry Pi3 ModelB'、OSは'Raspbian Stretch with desktop(NOOBS:2018-11-13)'で説明します。
プログラムファイルは`GP10_demo.py`です。  

[クラウドWEBアプリケーション](https://github.com/ratocsystems/raspberry-pi/demo_web_app)が動作するサーバーへRPi-GP10から取得したデータをPOSTします。  
  
***
## 準備
### Raspberry PiにRPi-GP10を接続
[README.md](https://github.com/ratocsystems/rpi-gp10/blob/master/README.md)を参考に下記の準備をおこなってください。  
- OS(`RASPBIAN`)のインストール
- GPIO40pinのSPI設定
- 'Raspberry Pi'に'RPi-GP10'を接続  
  

### プログラムを実行するディレクトリを作成
1. 'mkdir'コマンドを使って'demo_web_app'という名前のディレクトリを作成します。(ディレクトリ名や作成場所は自由です)
    ```
    $ mkdir demo_web_app  
    ```

1. 'ls'コマンドを実行して'demo_web_app'ディレクトリが作成されていること確認します。
    ```
    $ ls  
    ```

1. 'cd'コマンドで'demo_web_app'ディレクトリに移動します。
    ```
    $ cd demo_web_app  
    ```  
    
### PythonプログラムファイルをGitHubからダウンロード  
GitHubからPythonファイルをダウンロードします。
1. GP10_demo.pyをダウンロード
    ```
    $ wget https://github.com/ratocsystems/raspberry-pi/raw/master/demo_web_python/GP10_demo/GP10_demo.py  
    ```  

1. `ls`コマンドを実行してダウンロードされていることを確認します。
    ```
    $ ls  
    GP10_demo.py
    ```
  
***
## Pythonプログラムファイルについて
  
`GP10_demo.py`  

HTTPのPOST通信によりJSON形式にてデジタル入力データを送信するPythonデモプログラムです。  
下記の処理を行っています。

1. **サーバーURL**  
    デモ運用のAmazon AWS EC2サーバーやローカルサーバーアドレスを記述します。  
    サーバー上では[クラウドWEBアプリケーション](https://github.com/ratocsystems/raspberry-pi/demo_web_app)の動作が必要です。 
    EC2サーバーの場合起動のたびにアドレスが変更されるため、記述を確認してくださいです。  

1. **RPi-GP10の初期設定 init_GP10()**  
    GPIOとI2Cの初期設定を行います。  
    ※<u>ハードウェアに依存する設定ですので変更しないでください。</u>  
    - GPIOをGPIO番号で指定するように設定
    - 絶縁回路用電源をONに設定  
        電源ON後、安定するまで待ちます。
    - ストローブ端子を出力に設定し、初期状態をHighにします。
    - トリガー端子を入力に設定し、初期状態をHighにします。
    - I2Cでポート0を出力・反転なしに設定し、出力端子として使用できるようにします。  
          方向設定: Configurationレジスタ`0x06`に`0x00`(全ビット出力)を書きます。  
          極性    : Polarity Inversionレジスタ`0x04`に`0x00`(全ビット反転なし)を書きます。  
    - I2Cでポート1を入力・反転ありに設定し、入力端子として使用できるようにします。  
          方向設定: Configurationレジスタ`0x07`に`0xFF`(全ビット入力)を書きます。  
          極性    : Polarity Inversionレジスタ`0x05`に`0xFF`(全ビット反転あり)を書きます。  

1. **有線LAN(eth0)のMACアドレス取得 getMAC(interface='eth0')**  
    MACアドレスを取得します。  
    MACアドレスはRaspberry Piデバイスの機器判別用IDとして使用されます。  

1. **指定間隔と回数でデジタル入力データをPOSTする post_di(intv, cnt)**  
    指定間隔intv[sec]と指定回数cnt[回]でデジタル入力値を取得し、POST通信でEC2サーバーへJSON形式にて保存します。
    - デジタル入力値取得
    - 現在時刻取得
    - 辞書形式変換
    - JSON形式でPOST要求実行
    - レスポンスコード表示

1. **引数による直接実行形式**  
    引数の指定があれば、指定された間隔で指定回数デジタル入力を実行し、結果をPOSTします。  

1. **引数なしの場合はメニュー実行形式**  
    引数の指定がなければ、メニュー実行形式でデジタル入力を実行します。  

1. **メニュー表示**  
    次のメニューを表示します。  
    `a:単一デジタル入力, b:連続デジタル入力, e:終了 >`

1. **a:単一デジタル入力 post_di(0, 1)**  
    間隔0秒で1回デジタル入力を実行し、結果をPOSTします。     

1. **b:連続AD変換 post_di(interval, cnt)**  
    指定した間隔と回数でデジタル入力を実行し、結果をPOSTします。
    `[CTRL]+[C]` で中断します。

1. **e:終了**  
    `[e:終了]`が選択されるとプログラムを終了します。  

***
## Pythonプログラムの使い方  
`python3`をつけて実行します。  

引数を付けて実行すると、直接形式でデジタル入力値をPOSTします。  
`例) ヘルプ表示後に、1秒間隔で5回デジタル入力のPOSTを実行する場合`  
~~~
$ python3 GP10_demo.py -h  
usage: メニュー形式でRPi-GP10を制御します  

引数を指定することで直接実行が可能です  

optional arguments:  
  -h, --help          show this help message and exit  
  -t [T], --time [T]  [T]= デジタル入力間隔(0,1-1000)[秒]を指定 0:TRGで入力 例: -t 1  
  -c [C], --cnt [C]   [C]= デジタル入力回数(1-1000)[回]を指定 例: -c 100  

--------------------------------------------------------------------------  
$ python3 GP10_demo.py -t 1 -c 5  
RPi-GP10 WEBアプリデモプログラム  
   1: DIN=0  
<Response [201]>  
   2: DIN=0  
<Response [201]>  
   3: DIN=0  
<Response [201]>  
   4: DIN=0  
<Response [201]>  
   5: DIN=0  
<Response [201]>  
$  
~~~

引数をつけずに実行すると、メニュー形式でデジタル入力値をPOSTします。  
~~~
$ python3 GP10_demo.py  
RPi-GP10 WEBアプリデモプログラム  
a:単一デジタル入力, b:連続デジタル入力, e:終了 >b  
 連続デジタル入力 間隔 1-1000[秒] >1  
 連続デジタル入力 回数 1-1000[回] >10  
   1: DIN=0  
<Response [201]>  
   2: DIN=0  
<Response [201]>  
   3: DIN=0  
<Response [201]>  
   4: DIN=0  
<Response [201]>  
   5: DIN=0  
<Response [201]>  
   6: DIN=0  
<Response [201]>  
   7: DIN=0  
<Response [201]>  
   8: DIN=0  
<Response [201]>  
   9: DIN=0  
<Response [201]>  
  10: DIN=0  
<Response [201]>  
a:単一デジタル入力, b:連続デジタル入力, e:終了 >e  
$  
~~~
- **HTTPレスポンスステータスコードについて**  
    "<Response [201]>"は、POSTリクエストが成功したことを示します。  
    詳細については、[レスポンスステータスコード](https://developer.mozilla.org/ja/docs/Web/HTTP/Status)を参照してください。  

