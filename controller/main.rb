class MainController < Controller
  # the index action is called automatically when no other action is specified
  def index
    @title = "Ajax test pad"

	#EXAMPLE 1
	output = "<h3>Example 1</h3><p>click2edit text: Click to activate. Reverse the text in 1 for it to accept, capitalize the second</p>"
	output << "<ol><li>" + click2edit("abcd", :name => 'reverse') + "</li><li>" + click2edit("capitalize me", :name => 'caps') + "</li></ol>"

	#EXAMPLE 2
	output << "<h3>Example 2</h3><p>click2delete (table-row)</p>"
	output << "<table border='1' cellpadding='2'>"
	output << "<tr><th>Row number</th><th>Additional information</th></tr>"
	rows = (1..10)
	rows.each do |i|
		rwb = "<td>Row #{i}!</td><td>Some more text to pad it out a bit</td><td>" + click2delete_button({}) + "</td>\n"
		output << click2delete_wrapper(rwb, :tr)
	end
	output << "</table>"

	#EXAMPLE 3
	output << "<h3>Example 3</h3><p>click2delete (span): produces prettier results than using tables</p>"
	rows.each do |i|
		rwb = "<div>This is row number #{i}! " + click2delete_button({}) + "</div>\n"
		output << click2delete_wrapper(rwb)
	end

	output
  end

  def ajax
	data = parseajaxdata
	respond ajaxreturn(:error, {:message => "No post data"}) if data.nil?
	case data[:type]
	when :click2edit
		newval = data[:new]
		if data[:name] == 'reverse'		
			if newval == data[:old].reverse
				respond ajaxreturn(:success)
			else
				respond ajaxreturn(:error, {:set => data[:old], :message => "You didn't reverse the text!"})
			end
		elsif data[:name] == 'caps'
			if data[:new] == 'CAPITALIZE ME'
				respond ajaxreturn(:success)
			else
				respond ajaxreturn(:error, {:set => data[:old], :message => "Your capitalization abilities leave a lot to be desired."})
			end
		end
	when :click2delete
		respond ajaxreturn(:success)
	end
	respond ajaxreturn(:error, :message => request.POST.to_json)
  end
end
