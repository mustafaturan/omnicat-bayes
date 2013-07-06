module OmniCat
  module Classifiers
    module BayesInternals
      class Category < ::OmniCat::Classifiers::StrategyInternals::Category
        attr_accessor :prior

        def initialize(category_hash = {})
          super(category_hash)
          @prior = category_hash[:prior].to_f
        end
      end
    end
  end
end