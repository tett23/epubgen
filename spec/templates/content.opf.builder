tmp_dir = Epubgen::TMP_DIR+File::SEPARATOR+@identifier
tmp_data_dir = tmp_dir+File::SEPARATOR+'data'

xml.instruct!
xml.package :version=>'2.0', :xmlns=>'http://www.idpf.org/2007/opf', :'unique-identifier'=>:BookId do
  xml.metadata :'xmlns:dc'=>'http://purl.org/dc/elements/1.1/', :'xmlns:opf'=>'http://www.idpf.org/2007/opf' do
    @metadata.each do |key, val|
      args = {}
      if val.class == Hash
        args = val[:args]
        val = val[:value]
      end

      xml.tag! 'dc:'+key.to_s, args do |b|
        b.text!(val.to_s)
      end
    end
  end
  xml.manifest do
    xml.item :id=>'ncx', :href=>'toc.ncx', :'media-type'=>'application/x-dtbncx+xml'
    Dir::entries(tmp_data_dir).each do |filename|
      next unless @ignore_filenames.index(filename).nil?

      mimetype = MIME::Types.type_for(filename)[0].to_s
      xml.item :id=>filename, :href=>'data/'+filename, :'media-file'=>mimetype
    end
  end
  xml.spine :toc=>'ncx' do
    toc_path = @input+File::SEPARATOR+'toc.yml'
    YAML.load_file(toc_path).each do |item|
      xml.itemref :idref=>item['ref']
    end
  end
end
