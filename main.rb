# encoding: utf-8

require './lib/epubgen'

TARGET_DIR = './sample/snedronningen'
OUT_DIR = './tmp'

e = Epubgen.new(TARGET_DIR, OUT_DIR)
e.create
e.to_epub
e.disporse
