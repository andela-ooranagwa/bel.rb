module BEL::Translator::Plugins

  module Rdfa

    ID          = :rdfa
    NAME        = 'RDFa RDF Translator'
    DESCRIPTION = 'A translator that can read and write RDFa (https://rdfa.info/) for BEL evidence.'
    MEDIA_TYPES = %i(application/xml)
    EXTENSIONS  = %i(rdfa)

    def self.create_translator(options = {})
      require 'rdf'
      require 'rdf/rdfa'
      require_relative 'rdf/translator'

      BEL::Translator::Plugins::Rdf::RdfTranslator.new(ID)
    end

    def self.id
      ID
    end

    def self.name
      NAME
    end

    def self.description
      DESCRIPTION
    end

    def self.media_types
      MEDIA_TYPES
    end 

    def self.file_extensions
      EXTENSIONS
    end
  end
end