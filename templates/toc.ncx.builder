xml.instruct!
xml.ncx :version=>'2005-1', :xmlns=>'http://www.daisy.org/z3986/2005/ncx/' do
  xml.head do
    xml.meta :name=>'dtb:uid', :content=>@identifier
    xml.meta :name=>'dtb:depth', :content=>1
    xml.meta :name=>'dtb:totalPageCount', :content=>0
    xml.meta :name=>'dtb:maxPageNumber', :content=>0
  end
  xml.docTitle @metadata[:title]
  xml.navMap do
    @toc.each_with_index do |item, i|
      xml.navPoint :id=>item['name'], :playOrder=>i do
        xml.navLabel do
          xml.text item['name']
        end
        xml.content :src=>'data/'+item['ref']
      end
    end
  end
end
