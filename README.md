## 概要
Vagrantを用いてRuby on Railsのアプリケーションを開発するための仮想環境を作るための設定です．
Railsアプリを作成し，GitHub，Travis CI，Herokuと連携する設定を行い，Deployするところまでを自動化するscriptを同梱しています．

## 前提

### アカウントの作成

- GitHubアカウントを取得していること
  - [GitHub](https://github.com/)
- Herokuアカウントを取得していること
  - [Heroku | Cloud Application Platform](https://www.heroku.com/)

### ソフトウエアのインストール

- Windows/Mac共通
  - [Oracle VM VirtualBox](https://www.virtualbox.org/)
  - [Vagrant](http://www.vagrantup.com/)
- Windowsのみ
  - [Git - Downloading Package](http://git-scm.com/download/win)

## Host OSでの作業

### このリポジトリのダウンロード

Windowsの場合はWindows版Gitに付属する「Git Bash」を起動します．起動後，ウインドウのタイトルを右クリックして，プロパティを開き，フォントを「ラスターフォント」に設定してください．

Macの場合はターミナルを起動してください．

ターミナルで次の通り入力します．

```
$ git clone https://github.com/ychubachi/vagrant_enpit_package.git
$ cd vagrant_enpit_package
```

### Gust OSの起動

電源とネットワークの状態のよい環境で実行してください（10～20分程度かかる）．

```bash
$ vagrant up
```

### SSH接続

```bash
$ vagrant ssh
```

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
