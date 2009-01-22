require 'rubygems'
require 'json'
require 'digest/md5'
module Ramaze
	module Ajax
		class Reference
			attr_accessor :table, :uuid_col
			def initialize(table, uuid_col, uuid)
				@table = table
				@uuid_col = uuid_col
			end
		end
	end
	module Helper::Ajax
		#
		#	click2edit(params, text, url, &block)
		#		text: String to make clickily editable
		#		params: Hash of parameters to pass through to the ajax controller
		#		url: url of the ajax controller (default: /ajax/)
		def click2edit(text = '', params={}, url = '/ajax/')
			output = "<span class='RHA c2e container' id='RHA::c2e::" + Digest::MD5.hexdigest(rand(4398540824).to_s) + "'>\n"
			output << "<span class='RHA c2e text'>" + text.to_s + "</span>\n"
			output << "<img class='RHA ajimg' src='/load.gif' style='display:none;' />\n"
			output << "<input class='RHA original' type='hidden' value=#{text.inspect} />\n"
			output << "<input class='RHA url' type='hidden' value=#{url.inspect} />\n"
			params.each do |name, value|
				name = "RHA::" + name.to_s
				output << "<input type='hidden' class='RHA c2e param' name=#{name.inspect} value=#{value.to_s.inspect} />\n"
			end
			output << "</span>\n"
			output
		end

		def click2delete_button(params = {}, url = '/ajax/', confirm = 'Click again to confirm', imgurl = '/delete.png')
			output = %{
				<span class='RHA c2d button'>
					<a href='javascript:void;'><img src='#{imgurl}' class='RHA ajimg' style='border:0px;' alt='Delete item' /></a>
					<input class='RHA c2d confirm' type='hidden' value='0' />
					<input class='RHA url' type='hidden' value='#{url}' />
			}
			params.each do |name, value|
                                name = "RHA::" + name.to_s
                                output << "<input type='hidden' class='RHA c2d param' name=#{name.inspect} value=#{value.to_s.inspect} />\n"
                        end
			output << %{		<span style='display:none;'>#{confirm}</span>
				</span>
			}
			output
		end
		def click2delete_wrapper(text, tag = :div)
			output = "<#{tag} class='RHA c2d container' id='RHA::c2d::" + Digest::MD5.hexdigest(rand(9398440824).to_s) + "'>\n"
			output + text + "</#{tag}>"
		end
		def scriptlink(scr = '/js/ajaxhelper.js')
			"<script type='text/javascript' src='#{scr}'></script>"
		end
		def parseajaxdata
			output = {}
			unless request.POST['RHAtype'].nil?
				output[:type] = request.POST['RHAtype'].to_sym
				output[:new] = request.POST['RHA' + output[:type].to_s + '-new']
				output[:old] = request.POST['RHA' + output[:type].to_s + '-old']
				request.POST.each do |key, val|
					if key.match(/^RHA::/)
						outkey = key.gsub(/^RHA::/, '').to_sym
						output[outkey] = val if output[outkey].nil?
					end
				end
			else
				output = nil
			end
			output
		end
		def ajaxreturn(returnst, others={})
			{:status => returnst}.merge(others).to_json
		end
	end
end
