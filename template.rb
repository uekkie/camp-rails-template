# frozen_string_literal: true

# 使用方法: rails new a -m ./template.rb --css bootstrap --skip-jbuilder --skip-rubocop --skip-test --skip-ci --skip-kamal --skip-solid --skip-devcontainer

# --- 基本設定 ---
# 最新Railsバージョンを使用（rails new 時点での最新を利用する想定）

# 不要ファイル削除
remove_file 'app/views/layouts/mailer.html.erb'
remove_file 'app/views/layouts/mailer.text.erb'

# --- Gemfile 調整 ---
# jbuilder は使わない
gsub_file 'Gemfile', /^.*jbuilder.*$/, ''
# kamal は不要
gsub_file 'Gemfile', /^.*kamal.*$/, ''
# tzinfo-data は不要
gsub_file 'Gemfile', /^.*tzinfo-data.*$/, ''
# rubocop-rails-omakase は不要
gsub_file 'Gemfile', /^.*rubocop-rails-omakase.*$/, ''
# Gemfile のコメント行をすべて削除
gsub_file 'Gemfile', /^#.*\n/, ''

# rspec を導入
gem_group :development, :test do
  gem 'rspec-rails'
end

# sgcop (rubocop wrapper) を導入
gem_group :development do
  gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
end

# simple_form を導入
gem 'simple_form'

# hamlit-rails と html2haml を導入（変換用）
gem 'hamlit-rails'
gem 'html2haml', group: :development

# 必要な gem をインストール
after_bundle do
  # RSpec 設定
  generate 'rspec:install'

  # .rubocop.yml をプロジェクトルートに新規作成
  remove_file '.rubocop.yml' if File.exist?('.rubocop.yml')
  create_file '.rubocop.yml', <<~YAML
    inherit_gem:
      sgcop: rails/rubocop.yml
  YAML

  # simple_form 設定（bootstrapオプションで）
  generate 'simple_form:install', '--bootstrap'

  # i18n 日本語対応
  say 'Setting up i18n with Japanese locale...', :green
  inside('config/locales') do
    create_file 'ja.yml', <<~YAML
      ja:
        hello: "こんにちは"
    YAML
  end
  application "    config.i18n.default_locale = :ja\n"

  # esbuild で bootstrap を有効化
  say 'Setting up esbuild with bootstrap...', :green
  run 'yarn add bootstrap @popperjs/core'
  append_to_file 'app/javascript/application.js', "\nimport 'bootstrap'\n"

  css_file = Dir['app/assets/stylesheets/application.*'].first
  if css_file
    append_to_file css_file, "\n@import \"bootstrap/scss/bootstrap\";\n"
  end

  # erb から haml へ変換
  say 'Converting ERB to Haml...', :green
  run 'bundle exec rake hamlit:erb2haml'

  # 変換後に html2haml は不要なので Gemfile から削除
  gsub_file 'Gemfile', /^.*html2haml.*$/, ''
  run 'bundle install'

  git :init
  git add: '.'
  git commit: %( -m 'Initial commit with best template setup')
end
