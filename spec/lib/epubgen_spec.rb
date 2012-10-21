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

    it 'mimetypeが存在するか' do File.exists?(Helper.join_path(@tmp, 'mimetype')) end
    it 'toc.ncxが存在するか' do File.exists?(Helper.join_path(@tmp, 'toc.ncx')) end
    it 'content.opfが存在するか' do File.exists?(Helper.join_path(@tmp, 'content.opf')) end
    it 'container.xmlが存在するか' do File.exists?(Helper.join_path(@tmp, 'container.xml')) end
    it 'dataディレクトリが存在するか' do Dir::exists?(Helper.join_path(@tmp, 'data')) end
  end
end
