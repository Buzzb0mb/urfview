require 'open-uri'
require 'json'

OUT_PATH = 'phot0.jpg'
PHOTOS_JSON_PATH = 'photos.json'

def cie76_difference(color1, color2)
  Math.sqrt(
    (color1[0] - color2[0]) ** 2 +
    (color1[1] - color2[1]) ** 2 +
    (color1[2] - color2[2]) ** 2
  ) / Math.sqrt(255 ** 2 * 3)
end

def open_photo(slug, preview=false)
  num = slug.split('-').last
  open("https://www.gstatic.com/prettyearth/assets/#{preview ? 'preview' : 'full'}/#{num}.jpg")
end

def get_photos
  if not File.exists? PHOTOS_JSON_PATH
    $stderr.puts "Grabbing photos.json"
    json = open('https://earthview.withgoogle.com/_api/photos.json').read
    File.write(PHOTOS_JSON_PATH, json)
  else
    json = open(PHOTOS_JSON_PATH).read
  end
  return JSON.parse json
end

if not ARGV.empty?
  desired_color = ARGV.join(' ').scan(/([0-9]+)/).flatten.map(&:to_i)
  if desired_color.size != 3 or desired_color.any?{|c| c > 255 or c < 0}
    $stderr.puts "Invalid color"
    exit
  end
else
  desired_color = 3.times.map{rand(255)}
  $stderr.puts "Using desired color #{desired_color.join(', ')}"
end

# grab photos.json from earthview
photos = get_photos

# calculate the difference between the primary colors of each photo and our desired color
photos.map! do |p|
  # just compare rgb values; would be better to convert to LAB*
  p['diff'] = cie76_difference(desired_color, p['primaryColor'][0..2])
  p
end

# find the photo with the smallest difference
photo = photos.reduce {|acc, e| e['diff'] < acc['diff'] ? e : acc}

# write it
$stderr.puts "Found photo in #{photo['slug'].split('-')[0..-2].join(' ')}"
open(OUT_PATH, 'w') do |o|
  IO.copy_stream(open_photo(photo['slug']), o)
end
