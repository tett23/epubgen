xml.instruct!
xml.container :xmlns=>'urn:oasis:names:tc:opendocument:xmlns:container', :version=>'1.0' do
  xml.rootfiles do
    xml.rootfile :'full-path'=>'content.opf', :'media-type'=>'application/oebps-package+xml'
  end
end
