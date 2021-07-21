# frozen_string_literal: true

module Toycol
  # For HTTP Protocol
  DEFAULT_HTTP_REQUEST_METHODS = %w[
    GET
    HEAD
    POST
    OPTIONS
    PUT
    DELETE
    TRACE
    PATCH
    LINK
    UNLINK
  ].freeze

  DEFAULT_HTTP_STATUS_CODES = {
    100 => "Continue",
    101 => "Switching Protocols",
    102 => "Processing",
    200 => "OK",
    201 => "Created",
    202 => "Accepted",
    203 => "Non-Authoritative Information",
    204 => "No Content",
    205 => "Reset Content",
    206 => "Partial Content",
    207 => "Multi-Status",
    208 => "Already Reported",
    226 => "IM Used",
    300 => "Multiple Choices",
    301 => "Moved Permanently",
    302 => "Found",
    303 => "See Other",
    304 => "Not Modified",
    305 => "Use Proxy",
    307 => "Temporary Redirect",
    308 => "Permanent Redirect",
    400 => "Bad Request",
    401 => "Unauthorized",
    402 => "Payment Required",
    403 => "Forbidden",
    404 => "Not Found",
    405 => "Method Not Allowed",
    406 => "Not Acceptable",
    407 => "Proxy Authentication Required",
    408 => "Request Timeout",
    409 => "Conflict",
    410 => "Gone",
    411 => "Length Required",
    412 => "Precondition Failed",
    413 => "Payload Too Large",
    414 => "URI Too Long",
    415 => "Unsupported Media Type",
    416 => "Range Not Satisfiable",
    417 => "Expectation Failed",
    418 => "I'm A Teapot",
    421 => "Misdirected Request",
    422 => "Unprocessable Entity",
    423 => "Locked",
    424 => "Failed Dependency",
    426 => "Upgrade Required",
    428 => "Precondition Required",
    429 => "Too Many Requests",
    431 => "Request Header Fields Too Large",
    451 => "Unavailable For Legal Reasons",
    500 => "Internal Server Error",
    501 => "Not Implemented",
    502 => "Bad Gateway",
    503 => "Service Unavailable",
    504 => "Gateway Timeout",
    505 => "HTTP Version Not Supported",
    506 => "Variant Also Negotiates",
    507 => "Insufficient Storage",
    508 => "Loop Detected",
    510 => "Not Extended",
    511 => "Network Authentication Required"
  }.freeze

  # For connection from proxy server to app server
  UNIX_SOCKET_PATH = ENV["TOYCOL_SOCKET_PATH"] || "/tmp/toycol.socket"

  # Rack compartible environment
  PATH_INFO         = "PATH_INFO"
  QUERY_STRING      = "QUERY_STRING"
  REQUEST_METHOD    = "REQUEST_METHOD"
  SERVER_NAME       = "SERVER_NAME"
  SERVER_PORT       = "SERVER_PORT"
  CONTENT_LENGTH    = "CONTENT_LENGTH"
  RACK_VERSION      = "rack.version"
  RACK_INPUT        = "rack.input"
  RACK_ERRORS       = "rack.errors"
  RACK_MULTITHREAD  = "rack.multithread"
  RACK_MULTIPROCESS = "rack.multiprocess"
  RACK_RUN_ONCE     = "rack.run_once"
  RACK_URL_SCHEME   = "rack.url_scheme"
end
