
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
      # Ensure we have the directory
      dir = File.dirname object
      FileUtils.mkdir_p dir
      # Then build
      system "clang #{source} #{flags} -o #{object}"
    end

    # Set up rake hooks
    def setup
      # puts project.sources.inspect
      # puts project.target
      @build_dir = File.join project.dir, 'build'
      unless Dir.exists? @build_dir
        Dir.mkdir @build_dir
      end

      task 'default' => 'build'

      desc 'Build the project'
      task 'build' => project.target do
        puts "Built #{File.basename project.target}".green
      end

      # Build the sources into their objects via the rule below
      file project.target => project.sources.map {|fn| objectsify fn } do |t|
        # Then build the target file from the sources
        target  = t.name
        objects = t.prerequisites
        # Little message
        time_action "Linking #{File.basename target} from #{objects.length.to_s} objects" do
          # Then figure out our frameworks and objects
          objects = objects.join ' '
          frameworks = project.frameworks.map {|f| "-framework #{f}" }.join ' '
          system "clang #{objects} -lobjc #{frameworks} -o #{target}"
        end
      end

      def time_action name
        start = Time.now
        yield
        diff = ((Time.now - start) * 1000).round
        puts name + " (#{diff.to_s} ms)".light_black
      end

      # Set up a file task for every source file to catch changes
      project.sources.each do |src|
        # Figure out where stuff should come from and go to
        source_file = src
        object_file = objectsify src

        file object_file => source_file do |t|
          # Try to strip off the leading directory
          fn = src.sub project.dir+'/', ''
          time_action "Compiling #{fn}" do
            compile source_file, object_file
          end
        end
      end#project.sources.each

      desc 'Clean up build artifacts and target'
      task 'clean' do
        system "rm -f #{project.target}"
        project.sources.each do |fn|
          fn = objectsify fn
          system "rm -f #{fn}"
        end
      end

    end#setup

  end#Rake
end#Dest
