# -*- coding: utf-8 -*-

require 'sinatra/base'

class WebApp < Sinatra::Base

  configure do
    use Rack::Session::Pool
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  get '/' do
    @errors = session[:errors]
    session.clear

    @comments = Comment.dataset.all
    erb :index
  end

  post '/comment' do
    begin
    Comment.create(:display_name => params["display_name"],
                   :comment => params["comment"])
    rescue Sequel::ValidationFailed => e
      session[:errors] = e
    end
    redirect '/'
  end
end
