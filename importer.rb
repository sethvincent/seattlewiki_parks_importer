$:.push File.expand_path("../lib", __FILE__)
require 'localwiki'
require 'yajl'
require 'pp'

wiki = LocalWiki.new("http://seattlewiki.net", ENV['user'], ENV['apikey'])

def load_json_file(file)
  json = File.new(file, 'r')
  parser = Yajl::Parser.new
  parser.parse(json)
end

json_file = load_json_file("parks.json")
data = json_file["data"]

data.each do |item|

  website = item[11][0]
  address = item[10] || "Address here."
  lat = item[12].to_f
  lon = item[13].to_f

  page = {
    name: item[9],
    content: <<-END
      <table class="details">
      	<tbody>
      		<tr>
      			<td style="background-color: rgb(232, 236, 239);">
      				<strong>Park location:</strong></td>
      		</tr>
      		<tr>
      			<td>
      				#{address}</td>
      		</tr>
      		<tr>
      			<td style="background-color: rgb(232, 236, 239);">
      				<strong>Park offerings/features:</strong></td>
      		</tr>
      		<tr>
      			<td>
      				list park offerings here</td>
      		</tr>
      		<tr>
      			<td style="background-color: rgb(232, 236, 239);">
      				<strong>Hours:</strong></td>
      		</tr>
      		<tr>
      			<td>
      				Park hours here.</td>
      		</tr>
      		<tr>
      			<td style="background-color: rgb(232, 236, 239);">
      				<strong>Website:</strong></td>
      		</tr>
      		<tr>
      			<td>
      				<a href="#{website}">#{website}</td>
      		</tr>
      	</tbody>
      </table>
      <h3>
      	Related:</h3>
      <ul>
      	<li>
      		<a href="Parks">Parks</a></li>
      </ul>
    END
  }

  pp wiki.post_resource("page", page)
  wiki.post_page_tags(page[:name], ["parks", "needs photo", "stub"])
  wiki.post_map(page[:name], lat, lon)

end
