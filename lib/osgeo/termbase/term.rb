module Osgeo::Termbase

class Term

  OUTPUT_ATTRIBS = %i(
    id
    definition
    language_code
    notes
    examples
    comments
    authoritative_source
    terms
  )

  INPUT_ATTRIBS = %i(
    id
    term_preferred
    term_admitted
    term_abbrev
    comments
    definition
    source_link
    source_comment
    note1
    note2
    note3
    example1
    example2
    example3
  )

  attr_accessor *INPUT_ATTRIBS
  attr_reader *OUTPUT_ATTRIBS

  def initialize(**attrs)
    @language_code = "eng"

    assing_attributes(**attrs)
  end

  def assing_attributes(**attrs)
    attrs.each_pair do |name, value|
      public_send(:"#{name}=", value)
    end
  end

  def notes
    [note1, note2, note3].compact
  end

  def examples
    [example1, example2, example3].compact
  end

  # The termid should ALWAYS be an integer.
  # https://github.com/riboseinc/osgeo-termbase/issues/1
  #
  # skalee: not really, but let's keep it this way
  def id=(newid)
    @id = Integer(newid)
  end

  def default_designation
    [term_preferred, term_admitted, term_abbrev].compact.first
  end

  def to_hash
    OUTPUT_ATTRIBS.inject({}) do |acc, attrib|
      value = self.send(attrib)
      unless value.nil?
        acc.merge(attrib.to_s => value)
      else
        acc
      end
    end
  end

  def authoritative_source
    h = {
      "link" => source_link,
      "comment" => source_comment,
      # ref: ''
      # clause: ''
    }
    delete_blank_entries(h)
    h.empty? ? nil : h
  end

  # TODO types
  def terms
    [
      term_hash(:term_preferred),
      term_hash(:term_admitted),
      term_hash(:term_abbrev, abbrev: true),
    ].compact
  end

  def term_hash(attr_name, abbrev: false)
    designation = public_send(attr_name)
    return nil if designation.nil?

    {
      "type" => "expression",
      "designation" => designation,
      "normative_status" => "preferred",
      "abbrev" => (abbrev || nil),
    }.tap(&method(:delete_blank_entries))
  end

  def delete_blank_entries(hash)
    hash.delete_if { |_, v| v.nil? }
    hash
  end
end

end