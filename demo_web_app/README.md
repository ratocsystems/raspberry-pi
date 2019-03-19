# Rapberry Pi クラウドデモWEBアプリケーション

- [概要](#概要)
- [機能](#機能)
- [動作環境](#動作環境)
- [依存ツール導入](#依存ツール導入)
- [データベース設定](#データベース設定)
- [インストール方法](#インストール方法)
- [アプリケーションの開始](#アプリケーションの開始)
- [アプリケーションの停止](#アプリケーションの停止)
- [データバックアップ](#データバックアップ)
- [デモWEBアプリインターフェース仕様](#デモWEBアプリインターフェース仕様)


## 概要

Raspberry Pi クラウドデモWEBアプリケーションは、Raspberry Piに搭載した弊社製品から取得したデータをデータベースへ格納しウェブブラウザからデータを確認することができるデモアプリです。
対象の製品は下記としています。

- [RPi-GP10](https://github.com/ratocsystems/rpi-gp10) Raspberry-Pi I2C絶縁型デジタル入出力ボード
- [RPi-GP40](https://github.com/ratocsystems/rpi-gp40) Raspberry-Pi SPI絶縁型アナログ入力ボード


## 機能

- RPi-GP10、RPi-GP40から取得したデータの格納
- RPi-GP10、RPi-GP40の格納データをブラウザから一覧表示


## 動作環境

下記の環境にて動作することを確認しています。

- Ubuntu 18.04 LTS
- Ruby 2.5.1
- Ruby on Rails 5.2.0
- PostgreSQL 10
- nginx 1.14.0


## 依存ツール導入

```sh
$ sudo apt-get install build-essential nodejs libpq-dev postgresql postgresql-client nginx
```


## データベース設定

データベースユーザー作成とパスワード設定
```sh
$ sudo -u postgres psql -c "CREATE USER demo_web_app CREATEDB;"
sudo -u postgres psql -c "ALTER ROLE demo_web_app with password 'demo_web_app_password';"
```


## インストール方法

### コード取得

```sh
$ git clone https://github.com/ratocsystems/raspberry-pi/demo_web_app
```
### nginx設定ファイル

`lib/nginx/demo_web_app.conf`をベースに編集する。  
`{demo_web_app_path}`の箇所をdemo_web_appを配置したパスへ置き換える。  

```sh
$ sudo cp lib/nginx/demo_web_app.conf /etc/nginx/sites-available/demo_web_app.conf
$ sudo ln -s /etc/nginx/sites-available/demo_web_app.conf /etc/nginx/sites-enabled/demo_web_app.conf
$ sudo service nginx restart
```

### 設定ファイル準備

```sh
$ cd demo_web_app
$ cp config/database.yml.example config/database.yml
$ rm config/credentials.yml.enc
```
コピーした、`config/database.yml`のusernameとpasswordにデータベース設定で作成したユーザーとパスワードを設定する


### 環境構築

```sh
$ bundle install --path vendor/bundle
$ EDITOR="vi" bin/rails credentials:edit
$ bin/rake db:setup RAILS_ENV=production
$ bin/rake assets:precompile RAILS_ENV=production
```


## アプリケーションの開始

```sh
$ bundle exec puma -e production -C config/puma.rb -d
```


## アプリケーションの停止

```sh
$ kill -QUIT `(cat tmp/pids/server.pid)`
```


## データバックアップ

下記を実行することで、`tmp/backups/` へ `1550025021_2019_02_13_ver_demo_web_app_backup.sql.gz`のようなファイルが作成されます。

```sh
$ RAILS_ENV=production bin/rails demo_web_app:backup:create
```

データリストアは、バックアップファイル名から`_demo_web_app_backup.sql.gz`の部分を取り除いたものを指定して下記のように実行します。
```sh
$ RAILS_ENV=production bin/rails demo_web_app:backup:restore BACKUP=1550026691_2019_02_13_ver
```

## デモWEBアプリインターフェース仕様

デモWEBアプリインターフェース仕様については、別途[PDFファイル](./doc)の参照お願いします。
