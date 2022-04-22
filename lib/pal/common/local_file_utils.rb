# frozen_string_literal: true

require "pal"
require "fileutils"

module Pal
  module Common
    class LocalFileUtils

      def self.with_file(path, extension, &block)
        dir = File.dirname(path)

        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        path << ".#{extension}"
        File.open(path, "w", &block)
      end

      def self.clean_dir(path)
        dir = File.dirname(path)

        FileUtils.rm_f(dir) if File.directory?(dir)
      end
    end
  end
end
