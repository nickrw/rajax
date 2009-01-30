class Ajaxform < Controller
  map '/ajaxform'
  def index
    @title = "Rajax: ajaxform examples"
    output = "<a href='/'>&lt;&lt; Back to main page</a>"

    #EXAMPLE 1
    output << "<h3>Example 1</h3>"
    output << "<p>This form will disable itself if you say 'bishop', it will be replaced with some top-secret information if you say 'mops'</p>"
    form = "<input type='text' name='text' value='bob' /> <input type='submit' value='go' />"
    output << ajaxform(form, '/ajaxform/ajax') + "<br />More text"
    output
  end
  def ajax
    data = parseajaxdata
    respond ajaxreturn(:error, {:message => "No post data"}) if data.nil?
    case data[:type]
    when :ajaxform
      if data[:text].empty?
        status = :error
	rparams = {:append => "<div style='font-weight:bold;color:red;'>You didn't say anything!</div>"}
      else
        status = :success
        rparams = {:append => "<div style='font-weight:bold;'>You said: " + data[:text].to_s + "</div>"}
      end
      if data[:text].downcase == 'bishop'
        rparams[:disable] = true
	rparams[:append].gsub!("</div>", ", so I'm disabling the form.</div>")
      elsif data[:text].downcase == 'mops'
        rparams[:replace] = "<p>Ssh, don't tell anyone!</p>"
        rparams.delete(:append)
      end
      respond ajaxreturn(status, rparams)
    else
      respond ajaxreturn(:error)
    end
  end
end
