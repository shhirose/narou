# -*- mode: ruby -*-
# -*- coding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "version"

require "fileutils"

module Narou
  def self.create_git_commit_version
    File.write("commitversion", `git describe --always`.strip)
    "commitversion"
  end
end

at_exit do
  if File.exists?("commitversion")
    FileUtils.rm("commitversion")
  end
end

Encoding.default_external = Encoding::UTF_8

Gem::Specification.new do |gem|
  gem.name          = "narou"
  gem.version       = Version
  gem.license       = "MIT"
  gem.authors       = ["whiteleaf7"]
  gem.email         = ["2nd.leaf@gmail.com"]
  gem.homepage      = "http://whiteleaf.hatenablog.com/"
  gem.summary       = %q{Narou.rb ― 小説家になろうダウンローダ＆縦書用整形スクリプト}
  gem.description   = %q{
小説家になろうで公開されている小説の管理、及び電子書籍データへの
変換を支援します。縦書用に特化されており、横書き用に特化されたWEB小説
を違和感なく縦書で読むことが出来るようになります。
}.split("\n").join

  install_message = <<-EOS
#{"*" * 79}

narou コマンドのインストール or アップデートが完了しました。
詳しい説明は `narou help' コマンドをご覧下さい。

  NOTICE
  初めてこのアプリケーションを使う場合、小説管理用のフォルダを初期化する必要があります。
  任意のフォルダで `narou init' を実行して下さい。

2014/06/06 : **1.5.6.1**
* 追加機能もしくは仕様変更
	- タイトルにつく更新日の日付を新着があった日付に変更
* Bug Fix
	- 初期化時に `narou init` を実行できない問題を修正

2014/06/14 : **1.5.7**
* 追加機能もしくは仕様変更
	- 小説家になろうにおいて、10話ごとにかけていたウェイトを削除
* Bug Fix
	- &#39; (') のエンティティ変換を追加

2014/06/15 : **1.5.7.1**
* 追加機能もしくは仕様変更
	- 10話ごとの制限が復活していたので、1.5.7で外したウェイトを復活させました

#{"*" * 79}
  EOS
  gem.post_install_message = install_message.gsub("\t", " ")

  gem.required_ruby_version = ">=1.9.3"

  gem.files         = `git ls-files`.split("\n") << Narou.create_git_commit_version
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.add_runtime_dependency 'termcolor', '~> 1.2', '>= 1.2.2'
  gem.add_runtime_dependency 'rubyzip', '~> 1.1', '>= 1.1.0'
  gem.add_runtime_dependency 'pony', '~> 1.8'
end
