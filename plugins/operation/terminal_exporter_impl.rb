# frozen_string_literal: true

require "pal"
require "pal/operation/exporter"

module Pal
  module Operation
    class TerminalExporterImpl < BaseExportHandlerImpl
      def _export(rows, _column_headers)
        puts "Inside plugin! You passed me [#{rows.size}] rows"
      end
    end
  end
end
