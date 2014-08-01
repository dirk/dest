
module Dest
  module Project
    class << self
      attr_accessor :current
    end

    class Base
      attr_accessor :dir, :frameworks, :sources, :target, :compile_flags, :link_flags, :main
      # Testing stuff
      attr_accessor :test_frameworks, :test_target, :test_sources

      def initialize dir
        @dir = dir
        @frameworks = ['Foundation']
        @sources = []
        @target  = guess_target
        @compile_flags = ''
        @link_flags    = ''
        @main = guess_main

        @test_frameworks = []
        @test_target = nil
        @test_sources = []
      end
      # def scan_sources
      #   src  = Dir[File.join(@dir, 'src', '**/*.m')]
      #   root = Dir[File.join(@dir, '*.m')]
      #   return src + root
      # end
      def add_source fn
        @sources << File.expand_path(fn)
      end
      alias :add_source_file :add_source
      def add_source_directory dir
        glob_sources(dir).each {|fn| @sources << fn }
      end
      def add_test_directory dir
        glob_sources(dir).each {|fn| @test_sources << fn }
      end

      # Handy utility method to pull in special Xcode frameworks needed for
      # testing and the like.
      def include_xcode_frameworks!
        @compile_flags << "-F #{Dest::Util::XCODE_FRAMEWORKS}"
        @link_flags    << "-F #{Dest::Util::XCODE_FRAMEWORKS} -Wl,-rpath,#{Dest::Util::XCODE_FRAMEWORKS}"
      end

      def guess_target
        # Turns '/a/b/c' into just 'c'
        File.basename dir
      end
      def guess_main
        File.join(@dir, 'main.m')
      end

      def self.setup dir=nil, &block
        unless dir
          dir = ::Rake.application.original_dir
        end
        proj = self.new dir
        Dest::Project.current = proj
        block.call proj
      end

      private
      def glob_sources dir
        Dir[File.join dir, '**/*.m'].map {|fn| File.expand_path fn }
      end

    end
  end
end
