#!/bin/bash

# ================================================================
# ・Rails appを生成し，github,travis,herokuと連携させます
# ・下記の準備が終わっていることを前提とします
#   - ssh鍵の生成とgithubへの登録
# - Create and register an SSH key for your github account
#   - https://gist.github.com/acoulton/1969779
# ================================================================

# ================================================================
# 準備
# ================================================================

if [ $# -ne 1 ]; then
    echo "Usage: source $0 <app_name>"
    exit 1
fi
app_name=$1

# 色付きecho
function my_echo { command echo -e "\e[33m$*\e[m"; }

# ================================================================
# Heroku, Travis CIにログインする
# ================================================================

my_echo 'herokuにログインします'
heroku login
if [ $? != 0 ]; then exit; fi

my_echo 'herokuにssh公開鍵を登録します'
heroku keys:add
if [ $? != 0 ]; then exit; fi

my_echo 'travisコマンドのインストール（アップデート）'
gem install travis
rbenv rehash

my_echo 'GitHubのアカウントでtravisにloginします'
travis login
if [ $? != 0 ]; then exit; fi

# ================================================================
# gitリポジトリを生成
# ================================================================

my_echo 'projectディレクトリを作成します'
mkdir ${app_name}
cd ${app_name}/

my_echo 'ローカルgitリポジトリを作成します'
git init

# ================================================================
# Railsアプリを作成
# ================================================================

my_echo 'Railsアプリを作成します'
rails new . -T

my_echo 'rake db:migrateを実行します'
rake db:migrate

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Generate a new Rails application'

# ================================================================
# RspecのためGemfileを編集
# ================================================================

my_echo 'rspecのためのGemfile設定を追加'
echo "gem 'rspec-rails', '~> 2.0', group: [:development, :test]" >> Gemfile
bundle install
rbenv rehash

my_echo 'rspecの設定を生成'
rails generate rspec:install

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Run rails generate rspec:install'

# ================================================================
# HerokuのためのGemfile設定
# ================================================================

my_echo 'Gemfileにrubyのバージョンを設定します'
sed -i -e "1a\ruby '2.0.0'" Gemfile

my_echo 'slite3をdevelopment, testグループのみにします'
sed -i -e "s/gem 'sqlite3'/gem 'sqlite3', group: [:development, :test]/" Gemfile

my_echo 'pgをproductionグループに追加します'
echo "gem 'pg', group: :production" >> Gemfile
echo "gem 'rails_12factor', group: :production" >> Gemfile

my_echo 'bundle installしてGemfile.lockを更新します'
bundle install --without production

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Change database settings in Gemfile'

# ================================================================
# welcomeコントローラを生成
# ================================================================

my_echo 'welcomeコントローラを生成します'
rails generate controller welcome index

my_echo 'welcomeコントローラをroutesのrootに設定します'
sed -i -e "s/# root 'welcome#index'/root 'welcome#index'/" config/routes.rb

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Create welcome controller'

# ================================================================
# GitHub
# ================================================================

my_echo 'GetHubにリポジトリを作成します'
hub create
if [ $? != 0 ]; then exit; fi

my_echo 'upstreamを設定してGitHubにpushします'
git push -u origin master

# ================================================================
# heroku
# ================================================================

my_echo 'herokuでアプリを作ります'
heroku create
if [ $? != 0 ]; then exit; fi

my_echo 'herokuにpostgresqlアドオンを追加します'
heroku addons:add heroku-postgresql:dev
if [ $? != 0 ]; then exit; fi

my_echo 'herokuにアプリをdeployします'
git push heroku master

# ================================================================
# travis CI用の設定を作成します
# ================================================================

my_echo 'travisを初期化します'
yes Ruby | travis init; echo ''
if [ $? != 0 ]; then exit; fi

my_echo '.travis.ymlを上書き（travis initだと，使用しないversionのrubyも設定される）'
cat << EOS > .travis.yml
language: ruby
rvm:
- 2.0.0
EOS

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Create .travis.yml'

my_echo '.travis.ymlファイルにherokuのための情報を追加します'
yes | travis setup heroku; echo ''
if [ $? != 0 ]; then exit; fi

my_echo '.travis.ymlファイルにdb:migrateのための情報を追加します'
echo '  run: "rake db:migrate"' >> .travis.yml

my_echo 'ここまでの内容をcommitします'
git stage .
git commit -m 'Add settings for heroku into .travis.yml'

# ================================================================
# GitHubからTravis CIを経由してHerokuにdeployします
# ================================================================

my_echo 'GitHubにpushします'
git push origin master

# ================================================================
# 完了
# ================================================================

my_echo "アプリを${app_name}ディレクトリに作成しました"
my_echo "cd ${app_name} を実行してください"
my_echo 'しばらくするとtravisでbuildがはじまります'
my_echo 'heroku上のアプリは下記Web URLからアクセスできます'
heroku apps:info
