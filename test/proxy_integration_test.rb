# frozen_string_literal: true

require_relative "test_helper"

class ProxyIntegrationTest < Minitest::Test
  include Helper

  class TestApp
    def call(env)
      case env["REQUEST_METHOD"]
      when "GET"   then [200, { "Content-Type" => "text/html" }, ["Response for GET\n"]]
      when "OTHER" then [600, { "Content-Type" => "text/html" }, ["Response for OTHER\n"]]
      end
    end
  end

  def setup
    setup_test_protocol

    @server_pid = fork do
      Process.setpgrp # To detach from current process group
      ::Rack::Handler::Toycol.run(TestApp.new, { Port: 12_345 })
    end
  end

  def teardown
    Process.kill(:INT, -Process.getpgid(@server_pid))
  end
end
