module BEL

  # The Translator module defines a plugin that reads a specific document
  # format into BEL evidence and writes BEL evidence back to this document
  # format.
  #
  # - Read
  #   - {#read}:            read the input format and parse to
  #     {::BEL::Model::Evidence} objects
  # - Write
  #   - {#write}:           write {::BEL::Model::Evidence} objects to the
  #     output format
  #
  # @example Create a translator for conversion of YAML <-> BEL Evidence.
  #   module Translator
  #
  #     include ::BEL::Translator
  #
  #     def read(data, options = {})
  #       objects = YAML.load(data)
  #       # map objects to BEL evidence
  #       # return enumerator
  #     end
  #
  #     def write(data, writer = nil, options = {})
  #       # map BEL evidence to YAML objects
  #       YAML.dump(data)
  #     end
  #   end
  module Translator

    # The Plugins module provides a namespace for translator plugins.
    # Translator plugins must be defined within {::BEL::Translator::Plugins}
    # in order to be discovered.
    module Plugins

      # Retrieves one or more translator plugins that were identified by
      # +value+.
      #
      # @param [#to_s] value an id, media type, or file extension value that
      #        identifies a translator plugin
      # @return [#create_translator] if a single a translator plugin was found
      # @return [Array<#create_translator>] if multiple translator plugins
      #         were found
      def self.for(value)
        return nil unless value

        value_symbol = value.to_sym
        plugins      = BEL::Translator.plugins

        return plugins[value_symbol] if plugins.include?(value_symbol)

        matches = plugins.values.select { |t|
          match  = false
          match |= (value_symbol == t.name.to_sym)
          match |= (t.media_types.include?(value_symbol))
          match |= (t.file_extensions.include?(value_symbol))
          match
        }
        matches.size == 1 ? matches.first : matches
      end
    end

    # Set BEL::Translator as a plugin container. All plugins are loaded from
    # +bel/translator/plugins+ on the +LOAD_PATH+. Each plugin must define a
    # module within {::BEL::Translator::Plugins} that corresponds to the file
    # in the plugin path. For example the plugin module
    # +::BEL::Translator::Plugins::Foo+ must be defined within the file
    # +bel/translator/plugins/foo.rb+.
    extend LittlePlugger(
      :path   => 'bel/translator/plugins',
      :module => BEL::Translator::Plugins
    )

    # Read BEL evidence from this translator's supported file format.
    #
    # @param  [IO, String]             data the data to read
    # @param  [Hash{Symbol => Object}] options
    # @return [#each]                  an object that responds to +each+ and
    #         provides {::BEL::Model::Evidence} objects
    def read(data, options = {})
      raise NotImplementedError.new("#{__method__} is not implemented.")
    end

    # Writes BEL evidence +data+ to the provided IO +writer+.
    #
    # @param  [#each]                  data an object that responds to +each+ and
    #         provides {::BEL::Model::Evidence} objects
    # @param  [IO]                     writer an IO to write to
    # @param  [Hash{Symbol => Object}] options
    # @return [IO]                     the IO that was written to
    def write(data, writer = StringIO.new, options = {})
      raise NotImplementedError.new("#{__method__} is not implemented.")
    end
  end
end
