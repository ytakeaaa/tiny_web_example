# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'sinatra/config_file'

config_file 'config/webapp.yml', '/etc/tiny-web-example/webapp.yml'

$LOAD_PATH.unshift File.expand_path('..', __FILE__)

require 'webapp'
require 'models/comment'

run WebApp