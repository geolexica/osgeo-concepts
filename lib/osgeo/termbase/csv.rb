
require "csv"
require "yaml"
require "pathname"

require_relative "term"

module Osgeo::Termbase

class Csv
  attr_accessor :filename, :config

  COLUMN_ATTR_NAMES = Osgeo::Termbase::Term::INPUT_ATTRIBS.map { |str| :"#{str}_column" }

  # Spreadsheet config
  Config = Struct.new(:header_row_index, *COLUMN_ATTR_NAMES, keyword_init: true)

  def initialize(filepath, config)
    @config = config
    @filename = filepath
    @languages = languages_supported
    self
  end

  def languages_supported
    "eng"
  end

  def csv
    @csv ||= load_csv
  end

  def concepts
    @concepts ||= load_concepts
  end

  def load_csv
    raw = File.read(@filename)

    # Google Sheets always uses \n at the last line end, but \r\n for all other line breaks
    # which causes Ruby's CSV to show this error:
    # CSV::MalformedCSVError: Unquoted fields do not allow \r or \n
    # Here we replace the DOS \r\n with Unix \n
    csv_content = raw.gsub(/\r\n/, "\n")

    CSV.new(
      csv_content,
      liberal_parsing: true,
      skip_blanks: true
    )
  end

  def load_concepts
    # Was easier to change than #inject
    concepts = []

    csv.each_with_index do |row, i|
      next if i <= config.header_row_index
      term = parse_csv_row(row, i)
      concepts.push(term)
    end

    concepts
  end

  def parse_csv_row(row, i)
    get_column = ->(name, wrap_in_array: false) do
      column_idx = config.send(:"#{name}_column")
      value = column_idx ? row[column_idx] : nil
      value && wrap_in_array ? [value] : value
    end

    Term.new(
      id: i - config.header_row_index,
      term_preferred: get_column.(:term_preferred),
      term_admitted: get_column.(:term_admitted),
      term_abbrev: get_column.(:term_abbrev),
      comments: get_column.(:comments, wrap_in_array: true),
      definition: get_column.(:definition),
      source_comment: get_column.(:source_comment),
      source_link: get_column.(:source_link),
    )
  end

end
end
