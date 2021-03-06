########################################################################
# The ProjectsController class is responsible for managing project
# resources associated with the web service. It is the primary resource
# to which other records are related. Being a primary resource allows
# us to manage, authorization for group access to a project and all its
# related records.
#
# The controller uses an injection model for relating a project to a 
# a group. See lib/group_access.rb for injected methods.
########################################################################
class ProjectsController < ApplicationController

  ## RESCUE SETTINGS ---------------------------------------------------
	rescue_from Mongoid::Errors::DocumentNotFound, with: :missing_document
  rescue_from CanCan::AccessDenied, with: :access_denied
  
  
  ## CALL BACKS --------------------------------------------------------
  before_filter :authenticate_user!
  
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :set_project_class


  # CANCAN AUTHORIZATION -----------------------------------------------
  # This helper assumes that the instance variable @group is loaded
  # or checks Class permissions
  authorize_resource

  ######################################################################
  # GET /projects
  # GET /projects.json
  #
  # The index method displays the current users list of projects. If
  # the signed in user is a User::SERVICE_ADMIN, then all projects are 
  # listed.
  ######################################################################
  def index
 
    # Get page number
		page = params[:page].nil? ? 1 : params[:page]
		 
    if current_user.role == User::SERVICE_ADMIN
      @projects = Project.all.paginate(page: page,	per_page: PAGE_COUNT)	
    else
      @projects = current_user.projects.paginate(page: page,	per_page: PAGE_COUNT)	
    end
  end

  ######################################################################
  # GET /projects/1
  # GET /projects/1.json
  #
  # The show method will show the project record. The corresponding
  # view will show the owner name and list of user group names 
  # associated with the project.
  ######################################################################
  def show
  end

  ######################################################################
  # GET /projects/new
  #
  # The new method will show the user a new project form. It will also
  # lookup any groups that the user may have to see, if they want to
  # grant access to those groups to the user.
  ######################################################################
  def new
    @project = Project.new
  end

  ######################################################################
  # GET /projects/1/edit
  #
  # The standard edit method will display the edit form and include the
  # ability to select groups that will be given access to the project.
  ######################################################################
  def edit
  end

  ######################################################################
  # POST /projects
  # POST /projects.json
  #
  # The create method will create a new project and relate any selected
  # groups that the user selected.
  ######################################################################
  def create
    @project = Project.new(project_params)
    @project.user = current_user

    respond_to do |format|
      if @project.save
        @project.group_relate(params[:project][:group_ids])
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        @verrors = @project.errors.full_messages
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  ######################################################################
  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  #
  # The update will update the Project model object including any 
  # changes to the group access privileges that the user selected.
  ######################################################################
  def update
  
    # Check to see if the project group_ids hash is blank. This 
    # indicates that the user has deselected all groups, so we
    #  need to assign an empty array so the event relationship will
    # be cleared.
		params[:project][:group_ids] ||= []
		
    respond_to do |format|
      if @project.update(project_params)
      
        @project.group_relate(params[:project][:group_ids])
        @project.save
        
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  ######################################################################
  # DELETE /projects/1
  # DELETE /projects/1.json
  #
  # The destroy project method will delete the project, but does not 
  # destroy the related groups that were given access to the project.
  ######################################################################
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice:
        "Project was successfully deleted." }
      format.json { head :no_content }
    end
  end

  ## PRIVATE INSTANCE METHODS ------------------------------------------
  
  private
  
  ######################################################################
  # Use callbacks to share common setup or constraints between actions.
  ######################################################################
  def set_project
    @project = Project.find(params[:id])
  end

	######################################################################
	# The set_project_class method sets an instance variable for the CSS
	# class that will highlight the menu item. 
	######################################################################
  def set_project_class
    @project_active = "class=active" 
  end

  ######################################################################
  # Never trust parameters from the scary internet, only allow the 
  # white list through.
  ######################################################################
  def project_params
    params.require(:project).permit(:name, :description, :group_ids, :charter_doc)
  end
  
  ######################################################################
  # The display_alert_message will display an alert on the project#index
  # page.
  ######################################################################
  def display_alert_msg(msg)
    flash[:alert] = msg
    redirect_to projects_url
  end
  
  
  ######################################################################
  # The access_denied method is the controller method for catching
  # a CanCan exception for an unauthorized action. The user will be
  # redirected to the projects_url
  ######################################################################
  def access_denied(exception)
    msg = "You are not authorized to access the requested #{exception.subject.class}."
    display_alert_msg(msg)
  end
  
  
  ######################################################################
  # The missing_document method is the controller method for catching
  # a Mongoid Mongoid::Errors::DocumentNotFound exception across all
  # controller actions. User will be redirected to the projects_url
  ######################################################################
  def missing_document(exception)
    msg = "We are unable to find the requested #{exception.klass} - ID ##{exception.params[0]}"
    display_alert_msg(msg)
  end    
  
end
