class Click2edit < Controller
	map '/click2edit'
	def index
		@title = "Rajax: click2edit examples"
		output = "<a href='/'>&lt;&lt; Back to main page</a>"
		
		#EXAMPLE 1
		output << "<h3>Example 1</h3>"
		output << "<p>Click the text to turn it into a text box and edit. Reverse the text for the ajax controller to accept it.</p>"
		output << "<div style='margin-left:25px;'><h4>Example</h4>"
		output << "<p>" + click2edit("abcdefg", {:name => 'reverse'}, '/click2edit/ajax/') + "</p>"
		output << "<h4>Code to produce</h4>"
		output << "<pre>click2edit(\"abcdefg\", {:name =&gt; 'reverse'}, '/click2edit/ajax/')</pre></div><hr />"
		
		#EXAMPLE 2
		output << "<h3>Example 2</h3>"
		output << "<p>Click the text to turn it into a text box and edit. Capitalize ('CAPITALIZE ME') the text to have the ajax controller accept it. The controller will overwrite your changes with 'Well done!' if you are successful and prevent any further changes.</p>"
		output << "<div style='margin-left:25px;'><h4>Example</h4>"
		output << "<p>" + click2edit("capitalize me", {:name => 'caps'}, '/click2edit/ajax/') + "</p>"
		output << "<h4>Code to produce</h4>"
                output << "<pre>click2edit(\"capitalize me\", {:name =&gt; 'caps'}, '/click2edit/ajax/')</pre></div><hr />"
	
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
					respond ajaxreturn(:success, {:set => 'Well done!', :disable => true})
				else
					respond ajaxreturn(:error, {:set => data[:old], :message => "Your capitalization abilities leave a lot to be desired."})
				end
			end
		else
			respond ajaxreturn(:error)
		end
	end
end
