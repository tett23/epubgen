# encoding: utf-8

require './lib/epubgen'

TARGET_DIR = './target'
OUT_DIR = './tmp'

e = Epubgen.new(TARGET_DIR, OUT_DIR)
e.create
e.to_epub
e.disporse
