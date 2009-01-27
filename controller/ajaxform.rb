class Ajaxform < Controller
	map '/ajaxform'
	def index
		@title = "Rajax: ajaxform examples"
		output = "<a href='/'>&lt;&lt; Back to main page</a>"
		
		#EXAMPLE 1
		output << "<h3>Example 1</h3>"
		form = "<input type='text' name='bob' value='bob' /> <input type='submit' value='go' />"
    output << ajaxform(form, '/ajaxform/ajax') + "<br />More text"
			
		output
	end

	def ajax
		data = parseajaxdata
		respond ajaxreturn(:error, {:message => "No post data"}) if data.nil?
		case data[:type]
    when :ajaxform
      respond ajaxreturn(:success, :append => "<div style='font-weight:bold;'>Yay! (" + data[:bob].to_s + ")</div>")
		else
			respond ajaxreturn(:error)
		end
	end
end
