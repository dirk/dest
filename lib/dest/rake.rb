
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
      @flags = flags.join ' '
    end

    def compile source, object
      sh "clang #{source} #{flags} -o #{object}"
    end

    # Set up rake hooks
    def setup
      # puts project.sources.inspect
      # puts project.target
      @build_dir = File.join project.dir, 'build'
      unless Dir.exists? @build_dir
        Dir.mkdir @build_dir
      end

      desc 'Build the project'
      task 'build' => project.target do
        puts "Built #{File.basename project.target}"
      end

      # Build the sources into their objects via the rule below
      file project.target => project.sources.map {|fn| objectsify fn } do |t|
        # Then build the target file from the sources
        target  = t.name
        objects = t.prerequisites
        # Little message
        puts "Linking #{File.basename target} from #{objects.length.to_s} objects"
        # Then figure out our frameworks and objects
        objects = objects.join ' '
        frameworks = project.frameworks.map {|f| "-framework #{f}" }.join ' '
        sh "clang #{objects} -lobjc #{frameworks} -o #{target}"
      end

      # Set up a file task for every source file to catch changes
      project.sources.each do |src|
        # Figure out where stuff should come from and go to
        source_file = src
        object_file = objectsify src

        file object_file => source_file do |t|
          basename = File.basename src
          puts "Compiling #{basename}"

          compile source_file, object_file
        end
      end

    end#self.setup
  end#Rake
end#Dest
