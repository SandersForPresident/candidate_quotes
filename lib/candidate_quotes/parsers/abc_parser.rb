require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'

module CandidateQuotes
  class ABCParser
    def initialize(url)
      @url = url
      @page = Nokogiri::HTML(open(url))
    end

    def transcript
      build_show_hash
    end

    def unparsed_transcript
      show_text
    end

    private

    def build_show_hash
      parsed_show = {}
      parsed_show[:quotes] = {}
      parsed_show[:show_name] = show_name
      parsed_show[:show_title] = show_title
      parsed_show[:air_date] = show_date
      parsed_show[:candidates_mentioned] = %w(sanders clinton trump)
      parsed_show[:candidates_quoted] = ['sanders']
      parsed_show[:original_source] = @url

      parsed_show[:quotes] = quotes.map do |x|
        # puts "speaker: #{x[0]}"#" text:#{x[1]}"
        quote = {}
        quote[:speaker] = x[0].gsub(':', '').strip
        quote[:text] = x[1].gsub("\n", '').gsub(' .', '.').strip
        # fail 'bad speaker' if quote[:speaker].length > 100
        quote
      end
      parsed_show
    end

    def quotes
      tokens = show_text.split(/([A-Z ,\(\)\-\/\&\']+:)/).drop(1)
      tokens.reject! { |c| c.nil? || c.empty? }
      tokens.each_slice(2).to_a
    end

    def show_text
      raw = @page.css('div[itemscope] p').text.strip

      # remove annotations after a speakers name like STEWART (voice-over):
      raw = raw.gsub(/\([a-z\-]+\)/, '')

      replace_with_blankspace.each do |x|
        raw = raw.gsub(x, '')
      end

      # remove timecodes
      raw = raw.gsub(/\[\d+:\d+:\d+\]/, '')

      replace_with_newlines.each do |x|
        raw = raw.gsub(x, "\n")
      end

      raw
    end

    def show_date
      @page.css('div.date').text
    end

    def show_name
      headline[0].split("'")[1]
    end

    def show_title
      headline[1].strip
    end

    def headline
      @page.css('h1.headline').text.split(':')
    end

    def replace_with_blankspace
      ['(BEGIN VIDEO CLIP)', '(END VIDEO CLIP)', '(via telephone)', '(CROSSTALK)', '(COMMERCIAL BREAK)', '(BEGIN VIDEOTAPE)', '(END VIDEOTAPE)', '(LAUGHTER)', "\t"]
    end

    def replace_with_newlines
      ['--', '----', '(OFF-MIKE)', '(INAUDIBLE QUESTION)', '(INAUDIBLE)', '(AUDIENCE APPLAUDING)', '(AUDIENCE CHEERING AND APPLAUDING)', '(LAUGHING)']
    end
  end
end
