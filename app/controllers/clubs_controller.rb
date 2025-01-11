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
  end

  def new_sub_club
    @club = Club.new(Is_Super_Club: false, Parent_Club: params[:parent_club_id])
    @super_clubs = Club.where(Is_Super_Club: true)
    render :new_sub_club
  end

  def edit
    @club = Club.find(params[:id])
    @super_clubs = Club.where(Is_Super_Club: true)
  end

  def update
    @club = Club.find(params[:id])
    if @club.update(club_params)
      redirect_to clubs_path, notice: "Club updated successfully."
    else
      @super_clubs = Club.where(Is_Super_Club: true)
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @club = Club.new(club_params)
    if @club.save
      redirect_to club_created_path
    else
      if @club.Is_Super_Club
        render :new_super_club, status: :unprocessable_entity
      else
        @super_clubs = Club.where(Is_Super_Club: true)
        render :new_sub_club, status: :unprocessable_entity
      end
    end
  end

  private

  def club_params
    params.require(:club).permit(:Is_Super_Club, :Club_Name, :Parent_Club, :Budget)
  end
end
