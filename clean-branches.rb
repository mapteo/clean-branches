#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/cleaner')

Cleaner.new(ARGV).run

