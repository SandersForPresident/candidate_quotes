# usage bundle exec rake crawl_cnn http://transcripts.cnn.com/TRANSCRIPTS/2015.08.26.html
# usage bundle exec rake crawl_msnbc http://www.nbcnews.com/id/32390017/ns/msnbc-hardball_with_chris_matthews/

namespace :candidate_quotes do
  desc 'Grab an entire abc program and parse it'
  task :crawl_abc, [:url] do |_t, args|
    CandidateQuotes.crawl_abc(args[:url])
  end

  desc 'Grab an entire cnn program and parse it'
  task :crawl_cnn, [:url] do |_t, args|
    CandidateQuotes.crawl_cnn(args[:url])
  end

  desc 'Grab an entire msnbc program and parse it'
  task :crawl_msnbc, [:url] do |_t, args|
    CandidateQuotes.crawl_msnbc(args[:url])
  end
end