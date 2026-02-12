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
  "1.11.0"
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
    download_file("libhighs.so", "lib/libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "2e93fc61565295e67cc4e0e902f4cd3f2d3c6984799be66710159078c0ec3a4c")
    download_file("libhighs.arm64.so", "lib/libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "aab4feb8dbdf13706ed2b9d46af2625245d212ed7e1c370ff30076c9b4043bd2")
  end

  task :mac do
    download_file("libhighs.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "e35c969a7f62c762a5c6e2379b8d7d85914dbb786513c558c5e3a3cf340790ff")
    download_file("libhighs.arm64.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "f329379db8ab2e14f652b15af6fe0fabfa17674d289057367cd83469eff0dd8b")
  end

  task :windows do
    download_file("libhighs.dll", "bin/libhighs.dll", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "8c59525eda77c981e2ce9e513282abe429d1cc2959fddaa67d36904953894a56")
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
