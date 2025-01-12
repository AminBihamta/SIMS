class ClubsController < ApplicationController
  def new_super_club
    @club = Club.new(Is_Super_Club: true)
    render :new_super_club
  end

  def index
    @clubs = Club.where(Is_Super_Club: true)
    @total_budget = @clubs.sum(:Budget)
  end

  def show_children
    @parent_club = Club.find(params[:id])
    @child_clubs = Club.where(Parent_Club: @parent_club.Club_ID)
    @total_budget = @child_clubs.sum(:Budget)
  end

  def show
    @club = Club.find(params[:id])
    render partial: "club_details", locals: { club: @club }
  end

  def new_sub_club
    @club = Club.new(Is_Super_Club: false, Parent_Club: params[:super_club_id])
    @super_clubs = Club.where(Is_Super_Club: true)
    render :new_sub_club
  end

  def sub_clubs
    @sub_clubs = Club.where(Parent_Club: params[:id])
    render json: @sub_clubs
  end

  def edit
    @club = Club.find(params[:id])
    @super_clubs = Club.where(Is_Super_Club: true)
  end

def update
  @club = Club.find(params[:id])
  @parent_club = @club.parent_club

  if @club.update(club_params)
    if @parent_club
      total_budget = Club.where(Parent_Club: @parent_club.Club_ID).sum(:Budget)

      unless @parent_club.update(Budget: total_budget)
        Rails.logger.error "Failed to update parent club budget: #{@parent_club.errors.full_messages}"
      end
    end

    redirect_to show_children_club_path(params[:club][:Parent_Club])
  else
    @super_clubs = Club.where(Is_Super_Club: true)
    render :edit, status: :unprocessable_entity
  end
end



  def destroy
    @club = Club.find(params[:id])
      @parent_club = @club.parent_club



    if @club.parent_club == nil
      @club.destroy
      redirect_to clubs_path, notice: "Club deleted successfully."
    else
          @club.destroy
          total_budget = Club.where(Parent_Club: @parent_club.Club_ID).sum(:Budget)
          @parent_club.update(Budget: total_budget)
      redirect_to show_children_club_path(@parent_club)
    end
  end

  def sub_clubs
    @sub_clubs = Club.where(Parent_Club: params[:id])
    render json: @sub_clubs
  end

  def create
    @club = Club.new(club_params)
    if @club.save
      if @club.Is_Super_Club
        redirect_to clubs_path, notice: "Club created successfully."
      else
          @parent_club = @club.parent_club
          total_budget = Club.where(Parent_Club: @parent_club.Club_ID).sum(:Budget)
          @parent_club.update(Budget: total_budget)
        redirect_to show_children_club_path(params[:club][:Parent_Club])
      end
    end
  end

  private

  def club_params
    params.require(:club).permit(:Is_Super_Club, :Club_Name, :Parent_Club, :Budget)
  end
end
