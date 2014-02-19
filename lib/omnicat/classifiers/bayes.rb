require 'digest'
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
          @categories[category_name] = ::OmniCat::Classifiers::BayesInternals::Category.new(name: category_name)
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
        category_must_exist(category_name)
        doc = add_doc(category_name, doc_content)
        doc.tokens.each do |token, count|
          increment_token_counts(category_name, token, count)
          @categories[category_name].tokens[token] = @categories[category_name].tokens[token].to_i + count
        end
        increment_doc_counts(category_name)
        update_priors
      end

      # Untrain the desired category with a document
      #
      # ==== Parameters
      #
      # * +category_name+ - Name of the category from added categories list
      # * +doc_content+ - Document text
      #
      # ==== Examples
      #
      #   # Untrain the desired category
      #   bayes.untrain("positive", "clear documentation")
      #   bayes.untrain("positive", "good, very well")
      #   bayes.untrain("negative", "bad dog")
      #   bayes.untrain("neutral", "how is the management gui")
      def untrain(category_name, doc_content)
        category_must_exist(category_name)
        doc = remove_doc(category_name, doc_content)
        doc.tokens.each do |token, count|
          @categories[category_name].tokens[token] = @categories[category_name].tokens[token].to_i - count
          @categories[category_name].tokens.delete(token) if @categories[category_name].tokens[token] == 0
          decrement_token_counts(category_name, token, count)
        end
        decrement_doc_counts(category_name)
        update_priors
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
        doc = ::OmniCat::Doc.new(content: doc_content)
        result = ::OmniCat::Result.new
        @categories.each do |category_name, category|
          result.add_score(
            Score.new(
              key: category.name,
              value: doc_probability(category, doc)
            )
          )
        end
        auto_train(@categories[result.top_score.key], doc)
        result.calculate_percentages
        result
      end

      private
        # nodoc
        def auto_train(category, doc)
          case ::OmniCat.config.auto_train
          when :continues
            train(category.name, doc.content)
          when :unique
            train(category.name, doc.content) unless category.docs.has_key?(doc.content_md5)
          end
        end

        # nodoc
        def update_priors
          @categories.each do |_, category|
            category.prior = category.doc_count / doc_count.to_f
          end
        end

        # nodoc
        def increment_token_counts(category_name, token, count)
          modify_token_counts(category_name, token, count)
        end

        # nodoc
        def decrement_token_counts(category_name, token, count)
          modify_token_counts(category_name, token, -1 * count)
        end

        # nodoc
        def modify_token_counts(category_name, token, count)
          modify_unique_token_count(token, count < 0 ? -1 : 1)
          @token_count += count
          @categories[category_name].token_count += count
        end

        # nodoc
        def increment_unique_token_count(token)
          modify_unique_token_count(token, 1)
        end

        # nodoc
        def decrement_unique_token_count(token)
          modify_unique_token_count(token, -1)
        end

        # nodoc
        def modify_unique_token_count(token, uniq_token_addition)
          @categories.each do |_, category|
             if category.tokens.has_key?(token)
               uniq_token_addition = 0
               break
             end
          end
          @unique_token_count += uniq_token_addition
        end

        # nodoc
        def doc_probability(category, doc)
          score = @k_value
          doc.tokens.each do |token, count|
            score *= token_probability(category, token, count)
          end
          category.prior * score
        end

        # nodoc
        def token_probability(category, token, count)
          if category.tokens[token].to_i == 0
            @k_value / (@unique_token_count * count)
          else
            count * (
              (category.tokens[token].to_i + @k_value) /
              (category.token_count + @unique_token_count)
            )
          end
        end

        # nodoc
        def add_doc(category_name, doc_content)
          doc_key = generate_doc_key(doc_content)
          if doc = @categories[category_name].docs[doc_key]
            doc.increment_count
          else
            @categories[category_name].docs[doc_key] = ::OmniCat::Doc.new(content: doc_content)
          end
          @categories[category_name].docs[doc_key]
        end

        # nodoc
        def remove_doc(category_name, doc_content)
          doc_key = generate_doc_key(doc_content)
          doc = @categories[category_name].docs[doc_key]
          unless doc
            raise StandardError, 
                  "Document is not found in #{category_name} documents!"
          end
          doc.decrement_count
          @categories[category_name].docs.delete(doc_key) if doc.count == 0
          doc
        end

        # nodoc
        def generate_doc_key(doc_content)
          Digest::MD5.hexdigest(doc_content)
        end

        # nodoc
        def category_must_exist(category_name)
          unless category_exists?(category_name)
            raise StandardError,
                  "Category with name '#{category_name}' does not exist!"
          end
        end
    end
  end
end
