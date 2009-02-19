var fbcount = 0; // Maintain separate ajax flashboxen

// rha_error(message): Display ajax flashbox with given message.
// This will add a div with the class 'RHAfb' to the start of the <body>. Style this as you wish.
// 'RHAfb.hover' class is used while the mouse is over the element.
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

// rha_ajax(url, perams, containm, successcb)
// Send/receive ajax data (params) to given url.
// container jQuery object must be supplied, along with a callback to fire on successful data return.
function rha_ajax(url, params, containm, ajimg, successcb){
        ajimg.attr('src','/ajimg/load.gif') // Set ajax images to loading icons
        ajimg.fadeIn('fast')
        ajimg.ajaxError(function(event, request, settings, emsg){
                $(this).attr('src','/ajimg/cross.png');
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
                                ajimg.attr('src', '/ajimg/tick.png');
                                ajimg.fadeOut(5000);
                        } else if(data['status'] != 'silent') {
                                ajimg.attr('src', '/ajimg/cross.png');
                                ajimg.fadeOut(5000);
                        }
                        if(data['message']) {
                                rha_error(data['message']);
                        }
                }
        });
}

// Set up events when document is ready
$(document).ready(function(){

        var lastrha = 'none';

        // ajaxform setup
        $(".RHA.form.container").each(function(i){
                $(this).find(":submit").after("<img src='/ajimg/load.gif' alt='Loading...' style='display:none;' class='RHA ajimg form' />");
        });
        $(".RHA.form.container").submit(function(event){
                container = $(this);
                ajimg = container.find(".RHA.ajimg.form");
                submit = container.find(":submit")
                submit.attr('disabled', 'disabled');
                ajimg.fadeIn('fast');
                params = {}
                container.find(":input").each(function(i){
                        if($(this).attr('name') != '') {
                                params['RHA::' + $(this).attr('name')] = $(this).attr('value')
                        }
                });
                params["RHAtype"] = 'ajaxform';
                url = container.attr('action');
                rha_ajax(url, params, container, ajimg, function(data){
                        if(data['replace'] || data['append'])
                        {
                                $(".RHA.form.replace").slideUp('slow', function(){
                                        $(this).remove();
                                });
                                if(data['replace'])
                                {
                                        container.slideUp('slow', function(){
                                                $(this).html("<div class='RHA form replace' style=''>"+data['replace']+"</div>");
                                                $(this).slideDown('slow')
                                        });
                                }
                                if(data['append'])
                                {
                                        container.after("<div class='RHA form replace' style='display:none;'>"+data['append']+"</div>");
                                        $(".RHA.form.replace").slideDown('slow')
                                }
                                if(!data['disable'])
                                {
                                        submit.removeAttr('disabled');
                                }
                        }
                })
                event.preventDefault();
                return false;
        });

        // click2delete setup
        $(".RHA.c2d.button > a").click(function(event){
                event.preventDefault();
                container = $(this).parents('.RHA.c2d.container');
                container_tag = '';
                container.each(function(){
                        // Needed to determine the type of fade. TRs don't slideUp well.
                        container_tag = this.tagName;
                });
                ajimg = container.find('.RHA.ajimg.c2d');
                ajurl = container.find('.RHA.url').attr('value');
                params = {};
                paramsjq = container.find(".RHA.c2d.param"); // Find parameters for ajax request
                paramsjq.each(function(i){
                        params[$(this).attr('name')] = $(this).attr('value');
                })
                params["RHAtype"] = 'click2delete';
                button = container.find('.RHA.c2d.button > a > img');
                buttonoff = button.offset();
                doajax = false;
                if(container.find('.RHA.c2d.confirm.set').attr('value') == '1')
                {
                        clicks = container.find('.RHA.c2d.confirm.clicks')
                        if(clicks.attr('value') == '1')
                        {
                                doajax = true;
                        } else {
                                clicks.attr('value', '1')
                        }
                } else {
                        doajax = true;
                }
                if(doajax)
                {
                        ajimg.attr('src', '/ajimg/load.gif');
                        
                        rha_ajax(ajurl, params, container, ajimg, function(data){
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
                                        ajimg.attr('src', '/ajimg/delete.png').fadeIn('fast')
                                }
                        });
                }
        });
        
        // click2edit setup
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
                                                                contain = $(this).parents('.RHA.c2e.container')
                                                                ajimg = contain.find(".RHA.ajimg.c2e")
                                                                rha_ajax(ajurl, params, contain, ajimg, function(data, contain){
                                                                        // Success callback
                                                                        if(data['set'])
                                                                        {
                                                                                contain.find('.RHA.c2e.text').fadeOut('fast', function(){
                                                                                        $(this).text(data['set']);
                                                                                        $(this).siblings(".RHA.original").attr('value',data['set']);
                                                                                        $(this).fadeIn('fast');
                                                                                })
                                                                        }
                                                                        if(data['disable'])
                                                                        {
                                                                                contain.unbind('click');
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
