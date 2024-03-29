# coding: utf-8
require 'haml'
require 'redcloth'
require 'sass'

module AssetCompiler
  TEMPLATE_DIR = './templates'

  def compile(filename, options={}, &after)
    processor = router(filename)

    processor.call(filename, options, &after)
  end

  def compile_and_save(input_path, output_path, options={}, &after)
    body = compile(input_path, options, &after)

    output_path = File.expand_path(output_path)
    out_dir = File.dirname(output_path)
    Dir::mkdir(out_dir) unless Dir.exists?(out_dir)

    open_flag = binary?(input_path) ? 'wb' : 'w'
    f = open(output_path, open_flag); f.print(body); f.close;
  end

  def router(filename)
    ext = extname(filename).to_sym

    case ext
    when :textile
      processor = method(:textile)
    when :builder
      processor = method(:builder)
    when :haml
      processor = method(:haml)
    when :sass
      processor = method(:sass)
    when :markdown, :md
      processor = method(:markdown)
    else
      processor = method(:through)
    end

    processor
  end

  def out_extname(name)
    name = name.to_sym
    case name
    when :html, :textile, :markdown, :md, :haml
      return :html
    when :xml, :builder
      return :xml
    when :css, :sass
      return :css
    else
      return name
    end
  end

  def basename(filename)
    File.basename(filename, '.*')
  end

  def extname(filename)
    ext = File.extname(filename)

    ext.gsub!(/^./, '') if ext =~ /^\./

    ext
  end

  private
  def read_file(filename, options={})
    return open(filename, 'rb').read if options[:binary]

    open(filename).read
  end

  def builder(filename, options={}, &after)
    text = read_file(filename)

    out = ''
    xml = Builder::XmlMarkup.new(:target=>out)

    lambda { |xml, template|
      instance_eval(template)

      xml
    }.call(xml, text)

    out
  end

  def textile(filename, options={}, &after)
    text = read_file(filename)
    body = RedCloth.new(text).to_html
    template_path = options[:template]

    user_template = @input+'template.haml'
    if File.exists?(user_template)
      template_path = user_template
    else
      template_path = AssetCompiler::TEMPLATE_DIR+File::SEPARATOR+'template.haml' if template_path.nil?
      template_path = nil unless File.exists?(template_path)
    end

    template_path.nil? ? body : compile(template_path, :body=>body)
  end

  def haml(filename, options={}, &after)
    text = read_file(filename)

    Haml::Engine.new(text).render(Object.new, :body=>options[:body])
  end

  def sass(filename, options={}, &after)
    text = read_file(filename)
    Sass::Engine.new(text).render
  end

  def markdown(filename, options={}, &after)
    read_file(filename)

  end

  def through(filename, options={}, &after)
    text = read_file(filename, :binary=>binary?(filename))

    after.call(options) unless after.nil?

    text
  end

  def binary?(filename)
    s = File.read(filename, 1024)

    unless s.empty?
      return ((s.count("^ -~\t\r\n").fdiv(s.size) > 0.3) || !(s.index("\x00").nil?))
    else
      return false
    end
  end

  def data_path(path)
    input = Helper.join_path(File.expand_path(@input), 'data')
    fullpath = File.expand_path(path)

    fullpath = Helper.join_path(input, path) if fullpath.match(/^#{input}/).nil?
    fullpath.gsub(input+'/', '')
  end
end
