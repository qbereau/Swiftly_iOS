require 'rubygems'
require 'nokogiri'

f1 = File.open("country_codes.xml")
doc = Nokogiri::XML(f1).xpath("//icc")

out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
out << "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
out << "<plist version=\"1.0\">\n"
out << "<dict>\n"
out << "\t<key>countries</key>\n"
out << "\t<array>\n"

arr = []

f2 = File.new("country_name.txt", "r")
	while (line = f2.gets)
		country_code = line.split(',"')[0].strip
		country_name = line.split(',"')[1].strip.chop

		p "#{country_code} - #{country_name}"

    	cursor = p doc.at_css("#{country_code}")
    	if (cursor)
    		phone_prefix = cursor.content
            arr << {
                :phone_prefix => phone_prefix,
                :country_code => country_code,
                :country_name => country_name
            }
    	end

	end

f2.close
f1.close

arr.sort! { |x, y|
    x[:country_name] <=> y[:country_name]
}

arr.each { |x|
    out << "\t\t<dict>\n"
    out << "\t\t\t<key>country_code</key>\n"
    out << "\t\t\t<string>#{x[:country_code]}</string>\n"
    out << "\t\t\t<key>country_name</key>\n"
    out << "\t\t\t<string>#{x[:country_name]}</string>\n"
    out << "\t\t\t<key>phone_prefix</key>\n"
    out << "\t\t\t<integer>#{x[:phone_prefix]}</integer>\n"
    out << "\t\t</dict>\n"
}

out << "\t</array>\n"
out << "</dict>\n"
out << "</plist>"

File.open('./Countries.plist', 'w') do |f|
	f.puts out
end