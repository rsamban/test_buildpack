require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"
require 'fileutils'
#require "language_pack/java"

module LanguagePack
  class Geronimo
    
    
    
    include LanguagePack::PackageFetcher
    IS_CONFIG = File.join(File.dirname(__FILE__), "../../config/is.yml")
    attr_reader :build_path, :cache_path

    # changes directory to the build_path
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end
   
    def compile
	puts "Entering rs.rb compile...."
      Dir.chdir(@build_path) do
	puts "After Changing to build dir..."
        install_is
	puts "After Installing IS"
      end
     
    end
   
    def install_is
       #puts is_server
       # FileUtils.mkdir_p geronimo_home
       is_server = is_config["repository_root"]
       filename = is_config["filename"]
       puts "------->Downloading #{filename}  from #{is_server}"
       download_start_time = Time.now
       system("curl #{is_server}/#{filename} -s -o #{filename}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Integration Server"
       download_start_time = Time.now
       #unzip geronimo package in geronimo_home
       system "tar xf #{filename} 2>&1"
    end

    def is_config
      YAML.load_file(File.expand_path(IS_CONFIG))
    end
   end
end
