# encoding: utf-8

require 'redcloth'
require 'builder'
require 'mime/types'
require 'haml'
require 'zipruby'
require 'digest/sha1'

require './lib/helper'
require './lib/asset_compiler'

class Epubgen
  TMP_DIR = './tmp'

  include Helper
  include AssetCompiler

  def initialize(input, output)
    @input = input.match(/#{File::SEPARATOR}$/).nil? ? input+File::SEPARATOR : input
    @output = output
    @identifier = book_identifier
    @tmp_path = tmp_path
    @tmp_data_path = tmp_data_path

    @metadata = load_metadata
    @metadata[:identifier] = @identifier
    @ignore_filenames = ignore_filenames
    @toc = create_toc
  end
  attr_reader :identifier

  def create
    input_data_dir = @input+File::SEPARATOR+'data'

    Dir::mkdir(@tmp_path) unless Dir::exists?(@tmp_path)
    Dir::mkdir(@tmp_data_path) unless Dir::exists?(@tmp_data_path)

    convert(input_data_dir)

    compile_and_save('templates/toc.ncx.builder', join_path(@tmp_path, 'toc.ncx'))
    compile_and_save('templates/container.xml.builder', join_path(@tmp_path, 'container.xml'))
    compile_and_save('templates/mimetype', join_path(@tmp_path, 'mimetype'))
    compile_and_save('templates/content.opf.builder', join_path(@tmp_path, 'content.opf'))
  end

  def convert(input_path)
    Dir::entries(input_path).each do |t|
      next unless @ignore_filenames.index(t).nil?
      real_path = File.expand_path(join_path(input_path, t))

      if File::directory?(real_path)
        convert(real_path)
      else
        out_path = join_path(@tmp_data_path, data_path(real_path))
        ext = extname(out_path)
        out_path = out_path.gsub(/\.#{ext}$/, '.'+out_extname(ext).to_s)
        out_dir = File.dirname(out_path)

        Dir::mkdir(out_dir) unless Dir.exists?(out_dir)
        compile_and_save(real_path, out_path)
      end
    end
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
      archive.add_file(tmp_path+File::SEPARATOR+'toc.ncx')

      add_archive(archive, tmp_data_dir, 'data')
    end
  end

  private
  def add_archive(archive, tmp_dir, dir)
    Dir::entries(tmp_dir).each do |filename|
      path = File.expand_path(tmp_dir+File::SEPARATOR+filename)
      next unless @ignore_filenames.index(filename).nil?
      if File::directory?(path)
        archive.add_dir(filename)
        add_archive(archive, path, dir+'/'+filename)
      else
        zip_path = [dir, filename].reject {|f| f.nil? || f==''}.join('/')
        archive.add_buffer(zip_path, open(path).read)
      end
    end
  end

  def ignore_filenames
    [
      '.',
      '..'
    ]
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

  def tmp_path
    join_path(Epubgen::TMP_DIR, @identifier)
  end

  def tmp_data_path
    join_path(tmp_path, 'data')
  end


  def create_toc
    file = @input+File::SEPARATOR+'toc.yml'
    YAML.load_file(file)
  end
end
