
require 'colorize'

require 'dest/version'
require 'dest/project/base'

module Dest
  module Util
    XCODE_FRAMEWORKS = File.join(`xcode-select -p`.strip, 'Library', 'Frameworks')
  end
end
