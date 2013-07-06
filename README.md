# OmniCat Bayes

[![Build Status](https://travis-ci.org/mustafaturan/omnicat-bayes.png)](https://travis-ci.org/mustafaturan/omnicat-bayes) [![Code Climate](https://codeclimate.com/github/mustafaturan/omnicat-bayes.png)](https://codeclimate.com/github/mustafaturan/omnicat-bayes)

A Naive Bayes text classification implementation as an OmniCat classifier strategy.

## Installation

Add this line to your application's Gemfile:

    gem 'omnicat-bayes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omnicat-bayes

## Usage

See rdoc for detailed usage.

### Configurations

Optional configuration sample:

    OmniCat.configure do |config|
      config.exclude_tokens = ['something', 'anything'] # exclude token list
      config.token_patterns = {
        # exclude token Regex patterns
        minus: [/[\s\t\n\r]+/, /(@[\w\d]+)/],
        # include token Regex patterns
        plus: [/[\p{L}\-0-9]{2,}/, /[\!\?]/, /[\:\)\(\;\-\|]{2,3}/]
      }
    end

### Bayes classifier
Create a classifier object with Bayes strategy.

    # If you need to change strategy on runtime, you should prefer this inialization
    bayes = OmniCat::Classifier.new(OmniCat::Classifiers::Bayes.new)
or 

    # If you only need to use only Bayes classification, then you can use
    bayes = OmniCat::Classifiers::Bayes.new

### Create categories
Create a classification category.

    bayes.add_category('positive')
    bayes.add_category('negative')

### Train
Train category with a document.

    bayes.train('positive', 'great if you are in a slap happy mood .')
    bayes.train('negative', 'bad tracking issue')

### Train batch
Train category with multiple documents.

    bayes.train_batch('positive', [
      'a feel-good picture in the best sense of the term...',
      'it is a feel-good movie about which you can actually feel good.',
      'love and money both of them are good choises'
    ])
    bayes.train_batch('negative', [
      'simplistic , silly and tedious .',
      'interesting , but not compelling . ',
      'seems clever but not especially compelling'
    ])

### Classify
Classify a document.

    result = bayes.classify('I feel so good and happy')
    => #<OmniCat::Result:0x007fd20296aad8 @category={:name=>"positive", :percentage=>73}, @scores={"positive"=>5.4253472222222225e-09, "negative"=>1.9600796074572086e-09}, @total_score=7.385426829679431e-09>
    result.to_hash
    => {:category=>{:name=>"positive", :percentage=>73}, :scores=>{"positive"=>5.4253472222222225e-09, "negative"=>1.9600796074572086e-09}, :total_score=>7.385426829679431e-09}

### Classify batch
Classify multiple documents at a time.

    results = bayes.classify_batch(
      [
        'the movie is silly so not compelling enough',
        'a good piece of work'
      ]
    )
    => [#<OmniCat::Result:0x007fd2029341b8 @category={:name=>"negative", :percentage=>78}, @scores={"positive"=>2.5521869888765736e-14, "negative"=>9.074442627116706e-14}, @total_score=1.162662961599328e-13>, #<OmniCat::Result:0x007fd20292e7e0 @category={:name=>"positive", :percentage=>80}, @scores={"positive"=>2.411265432098765e-07, "negative"=>5.880238822371627e-08}, @total_score=2.999289314335928e-07>]

### Convert to hash
Convert full Bayes object to hash.

    # For storing, restoring modal data
    bayes_hash = bayes.to_hash
    => {:categories=>{"positive"=>{:doc_count=>4, :tokens=>{"great"=>1, "if"=>1, "you"=>2, "are"=>2, "in"=>2, "slap"=>1, "happy"=>1, "mood"=>1, "feel-good"=>2, "picture"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>2, "term"=>1, "it"=>1, "is"=>1, "movie"=>1, "about"=>1, "which"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>2, "love"=>1, "and"=>1, "money"=>1, "both"=>1, "them"=>1, "choises"=>1}, :token_count=>37}, "negative"=>{:doc_count=>4, :tokens=>{"bad"=>1, "tracking"=>1, "issue"=>1, "simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1, "interesting"=>1, "but"=>2, "not"=>2, "compelling"=>2, "seems"=>1, "clever"=>1, "especially"=>1}, :token_count=>17}}, :category_count=>2, :doc_count=>8, :k_value=>1.0, :token_count=>54, :uniq_token_count=>43}

### Load from hash
Load full Bayes object from hash.

    another_bayes_obj = OmniCat::Classifiers::Bayes.new(bayes_hash)
    => #<OmniCat::Classifiers::Bayes:0x007fd20308cff0 @categories={"positive"=>#<OmniCat::Classifiers::BayesInternals::Category:0x007fd20308cf78 @doc_count=4, @tokens={"great"=>1, "if"=>1, "you"=>2, "are"=>2, "in"=>2, "slap"=>1, "happy"=>1, "mood"=>1, "feel-good"=>2, "picture"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>2, "term"=>1, "it"=>1, "is"=>1, "movie"=>1, "about"=>1, "which"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>2, "love"=>1, "and"=>1, "money"=>1, "both"=>1, "them"=>1, "choises"=>1}, @token_count=37>, "negative"=>#<OmniCat::Classifiers::BayesInternals::Category:0x007fd20308cf00 @doc_count=4, @tokens={"bad"=>1, "tracking"=>1, "issue"=>1, "simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1, "interesting"=>1, "but"=>2, "not"=>2, "compelling"=>2, "seems"=>1, "clever"=>1, "especially"=>1}, @token_count=17>}, @category_count=2, @doc_count=8, @k_value=1.0, @token_count=54, @uniq_token_count=43>
    another_bayes_obj.classify('best senses')
    => #<OmniCat::Result:0x007fd203075008 @category={:name=>"positive", :percentage=>57}, @scores={"positive"=>0.0002314814814814815, "negative"=>0.00017146776406035664}, @total_score=0.00040294924554183816>

## Todo
* Implement all OmniCat(http://github.com/mustafaturan/omnicat) classifier strategy abstract methods

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright
Copyright © 2013 Mustafa Turan. See LICENSE for details.

