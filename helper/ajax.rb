require 'rubygems'
require 'json'
require 'digest/md5'
module Ramaze
  module Helper::Ajax
    #
    #
    #  click2edit(text, params, url)
    #    text: String to make clickily editable
    #    params: Hash of parameters to pass through to the ajax controller - :symbols for keys work best
    #    url: url of the ajax controller (specify where you have mapped your ajax controller - default: '/ajax/')
    #        you may find it easier to have an action on one controller that deals with all your application's AJAX or 
    #        have an ajax action for each controller.
    #
    #  This helper method returns the HTML required to make the text you pass in editable when clicked. See the comments below regarding
    #  the parseajaxdata method for params useage
    #
    def click2edit(text = '', params={}, url = '/ajax/')
      output = "<span class='RHA c2e container' id='RHA::c2e::" + Digest::MD5.hexdigest(rand(4398540824).to_s) + "'>\n"
      output << "<span class='RHA c2e text'>" + text.to_s + "</span>\n"
      output << "<img class='RHA ajimg' src='/ajimg/load.gif' style='display:none;' />\n"
      output << "<input class='RHA original' type='hidden' value=#{text.inspect} />\n"
      output << "<input class='RHA url' type='hidden' value=#{url.inspect} />\n"
      params.each do |name, value|
        name = "RHA::" + name.to_s
        output << "<input type='hidden' class='RHA c2e param' name=#{name.inspect} value=#{value.to_s.inspect} />\n"
      end
      output << "</span>\n"
      output
    end
    #
    #
    #  click2delete_button(params, url, confirm, imgurl)
    #    params: See click2edit documentation above
    #    url: See click2edit documentation above
    #    confirm: true to require double click to delete
    #    imgurl: Alternative path for delete button image
    #
    #  This helper method returns the HTML for a button to delete a set of data. To define the set of data you wish to delete
    #  you need to wrap it with the click2delete_wrapper method below. You should use the params here to let the ajax controller
    #  know what it is meant to be deleting and respond appropriately.
    #
    def click2delete_button(params = {}, url = '/ajax/', confirm = 0, imgurl = '/ajimg/delete.png')
      confirm = 1 if confirm == true
      confirm = 0 if confirm == false
      output = "<span class='RHA c2d button'><a href='javascript:void;'><img src='#{imgurl}' class='RHA ajimg' style='border:0px;' alt='Delete item' /></a>"
      output << "<input class='RHA c2d confirm set' type='hidden' value='#{confirm}' /><input class='RHA c2d confirm clicks' type='hidden' value='0' />"
      output << "<input class='RHA url' type='hidden' value='#{url}' />"
      params.each do |name, value|
        name = "RHA::" + name.to_s
        output << "<input type='hidden' class='RHA c2d param' name=#{name.inspect} value=#{value.to_s.inspect} />\n"
      end
      output << "<div class='RHA c2d confirm text' style='display:none;color:white;background-color:red;font-weight:bold;'>#{confirm}</div></span>"
      output
    end
    #
    #
    #  click2delete_wrapper(text, tag)
    #    text: String containing the item to be deleted. Must include the output from click2delete_button
    #    tag: The HTML tag to wrap the text in, a <div> (:div) by default produces the best results.
    #      There is somewhat patchy browser support for the effects produced by this when using a :tr (table-row)
    #
    #  This method wraps the given text in an HTML container which the ajaxhelper javascript will pick up upon. The delete button HTML
    #  produced by the click2delete_button method needs to be included in the text for this method to be of any use.
    #
    def click2delete_wrapper(text, tag = :div)
      if tag == :tr
        Ramaze::Log.warn "Be careful using the :tr tag with the click2delete wrapper, it does not render properly in all browsers."
      end
      "<#{tag} class='RHA c2d container' id='RHA::c2d::#{Digest::MD5.hexdigest(rand(9398440824).to_s)}'>#{text}</#{tag}>"
    end
    #
    #
    #  ajaxform(form, url, style)
    #    form: The HTML to wrap in a form - this should not include <form> tags
    #    url: The URL to send the ajax request to
    #    style: Style options to be added to the <form> tag. Default display:inline;
    #
    #  The ajaxform method creates a form around your inputs which will send data via ajax and display results
    #  without loading a new page. See ajaxreturn parameters below.
    #  
    def ajaxform(form, url='/ajax/', style='display:inline;')
      "<form action='#{url}' method='post' style='#{style}' class='RHA form container'>" + form.to_s + "</form>"
    end
    #
    #
    #  scriptlink(scr)
    #    scr: Optional, give the path to the ajaxhelper.js script. Leave blank for default
    #
    #  This method is simply for convenience - it outputs a <script> tag to include the javascript in the page.
    #
    def scriptlink(scr = '/js/ajaxhelper.js')
      "<script type='text/javascript' src='#{scr}'></script>"
    end
    #
    #
    #  parseajaxdata
    #    No arguments
    #
    #  This method returns a hash of information if it finds an ajax request in the POST data submitted by the browser,
    #  or nil if none was found. It will contain a few helper-set keys depending on the request type (:type will always be set).
    #
    #  Type may return as:
    #    :click2edit, :click2delete
    #  Other reserved keys are:
    #    :new - will be set if this is a click2edit request. This is the value that the user changed the text to.
    #    :old - will be set if this is a click2edit request. This is the original value of the text.d
    #
    #  Items you pass into an ajax creation method in the params hash will be available in the hash returned by parseajaxdata,
    #  so long as they aren't using one of the above reserved keys.
    #  E.G. This ajax creation method call:
    #    click2edit('some text', {:foo => 'bar', 'second' => 'item'})
    #  would have this hash returned by parseajaxdata:
    #    {:type => :click2edit, :new => 'whatever was typed in', :old => 'some text', :foo => 'bar', :second => 'item'}
    #
    def parseajaxdata
      output = {}
      unless request.POST['RHAtype'].nil?
        output[:type] = request.POST['RHAtype'].to_sym
        output[:new] = request.POST["RHA#{output[:type]}-new"]
        output[:old] = request.POST["RHA#{output[:type]}-old"]
        request.POST.each do |key, val|
          output[key.gsub(/^RHA::/, '').to_sym] ||= val if key.match(/^RHA::/)
        end
      else
        output = nil
      end
      output
    end
    #
    #
    #  ajaxreturn(returnstatus, otherparams)
    #    returnstatus: Indicate whether this ajax request has been successful or not by giving either:
    #        :success - Inform script that request was successful
    #        :error - Inform script that the request was not successful
    #        :silent - Same as :error, except the script will not mark it as failed (red cross)
    #    otherparams: A hash of other parameters which the script may act upon. Different options are available for each type
    #      All items will accept:
    #        :message - Displays the message using the rha_error(); javascript function.
    #          Especially useful when returning with an :error status to give the user a friendly explanation as to why
    #
    #      Additionally click2edit will accept:
    #        :set - String to change the text to. Return :error and set :set to the original text value to reject the new input and
    #          have it changed back to the original contents.
    #        :disable - Prevent any further text changes by setting this to true.
    #
    #      Additionally ajaxform will accept:
    #        :replace - The HTML to replace the form with (animated)
    #        :append  - The HTML to place after the form (animated)
    #        :disable - Set to true to have the submit button(s) remain disabled after the ajax transaction has finished.
    #
    #  This method returns the data given in the appropriate JSON format. You should respond directly with this return with no template.
    #  E.G.
    #    respond ajaxreturn(:success, {:disable => true})
    #
    def ajaxreturn(returnstatus, otherparams={})
      deliver = {:status => returnstatus}.merge(otherparams)
      if deliver.respond_to?('to_json')
        deliver.to_json
      else
        Ramaze::Log.warn 'Ramaze::Helper::Ajax requires JSON support: http://json.rubyforge.org/.'
        '{"status":"error","message":"Ramaze::Helper::Ajax requires JSON support: http:\/\/json.rubyforge.org\/."}'
      end
    end
  end
end
