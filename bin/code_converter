#!/usr/bin/env ruby
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'motion/code_converter'

code = $stdin.read
cnv  = Motion::CodeConverter.new(code)
puts cnv.result
