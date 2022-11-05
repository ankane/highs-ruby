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
  "1.3.0"
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
    download_file("libhighs.so", "libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "6cee1e126274c0da044e5b1ed724076e83859b0df65209a18c1cd6b38a0db831")
    download_file("libhighs.arm64.so", "libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "bda22d8a97f53a52a5a429823603729a5a069535de8b6a60c04ad99ad5852032")
  end

  task :mac do
    download_file("libhighs.dylib", "libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "5ba475ec05a4233f428f8d406d366d4795c759827e6949ee644e5714865534d7")
    download_file("libhighs.arm64.dylib", "libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "cb8bb1a5dadb0c98e2bdcc2b9e63323e76eb35657e081a115c0eb3cb939cb159")
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
