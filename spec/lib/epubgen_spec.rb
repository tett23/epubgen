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

  describe '変換後の一時ファイルについて' do
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

    it 'mimetypeファイルの検査' do
      File.open(Helper.join_path(@tmp, 'mimetype')).read.should == "application/epub+zip\n"
    end
    it 'opfファイルの検査' do
      xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?><package version="2.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookId"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf"><dc:title>雪の女王</dc:title><dc:author>ハンス・クリスティアン・アンデルセン　Hans Christian Andersen</dc:author><dc:publisher>青空文庫</dc:publisher><dc:contributor opf:role="trl">楠山正雄</dc:contributor><dc:identifier>#{@epubgen.identifier}</dc:identifier></metadata><manifest><item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/><item id="sec_5.html" href="data/sec_5.html" media-file="text/html"/><item id="images" href="data/images" media-file=""/><item id="sec_4.html" href="data/sec_4.html" media-file="text/html"/><item id="stylesheets" href="data/stylesheets" media-file=""/><item id="sec_6.html" href="data/sec_6.html" media-file="text/html"/><item id="sec_7.html" href="data/sec_7.html" media-file="text/html"/><item id="sec_1.html" href="data/sec_1.html" media-file="text/html"/><item id="sec_2.html" href="data/sec_2.html" media-file="text/html"/><item id="sec_3.html" href="data/sec_3.html" media-file="text/html"/><item id="imprint.html" href="data/imprint.html" media-file="text/html"/></manifest><spine toc="ncx"><itemref idref="sec_1.html"/><itemref idref="sec_2.html"/><itemref idref="sec_3.html"/><itemref idref="sec_4.html"/><itemref idref="sec_5.html"/><itemref idref="sec_6.html"/><itemref idref="sec_7.html"/></spine></package>
EOS
      File.open(Helper.join_path(@tmp, 'content.opf')).read.should == xml.chomp
    end
    it 'container.xmlの検査' do
      xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?><container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0"><rootfiles><rootfile full-path="content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>
EOS
      File.open(Helper.join_path(@tmp, 'container.xml')).read.should == xml.chomp
    end
    it 'toc.ncxの検査' do
      xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?><ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/"><head><meta name="dtb:uid" content="#{@epubgen.identifier}"/><meta name="dtb:depth" content="1"/><meta name="dtb:totalPageCount" content="0"/><meta name="dtb:maxPageNumber" content="0"/></head><docTitle/><navMap><navPoint id="第一のお話　鏡とそのかけらのこと" playOrder="0"><navLabel><text>第一のお話　鏡とそのかけらのこと</text></navLabel><content src="data/sec_1.html"/></navPoint><navPoint id="第二のお話　男の子と女の子" playOrder="1"><navLabel><text>第二のお話　男の子と女の子</text></navLabel><content src="data/sec_2.html"/></navPoint><navPoint id="第三のお話　魔法の使える女の花ぞの" playOrder="2"><navLabel><text>第三のお話　魔法の使える女の花ぞの</text></navLabel><content src="data/sec_3.html"/></navPoint><navPoint id="第四のお話　王子と王女" playOrder="3"><navLabel><text>第四のお話　王子と王女</text></navLabel><content src="data/sec_4.html"/></navPoint><navPoint id="第五のお話　おいはぎのこむすめ" playOrder="4"><navLabel><text>第五のお話　おいはぎのこむすめ</text></navLabel><content src="data/sec_5.html"/></navPoint><navPoint id="第六のお話　ラップランドの女とフィンランドの女" playOrder="5"><navLabel><text>第六のお話　ラップランドの女とフィンランドの女</text></navLabel><content src="data/sec_6.html"/></navPoint><navPoint id="第七のお話　雪の女王のお城でのできごとと　そののちのお話" playOrder="6"><navLabel><text>第七のお話　雪の女王のお城でのできごとと　そののちのお話</text></navLabel><content src="data/sec_7.html"/></navPoint></navMap></ncx>
EOS
    end
  end
end
