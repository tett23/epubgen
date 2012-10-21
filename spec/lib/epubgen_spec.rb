# coding: utf-8

require './lib/epubgen'

TARGET_DIR = './spec/sample/snedronningen'
OUT_DIR = './spec/tmp'

describe Epubgen do
  before do
    Epubgen.class_eval {remove_const(:TMP_DIR)}
    Epubgen.const_set(:TMP_DIR, Helper.join_path('.', 'spec', 'tmp'))
    @epubgen = Epubgen.new(TARGET_DIR, OUT_DIR)
  end

  describe '変換後のテンポラリのディレクトリ構造' do
    before(:all) do
      @epubgen = Epubgen.new(TARGET_DIR, OUT_DIR)
      @epubgen.create
      @epubgen.to_epub
      @tmp = [Epubgen::TMP_DIR, @epubgen.identifier].join(File::SEPARATOR)
    end

    it 'mimetypeが存在するか' do File.exists?(Helper.join_path(@tmp, 'mimetype')).should be_true end
    it 'toc.ncxが存在するか' do File.exists?(Helper.join_path(@tmp, 'toc.ncx')).should be_true end
    it 'content.opfが存在するか' do File.exists?(Helper.join_path(@tmp, 'content.opf')).should be_true end
    it 'container.xmlが存在するか' do File.exists?(Helper.join_path(@tmp, 'container.xml')).should be_true end
    it 'dataディレクトリが存在するか' do Dir::exists?(Helper.join_path(@tmp, 'data')).should be_true end

    it 'data以下が正常に出力されているか' do
      data_dir_path = Helper.join_path(@tmp, 'data')
      file_list = Dir::entries(data_dir_path)
      file_list << Dir::entries(Helper.join_path(data_dir_path, 'stylesheets'))
      file_list << Dir::entries(Helper.join_path(data_dir_path, 'images'))

      file_list.should == ["..", "sec_5.html", "images", "sec_4.html", "stylesheets", "sec_6.html", "sec_7.html", "sec_1.html", ".", "sec_2.html", "sec_3.html", "imprint.html", ["..", "common.css", "."], ["..", "fig42387_05.png", "fig42387_08.png", "fig42387_06.png", "fig42387_02.png", "fig42387_03.png", ".", "fig42387_01.png", "fig42387_07.png", "fig42387_04.png"]]
    end
  end
end
