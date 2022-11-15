class EventsController < ApplicationController

    def show
      id = params[:id] # retrieve event ID from URI route
      u = current_user.username
      @event = Event.find(id) # look up event by unique ID
      @host = User.find_by(username: @event.host)
      @is_user_joined = @event.people.include?(u)
      @join_text = @is_user_joined ? :Unjoin : :Join
      @join_btn_style = get_join_button_style(u)
      @is_viewer_host = @event.host == u
      @username = u
      @rate_btn_style = get_rate_button_style(u)
      @attendees = {}
      @event.people.each do |person|
        @attendees[person] = User.find_by(username: person)
      end
    end
  
    def index
      # TODO: record user during login
      # session[:username] = 'testuser'

      #check for search query string
      q = params[:q].to_s.strip
      
      if not q.blank?
        # TODO issue #70
        event1 = Event.find_event_by_date(params[:select][:year], params[:select][:month])
        event3 = Event.find_event_by_status(params[:status_selected])
        event4 = Event.find_event_by_name(q)
        @events = [ event1, event3, event4 ].reject( &:nil? ).reduce( :& )
        @users = {}
        @events.each do |event|
          u = User.find_by(username: event.host)
          @users[event.host] = u
        end
        @page_name = "Search Result for '#{q}'"
      else
        @events = Event.all
        @users = {}
        @events.each do |event|
          u = User.find_by(username: event.host)
          @users[event.host] = u
        end
        @page_name = "Home"
      end
    end
  
    def new
      # default: render 'new' template
    end

    def create
      user = current_user.username
      check_result = is_event_params_valid(event_params)
      if check_result[:is_valid]
        @event = Event.create!(event_params)
        init_attributes = {:host => user, :joined => '0', :status => 0, :people => []}
        @event.update_attributes!(init_attributes)
        flash[:notice] = "Event '#{@event.title}' was successfully created."
        redirect_to events_path
      else
        flash[:warning] = "Field '#{check_result[:invalid_field]}' must be correctly filled in."
        # temporarily redirect to a new post event page
        redirect_to new_event_path
      end
    end

    def edit
      puts params
      @event = Event.find(params[:id])
    end

    def join
      u = current_user.username
      @event = Event.find(params[:id])
      is_unjoin = @event.people.include?(u)
      atts = @event.attributes
      atts[:people] = is_unjoin ? @event.people - [u] : @event.people.append(u)
      atts[:joined] = atts[:people].size
      @event.update_attributes!(atts)
      @join_btn_style = get_join_button_style(u)
      flash[:notice] = is_unjoin ? "You've unjoined it." : "You've joined it!"
      redirect_to event_path(@event)
    end

    def update
      @event = Event.find(params[:id])
      check_result = is_event_params_valid(event_params)
      if check_result[:is_valid]
        @event.update_attributes!(event_params)
        flash[:notice] = "Event '#{@event.title}' was successfully updated."
        redirect_to event_path(@event)
      else
        flash[:warning] = "Field '#{check_result[:invalid_field]}' must be correctly filled in."
        redirect_to edit_event_path(@event)
      end
    end

    def destroy
      @event = Event.find(params[:id])
      @event.destroy
      flash[:notice] = "Event '#{@event.title}' was deleted."
      redirect_to events_path
    end
  
    def myEvents
      @username = current_user.username # TODO: session[:username]
      @host_events = Event.find_all_host_events(@username)
      @host_events = [] if @host_events.nil? or @host_events.empty?
      @join_events = Event.find_all_join_events(@username)
      @join_events = [] if @join_events.nil? or @join_events.empty?
    end

    def ratePeople
      @event = Event.find(params[:id])
      u = current_user.username
      # @can_user_rate = !@event.rated_users.include?(u)
      @rate_btn_style = get_rate_button_style(u)
      puts "btn style"
      puts @rate_btn_style
      @is_viewer_host = @event.host == u
    end

    # TODO refactor this method to set required params
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def event_params
      params.require(:event).permit(:title, :host, :joined, :people, :status, :event_time, :attendee_limit, :description, :q)
    end

    private
    def is_event_params_valid(params)
      result = {:is_valid => true, :invalid_field => 'None'}
      # date = Date.strptime(params['event_time(1i)'] + '-' + params['event_time(2i)'] + '-' + params['event_time(3i)'],"%Y-%m-%d")
      if params["title"].nil? or params["title"].blank?
        result[:is_valid] = false
        result[:invalid_field] = 'Title'
      elsif params["attendee_limit"].nil? or params["attendee_limit"].blank?
        result[:is_valid] = false
        result[:invalid_field] = 'Maximum Number of Attendees'
      elsif Date.parse(params['event_time(1i)'] + '-' + params['event_time(2i)'] + '-' + params['event_time(3i)']).past?
        result[:is_valid] = false
        result[:invalid_field] = 'Event Time'
      end
      puts params[:event_time]
      return result
    end

    private
    def get_join_button_style(uname)
      return 'btn btn-secondary col-2' if @event.people.include?(uname)
      return 'btn btn-success col-2 disabled' if @event.people.size >= @event.attendee_limit or @event.status == "closed"
      return 'btn btn-success col-2'
    end
    def get_rate_button_style(u)
      return 'btn btn-primary col-2 disabled' if @event.rated_users.include?(u)
      return 'btn btn-primary col-2'
    end
  end
  