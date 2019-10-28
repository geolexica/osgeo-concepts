
require "csv"
require "yaml"
require "pathname"

module Osgeo::Termbase

class Csv
  attr_accessor :filename

  def initialize(filepath)
    @filename = filepath
    @languages = languages_supported
    self
  end

  def languages_supported
    "eng"
  end

  def concept_collection
    collection = ConceptCollection.new

    csv_content = File.read(@filename)

    # Google Sheets always uses \n at the last line end, but \r\n for all other line breaks
    # which causes Ruby's CSV to show this error:
    # CSV::MalformedCSVError: Unquoted fields do not allow \r or \n
    # Here we replace the DOS \r\n with Unix \n
    csv_content = csv_content.gsub(/\r\n/, "\n")

    # puts csv_content

    CSV.new(
      csv_content,
      liberal_parsing: true,
      skip_blanks: true
    ).each_with_index do |row, i|
      next if i < 3
      term = Term.new(
        id: i - 2,
        term: row[0],
        type: row[1],
        domain: row[2],
        comments: row[3] && [row[3]],
        definition: row[4],
        authoritative_source: {
          "link" => row[5],
          # ref: '',
          # clause: ''
        },
        entry_status: row[6],
        language_code: "eng"
      )

      # puts term.to_hash
      collection.add_term(term)
    end

    collection
  end

end
end
