module Unitize
  module Expression
    # Matcher is responsible for building up Parslet alternatives of atoms and
    # prefixes to be used by Unitize::Expression::Parser.
    class Matcher
      class << self
        def atom(mode)
          new(Atom.all, mode).alternative
        end

        def metric_atom(mode)
          new(Atom.all.select(&:metric?), mode).alternative
        end

        def prefix(mode)
          new(Prefix.all, mode).alternative
        end
      end

      attr_reader :collection, :mode

      def initialize(collection, mode = :code)
        @collection = collection
        @mode = mode
      end

      def strings
        collection.map(&mode).flatten.compact.sort do |x, y|
          y.length <=> x.length
        end
      end

      def matchers
        strings.map { |s| Parslet::Atoms::Str.new(s) }
      end

      def alternative
        Parslet::Atoms::Alternative.new(*matchers)
      end
    end
  end
end
