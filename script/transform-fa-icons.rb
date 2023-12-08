#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'

@options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| @options[:input] = o }
  opt.on('--output OUTPUT') { |o| @options[:output] = o }
end.parse!

if @options[:input].nil? || @options[:output].nil?
  puts 'error: no input or output privided'
  exit
end

puts @options
puts 'Starting transformation...'

def file_paths
  Dir.children @options[:input]
end

def open_file(filename)
  File.open "#{@options[:input]}/#{filename}"
end

def transform_file(filedescriptor)
  xml = Nokogiri filedescriptor.read
  svg = xml.at('svg')
  _zero, _nother, width, height = svg['viewBox'].split ' '
  svg['width'] = width
  svg['height'] = height
  xml.to_xml
end

def write_file(transformed_xml, filename)
  filename.gsub! '.svg', '-512.svg'
  out_file_path = "#{@options[:output]}/#{filename}"
  file = File.new out_file_path, 'w'
  file.write transformed_xml
end

############################################

Dir.mkdir @options[:output] unless Dir.exist? @options[:output]

files = file_paths
files.each do |fn| # filename
  fd = open_file fn # filename to filedescriptor
  tf = transform_file fd # file descriptor to transformed xml
  write_file tf, fn # transformed xml to file with filename
end

puts 'Done!'
