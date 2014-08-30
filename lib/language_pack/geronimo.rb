require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"
require 'fileutils'
#require "language_pack/java"

module LanguagePack
  class Geronimo
    
    
    
    include LanguagePack::PackageFetcher
    GERONIMO_CONFIG = File.join(File.dirname(__FILE__), "../../config/is.yml")
    attr_reader :build_path, :cache_path

    # changes directory to the build_path
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end
   
    def compile
      Dir.chdir(@build_path) do
        install_is
        copy_webapp_to_geronimo
        move_geronimo_to_root
      end
     
    end
   
    def install_geronimo
       
       #puts geronimo_package
       FileUtils.mkdir_p geronimo_home
       geronimo_package = geronimo_config["repository_root"]
       filename = geronimo_config["filename"]
       puts "------->Downloading #{filename}  from #{geronimo_package}"
       download_start_time = Time.now
       system("curl #{geronimo_package}/#{filename} -s -o #{filename}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Geronimo"
       download_start_time = Time.now
       #unzip geronimo package in geronimo_home
       system "unzip -oq -d #{geronimo_home} #{filename} 2>&1"
       #move contents of geronimo zip to geronimo_home
       run_with_err_output("mv #{geronimo_home}/geronimo-tomcat*/* #{geronimo_home} && " + "rm -rf #{geronimo_home}/geronimo-tomcat*")
       # delete downloaded zip as we have extracted it now. So the size of droplet will get reduced 
       run_with_err_output("rm -rf geronimo.zip")
       puts "(#{(Time.now - download_start_time).duration})"
        #check for geronimo.sh if available means you have downloaded geronimo successfully
       unless File.exists?("#{geronimo_home}/bin/geronimo.sh")
         puts "Unable to retrieve Geronimo"
         exit 1
       end
      
    end
    def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
    #create deploy folder in geronimo_home for hot deployment
    def copy_webapp_to_geronimo
        run_with_err_output("mkdir -p #{geronimo_home}/deploy && mv * #{geronimo_home}/deploy")
    end
    
    def move_geronimo_to_root
      run_with_err_output("mv #{geronimo_home}/* . && rm -rf #{geronimo_home}")
    end
    def geronimo_home
      ".geronimo_home"
    end
    
    def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end
   end
end
