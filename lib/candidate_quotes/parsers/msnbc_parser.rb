require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'

module CandidateQuotes
  class MSNBCParser
    def initialize(url)
      @url = url
      @page = Nokogiri::HTML(open(url))
    end

    def transcript
      build_show_hash
    end

    def unparsed_transcript
      @page.css('div#intelliTXT').text.strip
    end

    private

    def build_show_hash
      parsed_show = {}
      parsed_show[:show_name] = show_name
      parsed_show[:show_title] = show_title
      parsed_show[:air_date] = show_date
      parsed_show[:candidates_mentioned] = %w(sanders clinton trump)
      parsed_show[:candidates_quoted] = ['sanders']
      parsed_show[:original_source] = @url
      parsed_show[:quotes] = {}

      parsed_show[:quotes] = quotes.map do |x|
        quote = {}
        quote[:speaker] = x[0].gsub(':', '').gsub('.', '').gsub('--', '').strip
        quote[:text] = x[1].strip
        fail 'bad speaker' if quote[:speaker].length > 100
        quote
      end
      parsed_show[:quotes] = parsed_show[:quotes][0...-1] if parsed_show[:quotes].last[:speaker].empty?

      parsed_show
    end

    def quotes
      tokens = @page.css('div#intelliTXT').text.split(/([A-Z ,\(\)\-\/\&\']+:)/).drop(1)
      tokens.each_slice(2).to_a
    end

    def show_date
      @page.css('div#intelliTXT').text.strip.scan(/Date:(.+)/).flatten[0]
    end

    def show_name
      @page.css('div#intelliTXT').text.strip.scan(/Show:(.+)/).flatten[0]
    end

    def show_title
      show_date
    end

    def show_text
      "Guest: #{@page.css('div#intelliTXT').text.split('Guest:')[1]}"
    end
  end
end
