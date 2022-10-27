class EventsController < ApplicationController

    def show
      id = params[:id] # retrieve event ID from URI route
      @events = Event.find(id) # look up event by unique ID
      # will render app/views/events/show.<extension> by default
    end
  
    def index
      session[:username] = 'Mysaria' # TODO: record user during login
      @events = Event.all
    end
  
    def new
      # default: render 'new' template
    end
  
    # TODO refactor this method to create events
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    # TODO refactor this method to edit events
    def edit
      @movie = Movie.find params[:id]
    end

    def join_event
      # upon clicking `Join`, add uid to event's list of attendees
      @event = Event.find(params[:id])
      @event.add_person_to_event(params[:uid])
      # TODO change status of button from `Join` to grayed `Joined`
    end
  
    # TODO refactor this method to update events
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    # TODO refactor this method to destroy events
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    def myEvents
      @username = session[:username]
      @host_events = Event.find_all_host_events(@username)
      if @host_events.nil? or @host_events.empty?
        @host_events = []
      end
      @join_events = Event.find_all_join_events(@username)
      if @join_events.nil? or @join_events.empty?
        @join_events = []
      end
    end

    # TODO refactor this method to set required params
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date, :uid)
    end
  end
  