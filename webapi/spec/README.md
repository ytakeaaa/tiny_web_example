# Unit Testの実行

# はじめに

本書はUnit testを実行するために必要な環境構築手順です。

# 動作環境

CentOS-6.6にて動作確認を行いました。それよりも古い環境の場合は動作確認してませんので、ご了承下さい。

# Unit Test実行環境の構築

## mysql-serverの設定

Unit Testはデータベースアクセスを行うためmysql-serverのインストール及び設定を行います。

### mysql-serverのインストール

```
$ sudo yum install -y mysql-server
```
### mysql-serverの起動

```
$ sudo service mysqld start
```

### 自動起動設定

現在の設定を確認する

```
$ chkconfig --list mysqld
mysqld          0:off   1:off   2:off   3:off   4:off   5:off   6:off
```

mysqldの自動起動設定を有効化する

```
$ sudo chkconfig mysqld on
```

有効化した設定を確認する

```
$ chkconfig --list mysqld
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
```

### データベースの作成

```
$ mysqladmin -uroot create tiny_web_example
```
## ruby環境の設定

Unit Testではrpecを使用するためruby環境のインストールを行います。

### rubyのインストール

```
$ sudo yum install -y http://dlc.wakame.axsh.jp.s3.amazonaws.com/demo/ruby-rpm/rhel/6/x86_64/ruby-2.0.0p598-2.el6.x86_64.rpm
```

### bundlerのインストール

```
$ sudo gem install bundler --no-ri --no-rdoc
```

### bundle install実行時に必要なパッケージのインストール

```
$ sudo yum install -y mysql-devel
```

## Unit Test実行環境の設定

### ソースコードの取得

Gitを使用してリポジトリからソースコードを取得してください。

```
$ git clone https://github.com/axsh/tiny_web_example.git
```

### Gemパッケージのインストール

```
$ cd tiny_web_example/webapi
$ bundle install
```

### configファイルの設定

```
$ cd tiny_web_example/webapi/config
$ cp webapi.conf.example webapi.conf
```

### データベーステーブルの作成

```
$ cd tiny_web_example/webapi
$ bundle exec rake db:up
```

## Unit Testの実行

```
$ cd tiny_web_example/webapi/spec
$ cp webapi.conf.example webapi.conf
$ bundle exec rspec ./comment_spec.rb
``` 
