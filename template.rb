# frozen_string_literal: true

# 最強の Rails template.rb （要件を満たす初期版）
# 使用方法: rails new app_name -m path/to/this_template.rb --css bootstrap --skip-jbuilder

# --- 基本設定 ---
# 最新Railsバージョンを使用（rails new 時点での最新を利用する想定）

# Jbuilder をスキップする
remove_file 'app/views/layouts/mailer.html.erb'
remove_file 'app/views/layouts/mailer.text.erb'

# --- Gemfile 調整 ---

# jbuilder は使わない
gsub_file 'Gemfile', /^.*jbuilder.*$/, ''

# kamal は不要
# （初期Gemfileには含まれていないので特に削除不要だが一応確認）
gsub_file 'Gemfile', /^.*kamal.*$/, ''

# rspec を導入
gem_group :development, :test do
  gem 'rspec-rails'
end

# sgcop (rubocop wrapper) を導入
gem_group :development do
  gem 'sgcop', require: false
end

# 必要な gem をインストール
after_bundle do
  # RSpec 設定
  generate 'rspec:install'

  # sgcop 設定ファイル生成
  run 'bundle exec sgcop install' rescue nil

  # esbuild で bootstrap を有効化
  # Rails 7+ では --css bootstrap を指定して new すると初期設定されるが
  # 念のため追加で必要な設定を行う

  say 'Setting up esbuild with bootstrap...', :green
  # Bootstrap インストール
  run 'yarn add bootstrap @popperjs/core'

  # application.js に bootstrap を import
  append_to_file 'app/javascript/application.js', "\nimport 'bootstrap'\n"

  # application.sass.scss に bootstrap を import
  # CSS Bundling with bootstrap を利用している前提
  css_file = Dir['app/assets/stylesheets/application.*'].first
  if css_file
    append_to_file css_file, "\n@import \"bootstrap/scss/bootstrap\";\n"
  end

  git :init
  git add: '.'
  git commit: %( -m 'Initial commit with best template setup')
end
