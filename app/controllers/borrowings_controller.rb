class BorrowingsController < ApplicationController
  before_action :set_borrowing, only: [ :edit, :update, :destroy ]
  before_action :set_club, only: [ :balance_sheet ]

  def index
    # Update the status of overdue borrowings
    @overdue = Borrowing.where("due_date < ? AND status = ?", Date.today, "borrowed")
    .update_all(status: "overdue")
    @borrowed = Borrowing.includes(:club, :equipment).where(status: "borrowed")
    @returned = Borrowing.where(status: "returned")
    
  end

  def super_club_borrowings
    @super_clubs = Club.where(Is_Super_Club: true)
    
    # Get all sub-club IDs for super clubs
    sub_club_ids = Club.where(Parent_Club: @super_clubs.pluck(:Club_ID)).pluck(:Club_ID)
    
    # Combine super club IDs and their sub-club IDs
    all_related_club_ids = @super_clubs.pluck(:Club_ID) + sub_club_ids
    
    @super_club_borrowings = Borrowing.includes(:equipment, :club)
                                     .where(club_id: all_related_club_ids)
  end

  def sub_club_borrowings
    @sub_clubs = Club.where(Is_Super_Club: false)
    @sub_club_borrowings = Borrowing.includes(:equipment, :club)
                                     .where(club_id: @sub_clubs.pluck(:Club_ID))
  end

  def balance_sheet
    @club = Club.find(params[:id])
    
    if @club.Is_Super_Club
      # Get all sub-club IDs for this super club
      sub_club_ids = Club.where(Parent_Club: @club.Club_ID).pluck(:Club_ID)
      # Include both super club and its sub-clubs
      club_ids = [@club.Club_ID] + sub_club_ids
      @borrowings = Borrowing.includes(:equipment, :club)
                            .where(club_id: club_ids)
    else
      @borrowings = Borrowing.includes(:equipment)
                            .where(club_id: @club.id)
    end
  
    if params[:search].present?
      search_term = params[:search].downcase
      @borrowings = @borrowings.select do |borrowing|
        borrowing.equipment&.Equipment_Name&.downcase&.include?(search_term) ||
        borrowing.status&.downcase&.include?(search_term)
      end
    end
  end

  def new
    @borrowing = Borrowing.new
    @clubs = Club.all
    @grouped_equipments = Equipment.grouped_for_selection  # Add this line
    @equipments = Equipment.all  # Keep this if you still need it for other purposes
  end

  def show
    @borrowing = Borrowing.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to borrowings_path, alert: "Borrowing record not found."
  end

  # In your existing BorrowingsController
def create
  @borrowing = Borrowing.new(borrowing_params)
  equipment = Equipment.find_by(Equipment_ID: @borrowing.equipment_id)

  if equipment.nil?
    redirect_to new_borrowing_path, alert: "Selected equipment does not exist."
    return
  end

  if equipment.Status != 'Available'
    redirect_to borrowing_notification_path, alert: "Equipment is not available for borrowing."
    return
  end

  if @borrowing.save
    redirect_to borrowings_path, notice: "Borrowing record created successfully."
  else
    redirect_to borrowing_notification_path, alert: "Failed to create borrowing record. Please try again."
  end
end

  def edit
    @borrowing = Borrowing.find_by(id: params[:id])
    if @borrowing.nil?
      redirect_to borrowings_path, alert: "Borrowing record not found."
    else
      @clubs = Club.all
      @grouped_equipments = Equipment.grouped_for_selection
      @equipments = Equipment.all
    end
  rescue => e
    Rails.logger.error("Error in edit: #{e.message}")
    redirect_to borrowings_path, alert: "Error loading borrowing record."
  end
  
  def update
    begin
      ActiveRecord::Base.transaction do
        old_quantity = @borrowing.quantity
        old_equipment = @borrowing.equipment
        new_quantity = borrowing_params[:quantity].to_i
        new_equipment = Equipment.find(borrowing_params[:equipment_id])
        new_due_date = Date.parse(borrowing_params[:due_date])
  
        Rails.logger.info "Old due date: #{@borrowing.due_date}"
        Rails.logger.info "New due date: #{new_due_date}"
        Rails.logger.info "Current time: #{Time.current}"
  
        # Handle stock updates
        if old_equipment
          old_borrowed_items = Equipment.where(
            Equipment_Name: old_equipment.Equipment_Name,
            Status: 'Unavailable'
          ).limit(old_quantity)
          
          old_borrowed_items.update_all(Status: 'Available', stock: 1)
        end
  
        # Check availability
        available_items = Equipment.where(
          Equipment_Name: new_equipment.Equipment_Name,
          Status: 'Available'
        ).limit(new_quantity)
  
        if available_items.count < new_quantity
          raise StandardError, "Not enough items available"
        end
  
        # Determine new status
        new_status = new_due_date < Time.current ? 'overdue' : 'borrowed'
        Rails.logger.info "Setting new status to: #{new_status}"
  
        # Update borrowing record
        update_successful = @borrowing.update(
          borrowing_params.merge(status: new_status)
        )
  
        if update_successful
          available_items.update_all(Status: 'Unavailable', stock: 0)
          redirect_to borrowings_path, notice: 'Borrowing updated successfully' and return
        else
          raise StandardError, "Failed to update borrowing"
        end
      end
    rescue => e
      Rails.logger.error "Update failed: #{e.message}"
      @clubs = Club.all
      @grouped_equipments = Equipment.grouped_for_selection
      flash.now[:alert] = e.message
      render :edit
    end
  end

  def destroy
    @borrowing.destroy
    redirect_to borrowings_path, notice: "Borrowing record deleted successfully."
  end

  def return
    borrowing = Borrowing.find(params[:id])
    if borrowing.update(status: "returned")
      borrowing.equipment.update(Status: 'Available', stock: 1)
      borrowing.update_equipment_group_stock
      Notification.where(borrowing_id: borrowing.id).destroy_all
      flash[:success] = "Borrowing status updated to returned."
    else
      flash[:error] = "Failed to update borrowing status."
    end
    redirect_to pic_dashboard_path
  end

  def equipment_by_club
    club_id = params[:club_id]
    equipments = Equipment.where(Club_ID: club_id)

    if equipments.any?
      render json: { equipments: equipments.map { |e| { id: e.Equipment_ID, name: e.Equipment_Name, stock: e.stock } } }
    else
      render json: { equipments: [] }, status: :not_found
    end
  end

  private

  def set_borrowing
    @borrowing = Borrowing.find_by(id: params[:id])
    unless @borrowing
      redirect_to borrowings_path, alert: "Borrowing record not found."
    end
  end

  def set_club
    @club = Club.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to borrowings_path, alert: "Club not found."
  end

  # before_action :require_pic! # Ensure only PIC users can access this action
  def borrowing_params
    params.require(:borrowing).permit(:equipment_id, :club_id, :borrow_date, :due_date, :quantity, :status)
  end
end
