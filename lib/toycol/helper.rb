# frozen_string_literal: true

module Toycol
  module Helper
    def logger(message)
      puts "[Toycol] #{message}"
    end

    private

    def safe_execution!(&block)
      safe_executionable_tp.enable(&block)
    end

    def safe_executionable_tp
      @safe_executionable_tp ||= TracePoint.new(:script_compiled) do |tp|
        if tp.binding.receiver == Protocol && tp.method_id.to_s.match?(unauthorized_methods_regex)
          raise UnauthorizeError, <<~ERROR
            - Unauthorized method was called!
            You can't use methods that may cause injections in your protocol.
            Ex. Kernel.#eval, Kernel.#exec, Kernel.#require and so on.
          ERROR
        end
      end
    end

    def unauthorized_methods_regex
      /(.*eval|.*exec|`.+|%x\(|system|open|require|load)/
    end
  end
end
