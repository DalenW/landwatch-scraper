# frozen_string_literal: true

require 'kimurai'

# scrapes the webpage
class LandSpider < Kimurai::Base
  @name = 'land_spider'
  @engine = :selenium_firefox

  def self.process(url)
    @start_urls = [url]
    LandSpider.crawl!
  end

  def parse(response, url:, data: {})
    puts 'here'

    response.xpath('//div[@data-qa-listing]').each do |land|
      # puts land
      new_land = Land.new

      new_land.site = 'landwatch.com'
      new_land.site_path

      new_land.site_path = land.css('div a').map.first['href']
      puts new_land.site_path

      new_land.landwatch_id = new_land.site_path.split('/').last
      puts new_land.landwatch_id

      new_land.price = land.at('div a div:contains("$")').text.scan(/\d/).join('').to_i
      puts new_land.price

      acres_and_county = land.at('div a div span:contains("acres")').text.split('-')
      new_land.acreage = acres_and_county[0].split('acres')[0].to_f
      puts new_land.acreage

      # new_land.save
    end
  end
end
