unless BEL::Features.sqlite3_support?
  # rdf and addressable are required
  raise RuntimeError, %Q{The sqlite3 configuration for BEL::Search is not supported.
The sqlite3 gem is required.

Install the gems:
      gem install sqlite3}
end

require_relative 'identifier_search'
require 'sqlite3'

module BEL
  module Search

    class Sqlite3FTS
      include BEL::Search::IdentifierSearch

      GLOBAL_FTS_QUERY = '''
        select
          uri, scheme_uri, identifier, pref_label, alt_labels, snippet(literals_fts) as snippet
        from
          literals_fts
        where
          literals_fts MATCH ?'''
        .gsub(/[ \n]{2,}/, ' ')
      SCHEME_FTS_QUERY = GLOBAL_FTS_QUERY + ' and scheme_uri = ?'

      def initialize(options = {})
        @db_file = options.delete(:db_file)
        unless @db_file or File.readable?(@db_file)
          fail ArgumentError.new('The db_file option cannot be read.')
        end

        @db = SQLite3::Database.new @db_file
        @db.results_as_hash = true
        @gq = @db.prepare(GLOBAL_FTS_QUERY)
        @sq = @db.prepare(SCHEME_FTS_QUERY)
      end

      # see {BEL::IdentifierSearch#search_annotations}
      def search_annotations(query_expression, scheme_uri = nil, options = {})
        nil
      end

      # see {BEL::IdentifierSearch#search_namespaces}
      def search_namespaces(query_expression, scheme_uri = nil, options = {})
        result_set =
          if scheme_uri
            @sq.execute(query_expression, scheme_uri)
          else
            @gq.execute(query_expression)
          end
        if result_set.respond_to? :lazy
          result_set = result_set.lazy
        end
        result_set.map { |result_hash|
          symbolize_keys!(result_hash)
          result_hash[:alt_labels] = (result_hash[:alt_labels] || '').split('|')
          SearchResult.new(result_hash)
        }
      end

      private

      def symbolize_keys!(hash)
        hash.keys.each do |key|
            hash[(key.to_sym rescue key) || key] = hash.delete(key)
        end
      end
    end
  end
end
