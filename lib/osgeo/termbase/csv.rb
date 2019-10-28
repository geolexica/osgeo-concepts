
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

    CSV.foreach(@filename).each_with_index do |row, i|
      next if i < 3
      term = Term.new(
        id: i - 2,
        term: row[0],
        type: row[1],
        domain: row[2],
        comments: row[3] && [row[3]],
        definition: row[4],
        authoritative_source: row[5],
        entry_status: row[6],
        language_code: "eng"
      )

      collection.add_term(term)
    end

    collection
  end

end
end
