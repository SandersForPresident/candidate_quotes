require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'

module CandidateQuotes
  class CNNParser
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
      parsed_show[:show_name] = show_name
      parsed_show[:show_title] = show_title
      parsed_show[:air_date] = show_date
      parsed_show[:candidates_mentioned] = %w(sanders clinton trump)
      parsed_show[:candidates_quoted] = ['sanders']
      parsed_show[:original_source] = @url
      parsed_show[:quotes] = {}

      begin
        parsed_show[:quotes] = quotes1.map do |x|
          # puts "speaker: #{x[0]}"#" text:#{x[1]}"
          quote = {}
          quote[:speaker] = x[0].gsub(':', '').gsub('.', '').gsub('--', '').strip
          quote[:text] = x[1].strip
          fail 'bad speaker' if quote[:speaker].length > 100
          quote
        end
      rescue
        # binding.pry
        parsed_show[:quotes] = quotes2.map do |x|
          # puts "speaker: #{x[0]}"#" text:#{x[1]}"
          quote = {}
          quote[:speaker] = x[0].gsub(':', '').gsub('.', '').gsub('--', '').strip
          quote[:text] = x[1].strip
          raise 'bad speaker' if quote[:speaker].length > 100
          quote
        end
      end

      parsed_show
    end

    def quotes1
      # works 80% of the time
      tokens = show_text.split /([A-Z ,\(\)\-\/\&\']+:)/
      tokens.reject! { |c| c.nil? || c.empty? }
      tokens.each_slice(2).to_a
    end

    def quotes2
      tokens = show_text.split /([A-Z ,\(\)\-\/\&\'\.]+:)/
      tokens.reject! { |c| c.nil? || c.empty? }
      tokens.each_slice(2).to_a
    end

    def show_date
      tokens = @page.css('p.cnnBodyText')
      date = tokens[0].text.scan(/Aired (.+)-/).flatten
      date[0].strip
    end

    def show_name
      @page.css('p.cnnTransStoryHead').text
    end

    def show_title
      @page.css('p.cnnTransSubHead').text
    end

    def show_text
      raw = @page.css('p.cnnBodyText:last-child').text

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

    def replace_with_blankspace
      ['(BEGIN VIDEO CLIP)', '(END VIDEO CLIP)', '(via telephone)', '(CROSSTALK)', '(COMMERCIAL BREAK)', '(BEGIN VIDEOTAPE)', '(END VIDEOTAPE)', '(LAUGHTER)', "\t"]
    end

    def replace_with_newlines
      ['--', '----', '(OFF-MIKE)', '(INAUDIBLE QUESTION)', '(INAUDIBLE)', '(AUDIENCE APPLAUDING)', '(AUDIENCE CHEERING AND APPLAUDING)', '(LAUGHING)']
    end
  end
end
