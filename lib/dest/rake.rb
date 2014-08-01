
require 'dest'

module Dest
  class Rake
    # Quick access to setting up the Rake environment
    def self.setup
      self.new.setup
    end
    # Pull in handy Rake DSL
    include ::Rake::DSL

    def project
      Dest::Project.current
    end

    def objectsify fn
      fn.sub(/\.m$/, '.bc').sub project.dir, @build_dir
    end

    def flags
      return @flags if @flags
      flags = []
      flags << '-S' # Only run preprocess and compilation steps
      flags << '-Wall' # All warnings
      flags << '-emit-llvm'
      flags << '-fobjc-arc'
      if project.compile_flags
        flags << project.compile_flags
      end
      @flags = flags.join ' '
    end

    def compile source, object
      # Ensure we have the directory
      dir = File.dirname object
      FileUtils.mkdir_p dir
      # Then build
      sh "clang #{source} #{flags} -o #{object}"
    end

    def time_action name
      start = Time.now
      yield
      diff = ((Time.now - start) * 1000).round
      puts name + " (#{diff.to_s} ms)".light_black
    end

    # Set up rake hooks
    def setup
      @build_dir = File.join project.dir, 'build'
      unless Dir.exists? @build_dir
        Dir.mkdir @build_dir
      end

      task 'default' => 'build'

      desc 'Build the project'
      task 'build' => project.target do
        puts "Built #{File.basename project.target}".green
      end

      self.setup_target
      self.setup_source_files

      if project.test_target
        self.setup_test_target
        self.setup_test_files
      end

      desc 'Clean up build artifacts and target'
      task 'clean' do
        sh "rm -f #{project.target}"
        project.sources.each do |fn|
          fn = objectsify fn
          sh "rm -f #{fn}"
        end
      end
      
      namespace 'test' do
        desc 'Build the test target'
        task 'build' => project.test_target do
          puts "Built #{File.basename project.test_target}".green
        end
        desc 'Clean test build artifacts'
        task 'clean' do
          sh "rm -f #{project.test_target}"
          project.test_sources.each do |fn|
            fn = objectsify fn
            sh "rm -f #{fn}"
          end
        end
      end
      
    end#setup

    # Build the target file from the sources
    def setup_target
      link_target_task project.target, (project.sources + [project.main]).map {|fn| objectsify fn }
    end

    # Set up a file task for every source file
    def setup_source_files
      project.sources.each do |src|
        # Figure out where stuff should come from and go to
        source_file = src
        object_file = objectsify src
        compile_task object_file, source_file
      end#project.sources.each
    end#setup_source_files
    
    # Set up test source files and test target tasks
    def setup_test_files
      project.test_sources.each do |src|
        compile_task objectsify(src), src
      end
    end
    def setup_test_target
      link_target_task project.test_target,
                       (project.sources + project.test_sources).map {|fn| objectsify fn },
                       :frameworks => project.test_frameworks
    end

    private
    def compile_task object, source
      file object => source do |t|
        # Try to strip off the leading directory
        fn = source.sub project.dir+'/', ''
        time_action "Compiling #{fn}" do
          compile source, object
        end
      end
    end
    def link_target_task target, objects, opts = {}
      file target => objects do |t|
        # Little message
        time_action "Linking #{File.basename target} from #{objects.length.to_s} objects" do
          # Then figure out our frameworks and objects
          objects = objects.join ' '
          frameworks = project.frameworks
          if opts[:frameworks]
            opts[:frameworks].each {|f| frameworks << f }
          end
          # Concatenate all the frameworks together
          frameworks = frameworks.map {|f| "-framework #{f}" }.join ' '
          flags = project.link_flags || ''
          sh "clang #{objects} -lobjc #{frameworks} #{flags} -o #{target}"
        end
      end
    end#link_target_task

  end#Rake
end#Dest
