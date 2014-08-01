
module Dest
  module Project
    class << self
      attr_accessor :current
    end

    class Base
      attr_reader   :dir
      attr_accessor :frameworks, :sources, :target
      def initialize dir
        @dir = dir
        @frameworks = ['Foundation']
        @sources = scan_sources
        @target = guess_target
      end
      def scan_sources
        src  = Dir[File.join(@dir, 'src', '*.m')]
        root = Dir[File.join(@dir, '*.m')]
        return src + root
      end
      def guess_target
        # Turns '/a/b/c' into just 'c'
        File.basename dir
      end

      def self.setup dir=nil, &block
        unless dir
          dir = ::Rake.application.original_dir
        end
        proj = self.new dir
        Dest::Project.current = proj
        block.call proj
      end
    end
  end
end
