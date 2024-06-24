require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

shared_libraries = %w(libhighs.so libhighs.arm64.so libhighs.dylib libhighs.arm64.dylib)

# ensure vendor files exist
task :ensure_vendor do
  shared_libraries.each do |file|
    raise "Missing file: #{file}" unless File.exist?("vendor/#{file}")
  end
end

Rake::Task["build"].enhance [:ensure_vendor]

def version
  "1.7.1"
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
    download_file("libhighs.so", "lib/libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "b6b8f8077175e69cf464a660404419a9f06b11485805af5af06cdb5b411877e7")
    download_file("libhighs.arm64.so", "lib/libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "e4bf361d016674a688ffcc44539a9eadbbcd7b8ceb6e436f7ac38871eee216a9")
  end

  task :mac do
    download_file("libhighs.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "72d3020c596dd5ef7fad9d60279a052785c90b9c0d9772b0411f84492b8abba8")
    download_file("libhighs.arm64.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "d27509f14c6a6144bbf91ab0b25b1641ebad7201535ac5967bb7eadbb877fca2")
  end

  task :windows do
    download_file("libhighs.dll", "bin/libhighs.dll", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "9b500d281491365730d3b6ff1f3b6f7c777e9ee009771732250e185f1affa29e")
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
