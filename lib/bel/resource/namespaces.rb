require          'rdf'
require_relative 'namespace'

module BEL
  module Resource

    # TODO Document
    class Namespaces

      # TODO Document
      QUERY_NAMESPACES = RDF::Query.new do
        pattern [:uri, RDF.type, BELV.NamespaceConceptScheme]
      end

      # TODO Document
      def initialize(rdf_repository)
        @rdf_repository = rdf_repository
      end

      # TODO Document
      def each
        return to_enum(:each) unless block_given?
				@rdf_repository.
					query(QUERY_NAMESPACES) { |solution|
						yield Namespace.new(@rdf_repository, solution.uri)
					}
      end

      def find(*namespaces)
        return to_enum(:find, *namespaces) unless block_given?

        namespaces.flatten.each do |ns|
          yield find_namespace(ns)
				end
			end

      protected

      def find_namespace(namespace)
        # nil input always yield nil
        return nil if namespace == nil

        # empty literals will match in a pattern as if it was nil
        # so return nil if empty string
        nstr = namespace.to_s
        return nil if nstr.empty?

        # URI handled by regex match on string
        return find_namespace_uri(nstr) if nstr =~ FULL_URI_REGEX

        # match input as namespace prefix
				nlit   = RDF::Literal(nstr)
				prefix = namespace_query(
					:predicate => BELV.prefix,
					:object    => nlit
				)
			  return Namespace.new(@rdf_repository, prefix.subject) if prefix

        # match input as namespace prefLabel
				label  = namespace_query(
					:predicate => RDF::SKOS.prefLabel,
					:object    => nlit
				)
				return Namespace.new(@rdf_repository, label.subject) if label
      end

      def find_namespace_uri(uri_s)
        subject    = RDF::URI(uri_s)
        type_check = RDF::Statement(subject, RDF.type, BELV.NamespaceConceptScheme)
				if @rdf_repository.has_statement?(type_check)
          return Namespace.new(@rdf_repository, subject)
        end
			end

      def namespace_query(pattern)
				@rdf_repository.query(pattern).find { |solution|
				  @rdf_repository.has_statement?(
						RDF::Statement(solution.subject, RDF.type, BELV.NamespaceConceptScheme)
					)
				}
      end
    end
  end
end
