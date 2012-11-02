# encoding: UTF-8
require 'nokogiri'

doc = Nokogiri::HTML(File.open('kontouppg.html'))
table = doc.xpath('//div[@class = "sektion-innehall2"]/table')[-1]
table.xpath('tbody/tr').each do |node|
    children = node.xpath('td')
    if !children.empty? && children.children.length > 5
        puts ""
        trans = {
            :date => children[0].text,
            :desc => children[2].text,
            :amount => children[4].text
        }
        puts trans
    end
end
