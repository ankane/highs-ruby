# stdlib
require "fiddle/import"

# modules
require "highs/array"
require "highs/methods"
require "highs/model"
require "highs/version"

module Highs
  class Error < StandardError; end

  extend Methods

  class << self
    attr_accessor :ffi_lib
  end
  lib_name =
    if Gem.win_platform?
      # uses lib prefix for Windows
      "libhighs.dll"
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "libhighs.arm64.dylib"
      else
        "libhighs.dylib"
      end
    else
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "libhighs.arm64.so"
      else
        "libhighs.so"
      end
    end
  vendor_lib = File.expand_path("../vendor/#{lib_name}", __dir__)
  self.ffi_lib = [vendor_lib]

  # friendlier error message
  autoload :FFI, "highs/ffi"
end
