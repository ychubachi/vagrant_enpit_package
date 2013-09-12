## 概要
Railsアプリを作成し，GitHub，Travis CI，Herokuと連携する設定を行い，Deployします．

## 前提

- Ruby 2.0.0，Rails 4.0がインストールされていること
- rbenvを使っていること
- [Heroku Toolbelt](https://toolbelt.heroku.com/)がインストールされていること
- [github/hub](https://github.com/github/hub)がインストールされていること

## GitHubへのSSH公開鍵

GitHubへSSH公開鍵を登録していない場合は下記のコマンドを実行してください．

```
$ ./github-connect.sh
```

（このscriptは[Create and register an SSH key for your github account](https://gist.github.com/acoulton/1969779)から一部を改変したものです．）

## Railsアプリの自動生成

下記のコマンドを実行してください．

```
$ ./generate_rails.sh <app_name>
```

Heroku，Travis CIへのログインの後，アプリの生成が始まります．
