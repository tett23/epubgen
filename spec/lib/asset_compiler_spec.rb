# coding: utf-8

require './lib/helper'
require './lib/asset_compiler'

TARGET_DIR = './spec/sample/snedronningen'
OUT_DIR = './spec/tmp'

class DummyClass
  def initialize(input, output)
    @input = input.match(/#{File::SEPARATOR}$/).nil? ? input+File::SEPARATOR : input
    @output = output
  end
end

describe AssetCompiler do
  before do
    @asset_compiler = DummyClass.new(TARGET_DIR, OUT_DIR)
    AssetCompiler.class_eval {remove_const(:TEMPLATE_DIR)}
    AssetCompiler.const_set(:TEMPLATE_DIR, Helper.join_path('.', 'spec', 'templates'))
    @asset_compiler.extend(AssetCompiler)
  end

  #it 'textileのコンパイル' do
  #  @asset_compiler.send(:textile, './spec/target/data/sec_1.textile')
  #end

  it 'data_pathにdata以下を想定した相対パスを与える' do
    @asset_compiler.send(:data_path, 'images/hogehoge').should == 'images/hogehoge'
  end
  it 'data_pathに絶対パスを与える' do
    real_path = File.expand_path(Helper.join_path(TARGET_DIR, 'data', 'sec_1.textile'))
    @asset_compiler.send(:data_path, real_path).should == 'sec_1.textile'
  end

  context 'ファイル名取得' do
    it '絶対パスの場合' do
      @asset_compiler.basename(Helper.join_path('/', 'absolute', 'path' , 'hoge.html')).should == 'hoge'
    end
    it '相対パスの場合1' do
      @asset_compiler.basename('hoge.html').should == 'hoge'
    end
    it '相対パスの場合' do
      @asset_compiler.basename(Helper.join_path('relative', 'hoge.html')).should == 'hoge'
    end
  end

  describe '拡張子判定' do
    context '入力された拡張子名を判定したい' do
      it 'textileの判定' do
        @asset_compiler.extname('hoge.textile').should == 'textile'
      end
      it '拡張子がついていない' do
        @asset_compiler.extname('hoge').should == ''
      end
      it '拡張子がついていないとき、ファイル名がそのままかえってきたりしたらこまる' do
        @asset_compiler.extname('hoge').should_not == 'hoge'
      end
    end
    describe '入力' do
      context 'htmlへの変換ルールがほしい' do
        it '拡張子がtextileの場合' do @asset_compiler.router('hoge.textile').should == @asset_compiler.method(:textile) end
        it '拡張子がhamlの場合' do @asset_compiler.router('hoge.haml').should == @asset_compiler.method(:haml) end
        it '拡張子がmarkdownの場合' do @asset_compiler.router('hoge.markdown').should == @asset_compiler.method(:markdown) end
        it '拡張子がmdの場合' do @asset_compiler.router('hoge.md').should == @asset_compiler.method(:markdown) end
      end
      context 'xmlへの変換ルールがほしい' do
        it '拡張子がbuilderの場合' do @asset_compiler.router('hoge.builder').should == @asset_compiler.method(:builder) end
      end
      context 'htmlへの変換ルールがほしい' do
        it '拡張子がsass場合' do @asset_compiler.router('hoge.sass').should == @asset_compiler.method(:sass) end
      end
      context '何もしない変換ルールがほしい' do
        it '拡張子がhtml場合' do @asset_compiler.router('hoge.html').should == @asset_compiler.method(:through) end
        it '拡張子がcss場合' do @asset_compiler.router('hoge.css').should == @asset_compiler.method(:through) end
        it '拡張子がxml場合' do @asset_compiler.router('hoge.xml').should == @asset_compiler.method(:through) end
      end
    end

    describe '出力' do
      context 'htmlにコンパイルされたいやつ' do
        it 'htmlの場合' do @asset_compiler.out_extname(:html).should == :html end
        it 'textileの場合' do @asset_compiler.out_extname(:textile).should == :html end
        it 'markdownの場合' do @asset_compiler.out_extname(:markdown).should == :html end
        it 'mdの場合' do @asset_compiler.out_extname(:md).should == :html end
        it 'hamlの場合' do @asset_compiler.out_extname(:haml).should == :html end
      end
      context 'xmlにコンパイルされたいやつ' do
        it 'xmlの場合' do @asset_compiler.out_extname(:xml).should == :xml end
        it 'builderの場合' do @asset_compiler.out_extname(:builder).should == :xml end
      end
      context 'cssにコンパイルされたいやつ' do
        it 'cssの場合' do @asset_compiler.out_extname(:css).should == :css end
        it 'sassの場合' do @asset_compiler.out_extname(:sass).should == :css end
      end
      context 'コンパイルしないやつはそのままの名前' do
        # というよりこの中はそのうち対応したいので対応後にコンパイルできなかったらアウト
        it 'xhtmlとか' do @asset_compiler.out_extname(:xhtml).should == :xhtml end
        it 'scssとか' do @asset_compiler.out_extname(:scss).should == :scss end
      end
    end
  end

end
