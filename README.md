## 1. システム概要

paper_rails は Ruby on Rails で作成された多読を支援するためのウェブアプリケーションである。  
利用するためには、RailsやMVCの考え方についてある程度知っている必要がある。  
現在は、記事の収集・分析機能と管理者用の一覧表示、閲覧機能しかない。  

---
---

## 2. 依存関係

現在、動作確認ができている環境は以下の通りである。

* OS: Ubuntu Server 14.04
* 言語: Ruby 2.1.5
* フレームワーク: Ruby On Rails 4.1.7
* DB: PostgreSQL 9.3.6
* Git

ただ、Ruby、Ruby On Rails、PostgreSQL、[TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/)、git が利用できる環境であれば、  
どのようなOSでもおそらく動作すると思われる。  
※windowsはやめておいたほうがいい。


---
---

## 3. 環境構築

### 3.1 プログラムの取得

環境が構築されている場所に、GitLabからクローンする。  
クローンする際のコマンドは、以下の通りである。  
```bash
git clone http://confiserie.eng.kagawa-u.ac.jp:4545/eer/paper_rails.git
```

---

### 3.2 Gemのインストール

クローン後は、クローンしたディレクトリで以下のコマンドを叩く。
```bash
bundle install --path vendor/bundle
```
ubuntuの場合、pg周りでエラーがでる場合があるので、  
もしエラーが出たら以下のコマンドを実行する。
```bash
sudo apt-get install libpq-dev
```
---

### 3.3 DBの構築

DBを用意する手順を示す。  
流れとしては、postgresでユーザを作り、yamlデータをロードするという流れである。  
コマンドは、以下のようになる。  
コマンドは、クローンしたディレクトリ内で実行すること。
```bash
sudo su postgres
createuser -d paper_rails
exit
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rails c
load 'db/thesis_seeds.rb'
exit
```
最初の3行で、postgresql内にユーザを作っている。  
以上の手順を実行することで、システムが利用できるようになる。

---
---

## 4. 各機能について

### 4.1 記事の取得
#### コマンド実行による取得

記事については、以下のコマンドを叩くことで取得することができる。
```bash
bundle exec rake scrap_article:scrapping
```

#### 自動取得

また、Cronを利用して定期的に自動実行することもできる。
Cronへのタスクの登録方法は、
```bash
bundle exec whenever --update-cron
```
タスクの削除方法は、
```bash
bundle exec whenever --clear-cron
```
である。  
現在は、6時間周期で記事を収集する設定になっている。  
設定を変更したい場合は、 config/schedule.rb を変更すること。  

また、Slack通知の連係機能があり，  
.envファイルを作成後、SLACK_URLという環境変数を定義してあげることで  
収集結果をSlackに通知することができる。  
以下は、.envファイルの例である。  
.envファイルは、プロジェクトのルートディレクトリに作成すること。  
```
SLACK_URL="hogehogehoge"
```

### 4.2 記事の分析
#### 概要
このプロジェクトでは、DBに保存されている記事に対して、  
SVL12000を用いた出現単語の分析が可能である。  
下記に、それぞれ方法を示す。  
この分析では、あらかじめ、記事の形態素解析後データ(analysis_content)が  
DBに登録されている必要がある。  
そのため、場合によっては、下記のコマンドを実行しておくこと。

```
bundle exec rails console
Article.regist_analysis_contents
```

#### SVL12000に出現する単語の頻度を数える場合
コマンドを以下に示す。
```
bundle exec rails console
WordAggregate.aggregate_englishword("2015/1/12", "2015/2/3")
```
上記コマンドにより、 data/出現単語_難易度別.csv というファイルが作成される。  


#### SVL12000に出現しない単語の頻度を数える場合
コマンドを以下に示す。
```
bundle exec rails console
WordAggregate.aggregate_notexist_word("2015/1/12", "2015/2/3")
```

上記コマンドにより、data/DBに存在しない単語.csv というファイルが作成される。

## 5. ディレクトリ構造について
基本的にrailsの構造に従っている。  
分析用のスクリプトについては、lib/aggregate/ で管理している。

