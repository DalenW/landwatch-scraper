# frozen_string_literal: true

require 'kimurai'

# scrapes the webpage
class LandSpider < Kimurai::Base
  @name = 'land_spider'
  @engine = :selenium_firefox

  PAGE_LIMIT = 50

  def self.process(url)
    @start_urls = [url]
    LandSpider.crawl!
  end

  def parse(response, url:, data: {})
    puts 'here'

    response.xpath('//div[@data-qa-listing]').each do |listing|
      parse_listing listing
    end

    next_url = url
    if next_url.include? '/page-'
      split_url = next_url.split('/page-')
      page = split_url[1].to_i
      next_page = page + 1

      next_url = if next_page > PAGE_LIMIT
                   nil
                 else
                   "#{split_url[0]}/page-#{next_page}"
                 end
    else
      next_url = "#{next_url}page-2" # it already ends with an "/"
    end

    return if next_url.nil?

    # puts url
    puts next_url

    path = next_url.split('.com')[1]
    puts path


    all_links = response.xpath("//a[@href='#{path}']")

    unless all_links.blank?
      request_to :parse, url: next_url
    end

    puts "All Links: #{all_links}"


  end

  def parse_listing(listing)
    new_land = Land.new

    new_land.site = 'landwatch.com'
    new_land.site_path

    new_land.site_path = listing.css('div a').map.first['href']
    puts new_land.site_path

    new_land.landwatch_id = new_land.site_path.split('/').last
    puts new_land.landwatch_id

    price_element = listing.at('div a div:contains("$")')

    return if price_element.nil? # if there's no price, then we skip this listing

    new_land.price = price_element.text.scan(/\d/).join('').to_i
    puts new_land.price

    # looks like this:
    # 5 acres - Greenville, Utah (Beaver County)
    # puts "title: #{listing.at('div a div span:contains("acres")').map.last}"

    listing_title = ''
    listing_title_element = listing.at('div a div span:contains("acres")')
    return if listing_title_element.nil? # if there's no acres, then we skip this listing

    listing.at('div a div span:contains("acres")').map do |title|
      listing_title = title.last
    end

    puts "Listing Title: #{listing_title}"

    acres_and_county = listing.at('div a div span:contains("acres")').text.split('-') # ['5 acres', 'Greenville, Utah (Beaver County)']

    new_land.acreage = acres_and_county[0].split('acres')[0].to_f
    puts new_land.acreage

    city_and_state_and_county = listing_title.split('(') # ['Greenville, Utah', 'Beaver County)']
    city_and_state = city_and_state_and_county[0].split(',') # ['Greenville', 'Utah']

    new_land.city = city_and_state[0].strip
    puts new_land.city

    new_land.state = city_and_state[1].strip
    puts new_land.state

    new_land.county = city_and_state_and_county[1].split(')')[0].strip # 'Beaver County'
    puts new_land.county

    new_land.save
  end

end
