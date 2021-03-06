# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "toycol"
require_relative "post"

Toycol::Protocol.use(:safe_ruby_with_sinatra)

class App < Sinatra::Base
  set :server, :toycol
  set :port, 9292

  get "/posts" do
    @posts = params[:user_id] ? Post.where(user_id: params[:user_id]) : Post.all

    erb :index
  end

  post "/posts" do
    Post.new(user_id: params[:user_id], body: params[:body])
    @posts = Post.all

    erb :index
  end

  run! if app_file == $PROGRAM_NAME
end
