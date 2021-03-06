module BEL
  module LibBEL
    module NodeTransformation

      def transform(transforms, options = {})
        if options[:mutate] == true
          ast_node = self
        else
          ast_node = LibBEL::copy_ast_node(self)
        end

        transforms.each do |transform|
          transform.call(ast_node)
        end
        ast_node
      end

      def transform_tree(transforms, traversal = :depth_first, options = {})
        if options[:mutate] == true
          ast_node = self
        else
          ast_node = LibBEL::copy_ast_node(self)
        end

        transforms.each do |transform|
          self.traversal_method(ast_node, traversal).call(transform)
        end

        ast_node
      end
    end
  end
end
