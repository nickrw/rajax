class MainController < Controller
  def index
    @title = "Rajax test pad"
    %{
      <p>Rajax is a work-in-progess Ramaze ajax helper, it is ORM agnostic (in fact, you don't even need to be using a database in order to take advantage of it)</p>
      <p>Rajax can do the following:</p>
      <hr />
      <h3>Edit things in-page</h3>
      <p>The <strong>click2edit</strong> helper method allows you to make text editable, submitting results, plus additional parameters you specify, to a controller of your choice.</p>
      <p><strong><a href='/click2edit/'>View examples</a></strong></p>

      <hr />
      <h3>Delete items from a page</h3>
      <p>The <strong>click2delete_button</strong> method gives you the HTML for a button which, when clicked, deletes an iitem from the page if a success response is given by the ajax controller. Parameters you specify are passed to the ajax controller.</p>
      <p>The <strong>click2delete_wrapper</strong> method wraps HTML around the item you want to be deletable. This method must contain the output of a click2delete_button for it to be of any use. You specify to this method what sort of tag you would like the wrapper to use, E.G. :tr for a table-row or :div for a block element.</p>
      <p><strong><a href='/click2delete/'>View examples</a></strong></p>
      
      <hr />
      <h3>Handle forms submission/response in-page</h3>
      <p>The <strong>ajaxform</strong> method wraps <form> tags around the given input which stop the form from submitting normally, instead sending the data to the ajax controller.</p>
      <p><strong><a href='/ajaxform/'>View example</a></strong></p>
    }
  end
end
