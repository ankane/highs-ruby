require "bundler/gem_tasks"
require "rake/testtask"
require "ruby_memcheck"

test_config = lambda do |t|
  t.pattern = "test/**/*_test.rb"
end
Rake::TestTask.new(&test_config)

namespace :test do
  RubyMemcheck::TestTask.new(:valgrind, &test_config)
end

task default: :test

shared_libraries = %w(libhighs.so libhighs.arm64.so libhighs.dylib libhighs.arm64.dylib)

# ensure vendor files exist
task :ensure_vendor do
  shared_libraries.each do |file|
    raise "Missing file: #{file}" unless File.exist?("vendor/#{file}")
  end
end

Rake::Task["build"].enhance [:ensure_vendor]

def version
  "1.15.0"
end

def download_file(library, remote_lib, file, sha256)
  require "fileutils"
  require "open-uri"
  require "tmpdir"

  url = "https://github.com/JuliaBinaryWrappers/HiGHS_jll.jl/releases/download/HiGHS-v#{version}%2B0/#{file}"
  puts "Downloading #{file}..."
  contents = URI.parse(url).read

  computed_sha256 = Digest::SHA256.hexdigest(contents)
  raise "Bad hash: #{computed_sha256}" if computed_sha256 != sha256

  Dir.chdir(Dir.mktmpdir) do
    File.binwrite(file, contents)
    command = "tar xzf"
    system "#{command} #{file}"
    dest = File.expand_path("vendor", __dir__)

    FileUtils.cp(remote_lib, "#{dest}/#{library}")
    puts "Saved vendor/#{library}"

    if library.end_with?(".so")
      license_path = "share/licenses/HiGHS/LICENSE.txt"
      raise "Unexpected licenses" unless Dir["share/licenses/**/*"] != [license_path]
      FileUtils.cp(license_path, "#{dest}/LICENSE.txt")
      puts "Saved vendor/LICENSE.txt"
    end
  end
end

# https://github.com/JuliaBinaryWrappers/HiGHS_jll.jl/releases
namespace :vendor do
  task :linux do
    download_file("libhighs.so", "lib/libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "2058c4f7193190fb08d711c959706c909a93577977e0fd530683625efa59c2a0")
    download_file("libhighs.arm64.so", "lib/libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "4a3896be8bfc450d77006e49d107e274ad929784557547221d9b603bd5a31f7c")
  end

  task :mac do
    download_file("libhighs.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "ebbb31118d34eaaec93ba583c7ebac5499a06c6dd5b1d7028b1bc85c77a869ae")
    download_file("libhighs.arm64.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "74f24e72ad9d5b11370974b5e88a757c801aa811902a7c5ec6ef558a7c518017")
  end

  task :windows do
    download_file("libhighs.dll", "bin/libhighs.dll", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "b3ad0718e882583442a1e8ab2c1938ac1312fe063c51a85ebb406409f004e40f")
  end

  task all: [:linux, :mac, :windows]

  task :platform do
    if Gem.win_platform?
      Rake::Task["vendor:windows"].invoke
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      Rake::Task["vendor:mac"].invoke
    else
      Rake::Task["vendor:linux"].invoke
    end
  end
end
