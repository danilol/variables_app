# encoding : utf-8
class ScriptsController < ApplicationController
  before_filter :ensure_authentication, :only => [:index]

  def index

  end

  def generate_script
  	sprint = params["sprint_number"].to_i
  	script_name = params["script_name"]
  	@generated_script = ExportScript.export_script_by_sprint(sprint, script_name) 

  	render "index",  generated_script: @generated_script 
  end

end
