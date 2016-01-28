module BEL::Translator::Plugins

  module Rj

    ID          = :rj
    NAME        = 'RDF/JSON RDF Translator'
    DESCRIPTION = 'A translator that can read and write RDF/JSON (https://dvcs.w3.org/hg/rdf/raw-file/default/rdf-json/index.html) for BEL evidence.'
    MEDIA_TYPES = %i(application/rdf+json)
    EXTENSIONS  = %i(rj)

    def self.create_translator(options = {})
      require 'rdf'
      require 'rdf/json'
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
