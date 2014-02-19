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
      # you can enable auto train mode by :unique or :continues
      # unique: only uniq docs will be added to training docs on prediction
      # continues: always add docs to training docs on prediction
      config.auto_train = :off
      config.exclude_tokens = ['something', 'anything'] # exclude token list
      config.token_patterns = {
        # exclude tokens with Regex patterns
        minus: [/[\s\t\n\r]+/, /(@[\w\d]+)/],
        # include tokens with Regex patterns
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
    
### Untrain
Untrain category with a document.

    bayes.untrain('positive', 'great if you are in a slap happy mood .')
    bayes.untrain('negative', 'bad tracking issue')

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
    
### Untrain batch
Untrain category with multiple documents.

    bayes.untrain_batch('positive', [
      'a feel-good picture in the best sense of the term...',
      'it is a feel-good movie about which you can actually feel good.',
      'love and money both of them are good choises'
    ])
    bayes.untrain_batch('negative', [
      'simplistic , silly and tedious .',
      'interesting , but not compelling . ',
      'seems clever but not especially compelling'
    ])

### Classify
Classify a document.

    result = bayes.classify('I feel so good and happy')
    => #<OmniCat::Result:0x007febb152af68 @top_score_key="positive", @scores={"positive"=>#<OmniCat::Score:0x007febb152add8 @key="positive", @value=6.813226744186048e-09, @percentage=58>, "negative"=>#<OmniCat::Score:0x007febb152ac70 @key="negative", @value=4.875003449064939e-09, @percentage=42>}, @total_score=1.1688230193250986e-08>
    result.to_hash
    => {:top_score_key=>"positive", :scores=>{"positive"=>{:key=>"positive", :value=>6.813226744186048e-09, :percentage=>58}, "negative"=>{:key=>"negative", :value=>4.875003449064939e-09, :percentage=>42}}, :total_score=>1.1688230193250986e-08}
    result.top_score
    => #<OmniCat::Score:0x007febb152add8 @key="positive", @value=6.813226744186048e-09, @percentage=58>
    result.top_score.to_hash
    => {:key=>"positive", :value=>6.813226744186048e-09, :percentage=>58}
    

### Classify batch
Classify multiple documents at a time.

    results = bayes.classify_batch(
      [
        'the movie is silly so not compelling enough',
        'a good piece of work'
      ]
    )
    => [#<OmniCat::Result:0x007febb14f3680 @top_score_key="negative", @scores={"positive"=>#<OmniCat::Score:0x007febb14f34a0 @key="positive", @value=7.971480930520432e-14, @percentage=22>, "negative"=>#<OmniCat::Score:0x007febb14f32c0 @key="negative", @value=2.834304330851709e-13, @percentage=78>}, @total_score=3.6314524239037524e-13>, #<OmniCat::Result:0x007febb14f2aa0 @top_score_key="positive", @scores={"positive"=>#<OmniCat::Score:0x007febb14f2960 @key="positive", @value=3.802731206057328e-07, @percentage=72>, "negative"=>#<OmniCat::Score:0x007febb14f2820 @key="negative", @value=1.4625010347194818e-07, @percentage=28>}, @total_score=5.26523224077681e-07>]

### Convert to hash
Convert full Bayes object to hash.

    # For storing, restoring modal data
    bayes_hash = bayes.to_hash
    => {:categories=>{"positive"=>{:doc_count=>4, :docs=>{"28fd29bbf840c86db65e510ff3cd07a9"=>{:content=>"great if you are in a slap happy mood .", :content_md5=>"28fd29bbf840c86db65e510ff3cd07a9", :count=>1, :tokens=>{"great"=>1, "if"=>1, "you"=>1, "are"=>1, "in"=>1, "slap"=>1, "happy"=>1, "mood"=>1}}, "82b4cd9513f448dea0024f2d0e2ccd44"=>{:content=>"a feel-good picture in the best sense of the term...", :content_md5=>"82b4cd9513f448dea0024f2d0e2ccd44", :count=>1, :tokens=>{"feel-good"=>1, "picture"=>1, "in"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>1, "term"=>1}}, "f917bf1cf1256c78c5436d850dab3104"=>{:content=>"it is a feel-good movie about which you can actually feel good.", :content_md5=>"f917bf1cf1256c78c5436d850dab3104", :count=>1, :tokens=>{"it"=>1, "is"=>1, "feel-good"=>1, "movie"=>1, "about"=>1, "which"=>1, "you"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>1}}, "4343bbe84c035733708c3f58136f321e"=>{:content=>"love and money both of them are good choises", :content_md5=>"4343bbe84c035733708c3f58136f321e", :count=>1, :tokens=>{"love"=>1, "and"=>1, "money"=>1, "both"=>1, "of"=>1, "them"=>1, "are"=>1, "good"=>1, "choises"=>1}}}, :name=>"positive", :tokens=>{"great"=>1, "if"=>1, "you"=>2, "are"=>2, "in"=>2, "slap"=>1, "happy"=>1, "mood"=>1, "feel-good"=>2, "picture"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>2, "term"=>1, "it"=>1, "is"=>1, "movie"=>1, "about"=>1, "which"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>2, "love"=>1, "and"=>1, "money"=>1, "both"=>1, "them"=>1, "choises"=>1}, :token_count=>37, :prior=>0.5}, "negative"=>{:doc_count=>4, :docs=>{"89b36e774579662591ea21b3283d9b35"=>{:content=>"bad tracking issue", :content_md5=>"89b36e774579662591ea21b3283d9b35", :count=>1, :tokens=>{"bad"=>1, "tracking"=>1, "issue"=>1}}, "b0ec48bc87527e285b26d6cce8e278e7"=>{:content=>"simplistic , silly and tedious .", :content_md5=>"b0ec48bc87527e285b26d6cce8e278e7", :count=>1, :tokens=>{"simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1}}, "ae9d4fbaf40906614ca712a888648c5f"=>{:content=>"interesting , but not compelling . ", :content_md5=>"ae9d4fbaf40906614ca712a888648c5f", :count=>1, :tokens=>{"interesting"=>1, "but"=>1, "not"=>1, "compelling"=>1}}, "0e495f5d88d8049746a1b6961bf3cc90"=>{:content=>"seems clever but not especially compelling", :content_md5=>"0e495f5d88d8049746a1b6961bf3cc90", :count=>1, :tokens=>{"seems"=>1, "clever"=>1, "but"=>1, "not"=>1, "especially"=>1, "compelling"=>1}}}, :name=>"negative", :tokens=>{"bad"=>1, "tracking"=>1, "issue"=>1, "simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1, "interesting"=>1, "but"=>2, "not"=>2, "compelling"=>2, "seems"=>1, "clever"=>1, "especially"=>1}, :token_count=>17, :prior=>0.5}}, :category_count=>2, :category_size_limit=>0, :doc_count=>8, :token_count=>54, :unique_token_count=>43, :k_value=>1.0}

### Load from hash
Load full Bayes object from hash.

    another_bayes_obj = OmniCat::Classifiers::Bayes.new(bayes_hash)
    => #<OmniCat::Classifiers::Bayes:0x007febb14d15a8 @categories={"positive"=>#<OmniCat::Classifiers::BayesInternals::Category:0x007febb14d1530 @doc_count=4, @docs={"28fd29bbf840c86db65e510ff3cd07a9"=>{:content=>"great if you are in a slap happy mood .", :content_md5=>"28fd29bbf840c86db65e510ff3cd07a9", :count=>1, :tokens=>{"great"=>1, "if"=>1, "you"=>1, "are"=>1, "in"=>1, "slap"=>1, "happy"=>1, "mood"=>1}}, "82b4cd9513f448dea0024f2d0e2ccd44"=>{:content=>"a feel-good picture in the best sense of the term...", :content_md5=>"82b4cd9513f448dea0024f2d0e2ccd44", :count=>1, :tokens=>{"feel-good"=>1, "picture"=>1, "in"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>1, "term"=>1}}, "f917bf1cf1256c78c5436d850dab3104"=>{:content=>"it is a feel-good movie about which you can actually feel good.", :content_md5=>"f917bf1cf1256c78c5436d850dab3104", :count=>1, :tokens=>{"it"=>1, "is"=>1, "feel-good"=>1, "movie"=>1, "about"=>1, "which"=>1, "you"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>1}}, "4343bbe84c035733708c3f58136f321e"=>{:content=>"love and money both of them are good choises", :content_md5=>"4343bbe84c035733708c3f58136f321e", :count=>1, :tokens=>{"love"=>1, "and"=>1, "money"=>1, "both"=>1, "of"=>1, "them"=>1, "are"=>1, "good"=>1, "choises"=>1}}}, @name="positive", @tokens={"great"=>1, "if"=>1, "you"=>2, "are"=>2, "in"=>2, "slap"=>1, "happy"=>1, "mood"=>1, "feel-good"=>2, "picture"=>1, "the"=>2, "best"=>1, "sense"=>1, "of"=>2, "term"=>1, "it"=>1, "is"=>1, "movie"=>1, "about"=>1, "which"=>1, "can"=>1, "actually"=>1, "feel"=>1, "good"=>2, "love"=>1, "and"=>1, "money"=>1, "both"=>1, "them"=>1, "choises"=>1}, @token_count=37, @prior=0.5>, "negative"=>#<OmniCat::Classifiers::BayesInternals::Category:0x007febb14d14e0 @doc_count=4, @docs={"89b36e774579662591ea21b3283d9b35"=>{:content=>"bad tracking issue", :content_md5=>"89b36e774579662591ea21b3283d9b35", :count=>1, :tokens=>{"bad"=>1, "tracking"=>1, "issue"=>1}}, "b0ec48bc87527e285b26d6cce8e278e7"=>{:content=>"simplistic , silly and tedious .", :content_md5=>"b0ec48bc87527e285b26d6cce8e278e7", :count=>1, :tokens=>{"simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1}}, "ae9d4fbaf40906614ca712a888648c5f"=>{:content=>"interesting , but not compelling . ", :content_md5=>"ae9d4fbaf40906614ca712a888648c5f", :count=>1, :tokens=>{"interesting"=>1, "but"=>1, "not"=>1, "compelling"=>1}}, "0e495f5d88d8049746a1b6961bf3cc90"=>{:content=>"seems clever but not especially compelling", :content_md5=>"0e495f5d88d8049746a1b6961bf3cc90", :count=>1, :tokens=>{"seems"=>1, "clever"=>1, "but"=>1, "not"=>1, "especially"=>1, "compelling"=>1}}}, @name="negative", @tokens={"bad"=>1, "tracking"=>1, "issue"=>1, "simplistic"=>1, "silly"=>1, "and"=>1, "tedious"=>1, "interesting"=>1, "but"=>2, "not"=>2, "compelling"=>2, "seems"=>1, "clever"=>1, "especially"=>1}, @token_count=17, @prior=0.5>}, @category_count=2, @category_size_limit=0, @doc_count=8, @token_count=54, @unique_token_count=43, @k_value=1.0>
    another_bayes_obj.classify('best senses')
    => #<OmniCat::Result:0x007febb14c0fc8 @top_score_key="positive", @scores={"positive"=>#<OmniCat::Score:0x007febb14c0ed8 @key="positive", @value=0.00029069767441860465, @percentage=52>, "negative"=>#<OmniCat::Score:0x007febb14c0de8 @key="negative", @value=0.0002704164413196322, @percentage=48>}, @total_score=0.0005611141157382368>

### Best practices
For bayes classification always try to train same amount of documents for each category. So, do not activate auto training mode, because it make overages on balance of trained docs and makes algorithm go crazy :).
To get best results on text classification you should apply some cleaning actions like spellchecking, stemming, stop words cleaning before training and prediction actions.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright
Copyright © 2013 Mustafa Turan. See LICENSE for details.

