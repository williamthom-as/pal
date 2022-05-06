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

      def self.read_file(file_location)
        result = file_location.start_with?("/") ? file_location : File.join(File.dirname(__FILE__), file_location)

        raise "No file found at [#{file_location}]" unless File.exist? result

        File.read(result)
      end
    end
  end
end
