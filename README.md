% OSS普及協議会Ruby勉強会2
% ka ([kaosfield](http://www.kaosfield.net))
% 2015-08-21

# はじめに

このスライドは公開されています

このスライドのリポジトリは[https://github.com/kaosf/20150821-oss-slide](https://github.com/kaosf/20150821-oss-slide)にあります

間違いなどを見つけた場合は

<ul>
<li>メールで連絡</li>
<li>Issueで報告</li>
<li>Pull Requestで修正案を提出</li>
</ul>

などしていただけるとありがたいです (※下に行くほど嬉しいです)

# 今回の進め方

先にとあるリポジトリを用意しました

[https://github.com/kaosf/20150821-oss-twcopy](https://github.com/kaosf/20150821-oss-twcopy)

これを皆さんの手元でも再現してみるのが目標です

# Rails

```sh
gem install rails -v 4.2.2
rbenv rehash
rails new twcopy
```

プロジェクトの初期の作成はこれでOK

# サーバプロセスの走らせ方

```sh
rails s
# rails server でもOK (rails s は短縮された形)
```

localhost以外で走らせる場合は

```sh
rails s -b 0.0.0.0
```

## 参考

[Ruby - Rails 4.2.0のrails serverにアクセスできない - Qiita](http://qiita.com/mizoki/items/d3bdef3be252ece425b9)

# その他コマンド

```sh
rails c # Rubyのインタプリタ起動
# rails console でもOK (rails c は短縮された形)
```

# まずRSpecとFactoryGirlを使うようにする

今回は実際に活用することは無いがデフォルトで使うようにしておく

Gemfile内の`group :development, :test do ... end`のブロック内に

```ruby
group :development, :test do
  gem 'rspec-rails', '3.2.1'
  gem 'factory_girl_rails', '4.5.0'
end
```

のように書く

# なんとか-rails というgemを使う

```ruby
gem 'rspec'
gem 'factory_girl'
```

というgemもあるのだがこれは使わず

```ruby
gem 'rspec-rails', '3.2.1'
gem 'factory_girl_rails', '4.5.0'
```

という名前の方を使うとRailsで使うにあたって楽が出来るようになる

あとついでにバージョンも固定しておく

# `rspec-rails`と`factory_girl_rails`

## 参考

<ul>
<li>[rspec/rspec-rails](https://github.com/rspec/rspec-rails)</li>
<li>[thoughtbot/factory_girl_rails](https://github.com/thoughtbot/factory_girl_rails)</li>
</ul>


# Gemfile編集後

```sh
bundle install
```

これでgemがインストール出来る

# RSpecの使用準備

```sh
rails g rspec:install
```

必要なファイルが生成される

# Bootstrapを使う

このgemは開発環境でも本番環境でも使うので

Gemfile内の`group :development, :test do ... end`のブロック内には**書かない**

```ruby
gem 'twitter-bootstrap-rails', '3.2.0'
```

`bundle install`も忘れずに

## 参考

<ul>
<li>[seyhunak/twitter-bootstrap-rails](https://github.com/seyhunak/twitter-bootstrap-rails)</li>
</ul>

# Bootstrapの使用準備

```sh
rails g bootstrap:layout application
rails g bootstrap:install static
```

上書きしますか？という問いにはYで答える

これで既存の`views/layouts/application.html.erb`を上書き出来る

JavaScriptやCSSも何もしなくてもちゃんとBootstrap用のものを使ってくれるようになる

# Deviseを使う

ユーザ認証機能のためのgem

```ruby
gem 'devise', '3.4.1'
```

## 参考

<ul>
<li>[plataformatec/devise](https://github.com/plataformatec/devise)</li>
</ul>

# Deviseの使用準備とユーザモデルの作成

```sh
rails g devise:install
rails g devise user name:string
```

これでmigrationファイルが作られるので

```sh
rake db:migrate
```

でDBスキーマを変更

ユーザ認証機能に必要なおおよそのカラムを勝手に作ってくれる

巨人の肩に乗ろう

# 独自のViewを使う

Deviseはデフォルトでメールアドレスとパスワードを弄るViewを用意してくれる

今回は`name`カラムがあるので独自のViewを使いたい

`config/initializers/devise.rb` を以下のように変更

```diff
-  # config.scoped_views = false
+  config.scoped_views = true
```

その後

```sh
rails g devise:views users
```

# nameのためのformを追加する

`app/views/users/registrations/edit.html.erb` と  
`app/views/users/registrations/new.html.erb` において

```diff
 <%= form_for ... do |f| %>
 ...
+  <div class="field">
+    <%= f.label :name %><br />
+    <%= f.text_field :name %>
+  </div>
 ...
 <% end %>
```

という変更を加える

# nameをフォームから受け取れるようにする

strong paramterという仕組みでサニタイズが行われるのがRailsのやり方

`app/controllers/application_controller.rb`に

```diff
   protect_from_forgery with: :exception
+
+  before_filter :configure_permitted_parameters, if: :devise_controller?
+
+  protected
+
+  def configure_permitted_parameters
+    devise_parameter_sanitizer.for(:sign_up) << :name
+    devise_parameter_sanitizer.for(:account_update) << :name
+  end
 end
```

という変更を加える

# ルート (/) となる場所を作る

```sh
rails g controller home index
```

`config/routes.rb`を変更

```diff
 Rails.application.routes.draw do
+  root to: 'home#index'
 ...
 end
```

# Tweetモデル Followingモデルを作る

```sh
rails g model tweet body:string user:references
rails g model following from_user:references to_user:references
```

# NOT NULL制約を付ける

可能な限りNOT NULLは付けておいた方が良い

生成されたmigrationファイルを以下の用に変更

```diff
-      t.string :body
-      t.references :user, index: true, foreign_key: true
+      t.string :body, null: false
+      t.references :user, index: true, foreign_key: true, null: false

-      t.references :from_user, index: true, foreign_key: true
-      t.references :to_user, index: true, foreign_key: true
+      t.references :from_user, index: true, foreign_key: true, null: false
+      t.references :to_user, index: true, foreign_key: true, null: false
```

# 各種機能を順次実装していく

ここまで来ればDBの方が変わらないので安心

アプリケーションを思うように弄っていく

ダメなら戻す(Gitなり何なりを活用しよう)

# 実装する項目

<ul>
<li>`tweets_controller`の`create`</li>
<li>`followings_controller`の`create`と`destroy`</li>
<li>`User`と`Tweet`の一対多の関連</li>
<li>`User`と`Following`の一対多の関連</li>
<li>`has_many through: ...`で`User`と`User`の多対多の関連</li>
<li>`friends_controller`の`index`</li>
</ul>

# デザイン

<ul>
<li>BootstrapのCSS活用</li>
<li>`container` `row` `col-XX-Y` クラス</li>
<li>`table` `table-hovered`クラス</li>
<li>`btn` `btn-primary` `btn-danger`クラス</li>
</ul>

## 参考

<ul>
<li>[CSS · Bootstrap](http://getbootstrap.com/css/)</li>
</ul>

# 画像投稿機能を追加する

Paperclipというgemを使う

```ruby
gem 'paperclip', '4.3.0'
```

## 参考

<ul>
<li>[thoughtbot/paperclip](https://github.com/thoughtbot/paperclip)</li>
</ul>

# `User`モデルに`icon`を追加する

```sh
rails g paperclip user icon
```

migrationファイルが生成されるので

```sh
rake db:migrate
```

# formをファイルアップロードが出来るようにする

`app/views/users/registrations/edit.html.erb` と  
`app/views/users/registrations/new.html.erb` において  
`name`を追加したときと同様に

```diff
+  <div class="field">
+    <%= f.label :icon %><br />
+    <%= f.file_field :icon %>
+  </div>
```

を追加

# strong parameter対策

`name`のときと同様`app/controllers/application_controller.rb`を変更

```diff
 def configure_permitted_parameters
   devise_parameter_sanitizer.for(:sign_up) << :name
+  devise_parameter_sanitizer.for(:sign_up) << :icon
   devise_parameter_sanitizer.for(:account_update) << :name
+  devise_parameter_sanitizer.for(:account_update) << :icon
 end
```

# `User`モデル変更

```diff
 class User < ActiveRecord::Base
 ...
+  has_attached_file :icon
+  validates_attachment_content_type :icon, content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
 end
```

上記の2行を追記する

`content_type`は必要な分だけでも良い

これでファイルアップロードの準備完了
