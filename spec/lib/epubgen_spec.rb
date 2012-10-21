# coding: utf-8

require './lib/epubgen'

TARGET_DIR = './spec/sample/snedronningen'
OUT_DIR = './spec/tmp'

describe Epubgen do
  before do
    @epubgen = Epubgen.new(TARGET_DIR, OUT_DIR)
  end

  describe '変換後のテンポラリのディレクトリ構造' do
    before(:all) do
      @epubgen = Epubgen.new(TARGET_DIR, OUT_DIR)
      @epubgen.create
      @epubgen.to_epub
      @tmp = [OUT_DIR, @epubgen.identifier].join(File::SEPARATOR)
    end
    after(:all) do
      @epubgen.disporse
    end

    it 'mimetypeが存在するか' do File.exists?(@tmp+File::SEPARATOR+'mimetype') end
    it 'toc.ncxが存在するか' do File.exists?(@tmp+File::SEPARATOR+'toc.ncx') end
    it 'content.opfが存在するか' do File.exists?(@tmp+File::SEPARATOR+'content.opf') end
    it 'container.xmlが存在するか' do File.exists?(@tmp+File::SEPARATOR+'container.xml') end
    it 'dataディレクトリが存在するか' do Dir::exists?(@tmp+File::SEPARATOR+'data') end
  end
end
