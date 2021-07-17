# frozen_string_literal: true

class Post
  @posts ||= []

  class << self
    def all
      @posts
    end

    def where(user_id: nil)
      @posts.select do |post|
        post.user_id == Integer(user_id) if user_id
      end
    end

    def insert(record)
      @posts << record
    end
  end

  attr_reader :user_id, :body

  def initialize(user_id:, body:)
    @user_id = Integer(user_id)
    @body    = body

    self.class.insert self
  end
end

# Initial records
Post.new(user_id: 1, body: "I love Ruby!")
Post.new(user_id: 2, body: "I love RubyKaigi!")
