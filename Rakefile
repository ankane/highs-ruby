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
  "1.2.1"
end

def download_file(library, remote_lib, file, sha256)
  require "fileutils"
  require "open-uri"
  require "tmpdir"

  url = "https://github.com/JuliaBinaryWrappers/HiGHS_jll.jl/releases/download/HiGHS-v#{version}%2B0/#{file}"
  puts "Downloading #{file}..."
  contents = URI.open(url).read

  computed_sha256 = Digest::SHA256.hexdigest(contents)
  raise "Bad hash: #{computed_sha256}" if computed_sha256 != sha256

  Dir.chdir(Dir.mktmpdir) do
    File.binwrite(file, contents)
    command = "tar xzf"
    system "#{command} #{file}"
    dest = File.expand_path("vendor", __dir__)

    FileUtils.cp("lib/#{remote_lib}", "#{dest}/#{library}")
    puts "Saved vendor/#{library}"

    if library.end_with?(".so")
      license_path = "share/licenses/HiGHS/LICENSE"
      raise "Unexpected licenses" unless Dir["share/licenses/**/*"] != [license_path]
      FileUtils.cp(license_path, "#{dest}/LICENSE")
      puts "Saved vendor/LICENSE"
    end
  end
end

# https://github.com/JuliaBinaryWrappers/HiGHS_jll.jl/releases
namespace :vendor do
  task :linux do
    download_file("libhighs.so", "libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "114482607b7e74fe1b423c7d30249427e208db9e71b1ccf58f7c5d3749269230")
    download_file("libhighs.arm64.so", "libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "ab3f71c0ab1806ed5848cd65a0f4d948c159a55f1c5dfca705ca35aa58cc8507")
  end

  task :mac do
    download_file("libhighs.dylib", "libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "347fb831dbeb5955f040fff5026cc75b2d6b105ca96bcd87a17c93a89906cb6b")
    download_file("libhighs.arm64.dylib", "libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "4373b67476d09e1ea528af9a927cbf11ff831df3e53a14c632c1b7d7479ccb43")
  end

  task :windows do
    # download_file("libhighs.dll.a", "libhighs.dll.a", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "a0cfe41a88ee636c6eba019110bc4e9e21c59f376a7b6d2207aa4485c21998dd")
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
