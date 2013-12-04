#!/usr/bin/env ruby

require 'pathname'

require File.join(File.dirname(Pathname.new(__FILE__).realpath), 'lib/cleaner')

Cleaner.new(ARGV).run

