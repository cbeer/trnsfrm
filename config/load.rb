require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'digest/md5'
require 'fileutils'
require 'pairtree'

services_root = File.expand_path('../../', __FILE__)
$:.unshift services_root if !$:.include?(services_root)

services_lib = File.expand_path('../../lib', __FILE__)
$:.unshift services_lib if !$:.include?(services_lib)

# Child processes inherit our load path.
ENV['RUBYLIB'] = $:.compact.join(':')

require File.expand_path('../../lib/trnsfrm', __FILE__)

