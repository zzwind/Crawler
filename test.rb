require 'open-uri'
require 'nokogiri'
require 'json'

base_dir='/home/vagrant/project/Crawler/catalog'

offerlist = []
todolist = []
todooffer = []

def download(url)
  open(url){ |f| f.read }
end
#get offerlist
data = download('http://.1688.com/page/offerlist.htm')
doc = Nokogiri::HTML(data)
doc.css('div.wp-category-nav-unit ul li a').each do |link|
  offerlist << [link[:title], link[:href]]
  Dir.mkdir(base_dir + '/' + link[:title])
end

offerlist.each do |off|
  data = download(off[1])
  doc = Nokogiri::HTML(data)
  if doc.css('em.page-count')[0]
    (1...doc.css('em.page-count')[0].text.to_i).each { |n| todolist << [off[0], "#{off[1]}?pageNum=#{n}"] }
  else
    todolist << [off[0], off[1]]
  end
end

todolist.each do |p|
  data = download(p[1])
  doc = Nokogiri::HTML(data)
  doc.css('div.title a').each do |a|
    todooffer << [p[0], a[:title], a[:href]]
  end
end

threads = []
todooffer.each do |p|
  if Thread.list.count % 5 != 0
    threads << Thread.new do 
      data = download(p[2])
      doc = Nokogiri::HTML(data)
      pic = (JSON.parse doc.css('li.active')[0].attribute('data-imgs'))['original']

      data = download(pic)
      p[1].gsub!('/',' ')
      open(base_dir + '/' + p[0] + '/' + p[1] + '.jpg','wb'){ |f| f.write(data) }
    end
    puts Thread.list.count
  else
    threads.each { |t| t.join }
  end
end
threads.each { |t| t.join }


