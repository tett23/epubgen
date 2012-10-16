# encoding: utf-8

require 'redcloth'
require 'builder'
require 'mime/types'
require 'haml'
require 'zipruby'
require 'digest/sha1'

class Epubgen
  TEMPLATE_DIR = './templates'
  TMP_DIR = './tmp'

  def initialize(input, output)
    @input = input
    @output = output
    @identifier = book_identifier

    @metadata = load_metadata
    @ignore_filenames = ignore_filenames
  end

  def create
    input_data_dir = @input+File::SEPARATOR+'data'
    tmp_dir = Epubgen::TMP_DIR+File::SEPARATOR+@identifier
    tmp_data_dir = tmp_dir+File::SEPARATOR+'data'

    Dir::mkdir(tmp_dir) unless Dir::exists?(tmp_dir)
    Dir::entries(@input+File::SEPARATOR+'data').each do |filename|
      next unless @ignore_filenames.index(filename).nil?

      if File.extname(filename) == '.textile'
        html = parse_textile(input_data_dir+File::SEPARATOR+filename)
        basename = File.basename(filename, '.*')
        Dir::mkdir(tmp_data_dir) unless Dir::exists?(tmp_data_dir)

        f = open(tmp_data_dir+File::SEPARATOR+basename+'.html', 'w'); f.print(html); f.close
      end
    end

    container = create_xml('templates/container.xml.builder')
    content = create_xml('templates/content.opf.builder')
    mimetype = open('templates/mimetype').read
    f = open(tmp_dir+File::SEPARATOR+'container.xml', 'w'); f.print(container); f.close
    f = open(tmp_dir+File::SEPARATOR+'content.opf', 'w'); f.print(content); f.close
    f = open(tmp_dir+File::SEPARATOR+'mimetype', 'w'); f.print(mimetype); f.close
  end

  def disporse
    tmp_path = Epubgen::TMP_DIR+File::SEPARATOR+@identifier
    disporse_tmp_dir(tmp_path)
  end

  def to_epub(out_path=nil)
    out_path = @output+File::SEPARATOR+@identifier+'.epub' if out_path.nil?
    tmp_path = Epubgen::TMP_DIR+File::SEPARATOR+@identifier
    tmp_data_dir = tmp_path+File::SEPARATOR+'data'

    File::delete(out_path) if File::exists?(out_path)

    Zip::Archive.open(out_path, Zip::CREATE) do |archive|
      archive.add_file('mimetype', tmp_path+File::SEPARATOR+'mimetype')
      archive.add_dir('META-INF')
      archive.add_file('META-INF/container.xml', tmp_path+File::SEPARATOR+'container.xml')
      archive.add_file(tmp_path+File::SEPARATOR+'content.opf')

      archive.add_dir('data')
      Dir::entries(tmp_data_dir).each do |filename|
        next unless @ignore_filenames.index(filename).nil?

        path = File.expand_path(tmp_data_dir+File::SEPARATOR+filename)
        archive.add_buffer('data/'+filename, open(path).read)
      end
    end
  end

  private
  def create_xml(template_path)
    template = open(template_path).read
    out = ''
    xml = Builder::XmlMarkup.new(:target=>out)

    lambda { |xml, template|
      instance_eval(template)

      xml
    }.call(xml, template)

    out
  end

  def ignore_filenames
    [
      '.',
      '..'
    ]
  end

  def parse_textile(path)
    text = open(path).read
    template = open('./templates/template.haml').read
    body = RedCloth.new(text).to_html

    Haml::Engine.new(template).render(Object.new, :body=>body)
  end

  def disporse_tmp_dir(tmp_path)
    if FileTest.directory?(tmp_path)
      Dir.foreach(tmp_path) do |file|
        next if /^\.+$/ =~ file
        disporse_tmp_dir(tmp_path.sub(/\/+$/,"") + "/" + file )
      end

      Dir.rmdir(tmp_path) rescue ""
    else
      File.delete(tmp_path)
    end
  end

  def load_metadata
    file = @input+File::SEPARATOR+'metadata.yml'
    YAML.load_file(file)
  end

  def book_identifier
    Digest::SHA1.hexdigest(@input+Time.now.to_s)
  end
end
