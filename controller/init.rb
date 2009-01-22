# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  helper :ajax
  engine :Ezamar
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
