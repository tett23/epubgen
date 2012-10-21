# coding: utf-8
require 'haml'
require 'redcloth'

module AssetCompiler
  TEMPLATE_DIR = './templates'

  def compile(filename, options={}, &after)
    processor = router(filename)

    processor.call(filename, options, &after)
  end

  def compile_and_save(input_path, output_path, options={}, &after)
    body = compile(input_path, options, &after)
    f = open(output_path, 'w'); f.print(body); f.close;
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

  private
  def read_file(filename)
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

    template_path = TEMPLATE_DIR+File::SEPARATOR+'template.haml' if template_path.nil?
    template_path = nil unless File.exists?(template_path)

    template_path.nil? ? body : compile(template_path, :body=>body)
  end

  def haml(filename, options={}, &after)
    text = read_file(filename)

    Haml::Engine.new(text).render(Object.new, :body=>options[:body])
  end

  def sass(filename, options={}, &after)
    read_file(filename)

  end

  def markdown(filename, options={}, &after)
    read_file(filename)

  end

  def through(filename, options={}, &after)
    text = read_file(filename)

    after.call(options)
  end

  def extname(filename)
    ext = File.extname(filename)

    ext.gsub!(/^./, '') if ext =~ /^\./

    ext
  end
end