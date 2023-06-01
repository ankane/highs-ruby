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
  "1.5.3"
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
    download_file("libhighs.so", "lib/libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "be177f17f1772bf98c0c07051976f7e89908df8fab4bba19dda35536d70e586f")
    download_file("libhighs.arm64.so", "lib/libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "f7c616d1b4ad28491a070be33fe913214a29f9a9410c34a7d08b597947dbabc9")
  end

  task :mac do
    download_file("libhighs.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "eac3e95e165a1a30b09cfce49b8b5886200ea11ad246bb9ea6c4e661e1f6192d")
    download_file("libhighs.arm64.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "079d7b10badcefb2d03081e56cf24ca4ea5c1962724ca9d16ffb1768fdb5134e")
  end

  task :windows do
    download_file("libhighs.dll", "bin/libhighs.dll", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "4695da78165e10a7c87c059515a11719f3c161b1a633e82cd5f450cb5ec52b0e")
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
