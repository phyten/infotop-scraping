# -*- coding: utf-8 -*-
require "infotop/scraping/version"

require 'rubygems'
require 'mechanize'
require 'scraper'
require 'pp'

module Infotop
  module Scraping
    TOP_URL = "http://www.infotop.jp/buyer/item/"
    class Core
      def initialize
        @scraper = Scraper::Core.new
      end
      def ranking(genre = nil)
        result = []
        rank = 1                # each_with_indexが効かないので、カウンタを設置
        @scraper.url = TOP_URL
        if genre.nil?
          @scraper.reload
        else
          @scraper.reload(true, {"info[category_id_i]" => genre})
        end
        @scraper.content.search('table.noborder tr').each do |tr|
          if tr.search('th p a img').first.respond_to?(:inner_text)
            img_url = tr.search('th p a img').first[:src]
            unique_number = tr.search('th p a img').first[:src].to_s.gsub(/[^0-9]/, "").to_i
          end
          if tr.search('td').search('a').first.respond_to?(:inner_text)
            title = tr.search('td').search('a').first.inner_text
            url = tr.search('td').search('a').first[:href]
            if tr.search('td').search('table tr td')[1].respond_to?(:inner_text)
              price = tr.search('td').search('table tr td')[1].inner_text.to_s.gsub(/[^0-9]/, "").to_i
            end
          end
          if unique_number.nil?
            next
          end
          result.push({
                        rank: rank,
                        unique_number: unique_number,
                        title: title,
                        url: url,
                        price: price,
                        img_url: img_url,
                      })
          rank = rank.succ
        end
        result
      end
    end
  end
end

module Scraper
  class Core
    def reload(post_flag = false, post_query = {})
      if post_flag == true
        page = @mechanize.post(@url, post_query)
        @content = page.content.to_s.toutf8
        @document = Hpricot @content
        return @document
      else
        page = @mechanize.get(@url)
        @content = page.content.to_s.toutf8
        @document = Hpricot @content
        return @document
      end
    end
  end
end
