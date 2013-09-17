## 概要
Vagrantを用いてRuby on Railsのアプリケーションを開発するための仮想環境を作るための設定です．
Railsアプリを作成し，GitHub，Travis CI，Herokuと連携する設定を行い，Deployするところまでを自動化するscriptを同梱しています．

## 前提

- VirtualBox（4.2.18で動作確認）
  - https://www.virtualbox.org/
- Vagrantが使えること（v1.3.1で動作確認）
  - http://www.vagrantup.com/
- GitHubアカウントを取得していること
  - https://github.com/
- Herokuアカウントを取得していること
  - https://www.heroku.com/
- Gitコマンドが利用できること
  - http://git-scm.com/

## Host OSでの作業

### このリポジトリのダウンロード

コマンドプロンプトから次の通り入力．

```
$ git clone git@github.com:ychubachi/vagrant_enpit_package.git
$ cd vagrant_enpit_package
```

### Gust OSの起動

電源とネットワークの状態のよい環境で実行してください．

```bash
$ vagrant up
```

### SSH接続
#### Macの場合

```bash
$ vagrant ssh
```

#### Windowsの場合

vagrant sshだと文字化けするのでPutty/TeraTermなどで
SSH接続し，漢字コードをUTF-8にしてください．

- host: localhost
- port: 2222
- user: vagrant
- password: vagrant

## Guest OSでの作業

### 作業用ディレクトリ

Host OSのこのREADME.mdがあるディレクトリを，Guest OSは/vagrantディレクトリにマウントします．この下にあるworkディレクトリで作業してください．

```bash
cd /vagrant/work
```

### GitHubへのSSH公開鍵

Guest OSでSSH鍵を生成してGitHubに登録します．

```bash
$ /vagrant/scripts/github-connect.sh
```

（このscriptは[Create and register an SSH key for your github account](https://gist.github.com/acoulton/1969779)です．）

## Railsアプリの自動生成

下記のコマンドを実行してください．

```
$ /vagrant/scripts/generate_rails.sh <app_name>
```

Heroku，Travis CIへのログインの後，アプリの生成が始まります．

## Memo

- インストールし直しする場合は、vagrant box removeすること。
