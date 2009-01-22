var fbcount = 0
function rha_error(message)
{
	fbcount = fbcount + 1;
	$('body').prepend("<div id='RHAfb" + fbcount + "' class='RHA flashbox' title='Click to dismiss message'>" + message + "</div>")
	$('#RHAfb' + fbcount).slideDown('slow');
	$('#RHAfb' + fbcount).hover(
		function()
		{
			$(this).attr('class', 'RHA flashbox hover')
		},
		function ()
		{
			$(this).attr('class', 'RHA flashbox')
		}
	);
	$('#RHAfb' + fbcount).click(function(event){
		$(this).slideUp('fast', function(){
			$(this).remove();
		});
	});
        //alert(message);
}
function rha_ajax(url, params, containm, successcb){
	ajimg = containm.find(".RHA.ajimg")
	ajimg.attr('src','/load.gif') // Set ajax images to loading icons
	ajimg.fadeIn('fast')
	ajimg.ajaxError(function(event, request, settings, emsg){
		$(this).attr('src','/cross.png');
		$(this).fadeOut(5000);
		rha_error("An AJAX error occured: " + request.status);
	});
	$.ajax({
		type: "POST",
		url: url,
		data: params,
		timeout: 10000,
		dataType: 'json',
		success: function(data){
			successcb(data,containm);
			if(data['status'] == 'success')
			{
				ajimg.attr('src', '/tick.png');
			} else {
				ajimg.attr('src', '/cross.png');
			}
			ajimg.fadeOut(5000);
		}
	});
}
$(document).ready(function(){
	var lastrha = 'none';
	$(".RHA.c2d.button > a").click(function(event){
		event.preventDefault();
		container = $(this).parents('.RHA.c2d.container');
		container_tag = '';
		container.each(function(){
			container_tag = this.tagName;
		});
		ajimg = container.find('.RHA.ajimg');
		ajimg.attr('src', '/load.gif');
		ajurl = container.find('.RHA.url').attr('value');
		params = {};
		paramsjq = container.find(".RHA.c2d.param");
		paramsjq.each(function(i){
			params[$(this).attr('name')] = $(this).attr('value');
		})
		params["RHAtype"] = 'click2delete';
		rha_ajax(ajurl, params, container, function(data){
			if(data['status'] == 'success')
			{
				if(container_tag == 'TR')
				{
					container.fadeOut('slow', function(){
						$(this).remove();
					});
				} else {
					container.slideUp('slow', function(){
						$(this).remove();
					});
				}
			} else if(data['message']) {
				ajimg.attr('src', '/delete.png').fadeIn('fast')
				rha_error(data['message']);
			}
		});
	});
	$(".RHA.c2e.container").click(function(event){
		id = $(this).attr('id');
		container = $(this);
		ajurl = container.children('.RHA.url').attr('value');
		c2etext = $(this).children('.RHA.c2e.text');
		if(lastrha != id)
		{
			lastrha = id;
			$(this).children('.RHA.c2e.text').fadeOut('fast', function(){
				// Replace the contents of the .RHA.c2e.text box with a text input, wrapped in a <form>
				oldval = $(this).text();
				$(this).html("<form id='frm-" + id + "' style='display:inline;'><input type='text' value='" + $(this).text() + "' class='RHA c2e tb' /></form>");
				input = $(this).find(".RHA.c2e.tb");
				$(this).children('form').submit(function(event){
					// Pervent the form wrapper from submitting, instead trigger the blur event
					// This is an easy way of catching carriage return
					input.blur();
					event.preventDefault();
					return false;
				});
				input.focus(); // Focus on the textbox now that it exists
				input.blur(function(event){
					newval = input.attr('value')
					c2etext.fadeOut('fast', function(){
						$(this).text(newval);
						$(this).fadeIn('fast', function(){
							newval = $(this).text();
							oldval = $(this).siblings(".RHA.original").attr('value');
							//oldval = $(this).find(".RHA.c2e.old").attr('value');
							//alert("New: " + newval + ". Old: " + oldval);
							//alert(oldval);
							if(newval != oldval)
							{
								$(this).siblings(".RHA.original").attr('value', newval);
								params = {};
								paramsjq = $(this).siblings(".RHA.c2e.param")
								paramsjq.each(function(i){
									params[$(this).attr('name')] = $(this).attr('value');
								})
								params["RHAtype"] = 'click2edit'
								params["RHAclick2edit-new"] = newval
								params["RHAclick2edit-old"] = oldval
								rha_ajax(ajurl, params, $(this).parents('.RHA.c2e.container'), function(data, contain){
									// Success callback
									if(data['message'])
									{
											rha_error(data['message']);
									}
									if(data['set'])
									{
										contain.find('.RHA.c2e.text').fadeOut('fast', function(){
											$(this).text(data['set']);
											$(this).siblings(".RHA.original").attr('value',data['set']);
											$(this).fadeIn('fast');
										})
									}
								});
							}
						});
					});
					if(lastrha == id)
					{
						lastrha = 'none';
					}
				})
			})
			c2etext.fadeIn('fast', function(event){ // Fade the container back in once the contents have been switched
				input.focus(); // Focus again once it's faded in (IE7 compatibility)
			});
		}
	})
})
