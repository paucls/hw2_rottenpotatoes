class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session_used = false
    @all_ratings = Movie.all_ratings
    @ratings = params[:ratings]
    if @ratings
      @used_ratings = @ratings.keys
    elsif session[:used_ratings] || params[:commit] == "Refresh"
      @used_ratings = session[:used_ratings]
      session_used = true
    else
      @used_ratings = @all_ratings
    end
    
    if params[:sort]
      @sort = params[:sort]
      @movies = Movie.order(params[:sort]).find_all_by_rating(@used_ratings)
    elsif session[:sort]
      @sort = session[:sort]
      @movies = Movie.order(session[:sort]).find_all_by_rating(@used_ratings)
      session_used = true
    else
      @movies = Movie.find_all_by_rating(@used_ratings)
    end
    
    # store the result in session
    session[:used_ratings] = @used_ratings
    session[:sort] = @sort
    # If session was used, redirect to remain restfull
    if session_used
      redirect_to movies_path(:sort => @sort, :ratings => Hash[@used_ratings.map {|x| [x,1]}])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
