class Click2delete < Controller
	map '/click2delete'
	def index
		@title = "Rajax: click2delete examples"
		output = "<a href='/'>&lt;&lt; Back to main page</a>"
	
		#EXAMPLE 1
		output << "<h3>Example 1</h3>"
		output << "<p>This example uses a table to display data which includes a button for deleting items at the end.</p>"
		output << "<p>Click2delete items work with tables, but can look visually different depending on your browser. The effect will always look different to using a block element like &lt;div&gt; as the same effect as in <strong>example 2</strong> below does not work. In this example you must click the delete button twice before your request will be processed.</p>"
		output << "<p>In firefox and webkit browsers (safari, chrome) this will fade out the row, then snap the items below it upwards to fill the gap. In Opera there is no fade, it just snaps out.</p>"
		output << "<div style='margin-left:25px;'><h4>Example</h4>"
		output << "<table border='1' cellpadding='2'>"
		output << "<tr><th>Row number</th><th>Additional information</th></tr>"
		rows = (1..10)
		rows.each do |i|
			rwb = "<td>Row " + i.to_s + "!</td><td>Some more text to pad it out a bit</td><td>" + click2delete_button({}, '/click2delete/ajax', 1) + "</td>"
			output << click2delete_wrapper(rwb, :tr)
		end
		output << "</table>"
		output << "<h4>Code to produce</h4>"
		output << %{<pre>
	rows.each do |i|
		rwb = "&lt;td&gt;Row " + i.to_s + "!&lt;/td&gt;&lt;td&gt;Some more text to pad it out a bit&lt;/td&gt;&lt;td&gt;" + click2delete_button({}, '/click2delete/ajax', 1) + "&lt;/td&gt;"
                output &lt;&lt; click2delete_wrapper(rwb, :tr)
	end
		</pre>}
		output << "</div><hr />"
	
		#EXAMPLE 2
		output << "<h3>Example 2</h3>"
		output << "<p>This example uses the default &lt;div&gt; element for the wrapper and looks far better in all browsers. The controller will refuse to delete rows 4 and 5. In this example you need only click the delete button once for the deletion to be processed</p>"
		output << "<p>In firefox, webkit and opera the deleted item slides up out of view upon confirmation from the ajax controller</p>"
		output << "<div style='margin-left:25px;'><h4>Example</h4>"
		rows.each do |i|
			rwb = "<div>This is row number " + i.to_s + "! " + click2delete_button({:row => i}, '/click2delete/ajax/') + "</div>"
			output << click2delete_wrapper(rwb)
		end
		output << "<h4>Code to produce</h4>"
		output << %{<pre>
	rows.each do |i|
		rwb = "&lt;div&gt;This is row number " + i.to_s + "! " + click2delete_button({:row =&gt; i}, '/click2delete/ajax/') + "&lt;/div&gt;"
		output &lt;&lt; click2delete_wrapper(rwb)
	end
		</pre>}
		output
	end

	def ajax
		data = parseajaxdata
		respond ajaxreturn(:error, {:message => "No post data"}) if data.nil?
		case data[:type]
		when :click2delete
			if (4..5) === data[:row].to_i
				respond ajaxreturn(:silent, :message => "You do not have permission to delete these items, you scoundrel.")
			else
				respond ajaxreturn(:success)
			end
		end
		respond ajaxreturn(:error, :message => request.POST.to_json)
	end
end
