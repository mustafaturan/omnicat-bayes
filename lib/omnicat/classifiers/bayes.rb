require 'omnicat/classifiers/strategy'

module OmniCat
  module Classifiers
    class Bayes < ::OmniCat::Classifiers::Strategy
      attr_accessor :k_value # Integer - Helper value for skipping some Bayes algorithm errors

      def initialize(bayes_hash = {})
        super(bayes_hash)
        if bayes_hash.has_key?(:categories)
          bayes_hash[:categories].each do |name, category|
            @categories[name] = ::OmniCat::Classifiers::BayesInternals::Category.new(category)
          end
        end
        @k_value = bayes_hash[:k_value] || 1.0
      end

      # Allows adding new classification category
      #
      # ==== Parameters
      #
      # * +category_name+ - Name for category
      #
      # ==== Examples
      #
      #   # Create a classification category
      #   bayes = Bayes.new
      #   bayes.add_category("positive")
      def add_category(category_name)
        if category_exists?(category_name)
          raise StandardError,
                "Category with name '#{category_name}' is already exists!"
        else
          increment_category_count
          @categories[category_name] = ::OmniCat::Classifiers::BayesInternals::Category.new
        end
      end

      # Train the desired category with a document
      #
      # ==== Parameters
      #
      # * +category_name+ - Name of the category from added categories list
      # * +doc_content+ - Document text
      #
      # ==== Examples
      #
      #   # Train the desired category
      #   bayes.train("positive", "clear documentation")
      #   bayes.train("positive", "good, very well")
      #   bayes.train("negative", "bad dog")
      #   bayes.train("neutral", "how is the management gui")
      def train(category_name, doc_content)
        if category_exists?(category_name)
          increment_doc_counts(category_name)
          update_priors
          doc = OmniCat::Doc.new(content: doc_content)
          doc.tokens.each do |token, count|
            increment_token_counts(category_name, token, count)
            @categories[category_name].tokens[token] = @categories[category_name].tokens[token].to_i + count
          end
        else
          raise StandardError,
                "Category with name '#{category_name}' does not exist!"
        end
      end

      # Classify the given document
      #
      # ==== Parameters
      #
      # * +doc_content+ - The document for classification
      #
      # ==== Returns
      #
      # * +result+ - OmniCat::Result object
      #
      # ==== Examples
      #
      #   # Classify a document
      #   bayes.classify("good documentation")
      #   =>
      def classify(doc_content)
        return unless classifiable?
        score = -1000000
        result = ::OmniCat::Result.new
        @categories.each do |category_name, category|
          result.scores[category_name] = doc_probability(category, doc_content)
          if result.scores[category_name] > score
            result.category[:name] = category_name
            score = result.scores[category_name]
          end
          result.total_score += result.scores[category_name]
        end
        result.total_score = 1 if result.total_score == 0
        result.category[:percentage] = (
          result.scores[result.category[:name]] * 100.0 /
          result.total_score
        ).floor
        result
      end

      private
        # nodoc
        def update_priors
          @categories.each do |_, category|
            category.prior = category.doc_count / doc_count.to_f
          end
        end

        # nodoc
        def increment_token_counts(category_name, token, count)
          increment_uniq_token_count(token)
          @token_count += count
          @categories[category_name].token_count += count
        end

        # nodoc
        def increment_uniq_token_count(token)
          uniq_token_addition = 1
          categories.each do |_, category|
             if category.tokens.has_key?(token)
               uniq_token_addition = 0
               break
             end
          end
          @uniq_token_count += uniq_token_addition
        end

        # nodoc
        def doc_probability(category, doc_content)
          score = k_value
          doc = OmniCat::Doc.new(content: doc_content)
          doc.tokens.each do |token, count|
            score *= token_probability(category, token, count)
          end
          category.prior * score
        end

        # nodoc
        def token_probability(category, token, count)
          if category.tokens[token].to_i == 0
            k_value / token_count
          else
            count * (
              (category.tokens[token].to_i + k_value) /
              (category.token_count + uniq_token_count)
            )
          end
        end
    end
  end
end
