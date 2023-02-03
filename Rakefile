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
  "1.4.1"
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
    download_file("libhighs.so", "lib/libhighs.so", "HiGHS.v#{version}.x86_64-linux-gnu-cxx11.tar.gz", "aaa82b2dbb647a05e17a3af2068f5608199c4cd02327124b5292b7b7cd6fe64a")
    download_file("libhighs.arm64.so", "lib/libhighs.so", "HiGHS.v#{version}.aarch64-linux-gnu-cxx11.tar.gz", "1734390afee5c43149f6cb04dcf225112bf7b979e84850e2812c218259d7729e")
  end

  task :mac do
    download_file("libhighs.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.x86_64-apple-darwin.tar.gz", "30e0e0abbdf9edff9e374c05b48aa14ecad16369af694ec2b52c611f86f7092c")
    download_file("libhighs.arm64.dylib", "lib/libhighs.dylib", "HiGHS.v#{version}.aarch64-apple-darwin.tar.gz", "577dd4b2204042870f7d7b47c626205db44160456e8c0bc1fafc9c660ef693e1")
  end

  task :windows do
    download_file("libhighs.dll", "bin/libhighs.dll", "HiGHS.v#{version}.x86_64-w64-mingw32-cxx11.tar.gz", "c520d1ee90056d2ab65cb36870e998273745c69109e57acf93644872bdbb8aad")
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
