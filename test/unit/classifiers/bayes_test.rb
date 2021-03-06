# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

class TestBayes < Test::Unit::TestCase
  def setup
    OmniCat.configure do |config|
      config.auto_train = :off
      config.exclude_tokens = ['are', 'at', 'by']
      config.token_patterns = {
        minus: [/[\s\t\n\r]+/, /(@[\w\d]+)/],
        plus: [/[\p{L}\-0-9]{2,}/, /[\!\?]/, /[\:\)\(\;\-\|]{2,3}/]
      }
    end
    @bayes = OmniCat::Classifiers::Bayes.new
  end

  def test_add_category
    @bayes.add_category 'neutral'
    assert_not_nil(@bayes.categories['neutral'])
    assert_equal(
      ['neutral'],
      @bayes.categories.keys
    )
    assert_equal(
      0,
      @bayes.categories['neutral'].doc_count
    )
    assert_equal(
      {},
      @bayes.categories['neutral'].tokens
    )
    assert_equal(
      0,
      @bayes.categories['neutral'].token_count
    )
  end

  def test_add_category_that_already_exists
    @bayes.add_category 'neutral'
    assert_raise(StandardError) { @bayes.add_category 'neutral' }
  end

  def test_add_categories
    @bayes.add_categories ['neutral', 'positive', 'negative']
    assert_not_nil(@bayes.categories['neutral'])
    assert_equal(
      ['neutral', 'positive', 'negative'],
      @bayes.categories.keys
    )
  end

  def test_train_valid_category
    @bayes.add_category 'neutral'
    @bayes.train 'neutral', 'how are you?? : :| :) ;-) :('
    assert_equal(
      1,
      @bayes.categories['neutral'].doc_count
    )
    assert_equal(
      {'how' => 1, 'you' => 1, '?' => 2, ':|' => 1, ':)' => 1, ';-)' => 1, ':(' => 1},
      @bayes.categories['neutral'].tokens
    )
    assert_equal(
      8,
      @bayes.categories['neutral'].token_count
    )
  end

  def test_untrain_valid_category
    @bayes.add_category 'neutral'
    @bayes.train 'neutral', 'how are you?? : :| :) ;-) :('
    @bayes.untrain 'neutral', 'how are you?? : :| :) ;-) :('
    assert_equal(
      0,
      @bayes.categories['neutral'].doc_count
    )
    assert_equal(
      0,
      @bayes.categories['neutral'].docs.count
    )
    assert_equal(
      0,
      @bayes.categories['neutral'].token_count
    )
  end

  def test_untrain_with_doc_count_2
    @bayes.add_category 'neutral'
    @bayes.train 'neutral', 'how are you?? : :| :) ;-) :('
    @bayes.train 'neutral', 'how are you?? : :| :) ;-) :('
    @bayes.untrain 'neutral', 'how are you?? : :| :) ;-) :('
    assert_equal(
      1,
      @bayes.categories['neutral'].doc_count
    )
    assert_equal(
      {'how' => 1, 'you' => 1, '?' => 2, ':|' => 1, ':)' => 1, ';-)' => 1, ':(' => 1},
      @bayes.categories['neutral'].tokens
    )
    assert_equal(
      8,
      @bayes.categories['neutral'].token_count
    )
  end

  def test_untrain_invalid_category
    assert_equal(false, @bayes.categories.has_key?('neutral'))
    assert_raise(StandardError) {
      @bayes.untrain 'neutral', 'how are you?? : :| :) ;-) :('
    }
  end

  def test_untrain_with_missing_doc
    @bayes.add_category 'neutral'
    assert_raise(StandardError) {
      @bayes.untrain 'neutral', 'how are you?? : :| :) ;-) :('
    }
  end

  def test_train_batch
    @bayes.add_category 'positive'
    @bayes.train_batch 'positive', ['good job ever', 'valid syntax',
      'best moments of my life']
    assert_equal(
      3,
      @bayes.categories['positive'].doc_count
    )
  end

  def test_train_missing_category
    assert_raise(StandardError) { @bayes.train 'neutral', 'how are you?' }
  end

  def test_unique_token_count
    @bayes.add_category 'positive'
    @bayes.train_batch 'positive', ['good job ever', 'valid syntax',
      'best moments of my good life']
    assert_equal(10,@bayes.unique_token_count)
    @bayes.untrain_batch 'positive', ['good job ever', 'valid syntax',
      'best moments of my good life']
    assert_equal(0,@bayes.unique_token_count)
  end

  def test_classifiability_error
    @bayes.add_category 'positive'
    @bayes.add_category 'negative'
    assert_raise(StandardError) { @bayes.classify 'good job' }
    @bayes.train('positive', 'good job')
    assert_raise(StandardError) { @bayes.classify 'good job' }
  end

  def test_classify
    @bayes.add_category 'positive'
    @bayes.add_category 'negative'
    @bayes.train('positive', 'good job')
    @bayes.train('negative', 'bad work')
    assert_equal(
      'positive',
      @bayes.classify('very good position for this sentence').top_score.key
    )
    @bayes.train('negative', 'work')
    assert_equal(
      'negative',
      @bayes.classify('bad words').top_score.key
    )
  end

  def test_classify_batch
    @bayes.add_category 'positive'
    @bayes.add_category 'negative'
    @bayes.train_batch 'positive', ['good job ever', 'valid syntax',
      'best moments of my life']
    @bayes.train_batch('negative', ['bad work', 'awfull day', 'never liked it'])
    results = @bayes.classify_batch(
      ['good sytanx research', 'bad words']
    )

    assert_equal(2, results.count)

    assert_equal(
      'positive',
      results[0].top_score.key
    )
    assert_equal(
      'negative',
      results[1].top_score.key
    )
  end

  def test_initialize_with_hash
    bayes1 = ::OmniCat::Classifiers::Bayes.new
    bayes1.add_category 'positive'
    bayes1.add_category 'negative'
    bayes1.train('positive', 'good job')
    bayes1.train('negative', 'bad work')
    h1 = bayes1.to_hash
    bayes2 = ::OmniCat::Classifiers::Bayes.new(h1)
    assert_equal(h1, bayes2.to_hash)
  end

  def test_change_strategy
    c1 = ::OmniCat::Classifier.new(::OmniCat::Classifiers::Bayes.new)
    c1.add_category 'positive'
    c1.add_category 'negative'
    c1.train('positive', 'good job')
    c1.train('negative', 'bad work')
    h1 = c1.to_hash
    c1.strategy = ::OmniCat::Classifiers::Bayes.new
    assert_equal(h1, c1.to_hash)
  end

  def test_classify_with_insufficient_categories
    assert_raise(StandardError) { @bayes.classify 'blank' }
  end
end
