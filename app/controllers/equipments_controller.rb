class EquipmentsController < ApplicationController
  layout "equipments"
  before_action :set_equipment, only: %i[ show edit update destroy ]
  def index
    @equipments = Equipment.all
    @equipment = Equipment

    if params[:query].present?
      query = params[:query].downcase
      @unique_equipments = Equipment.where('LOWER("Equipment_Name") LIKE ?', "%#{query}%").distinct.order(:Equipment_Name)
    else
      @unique_equipments = Equipment.select(:Equipment_Name).distinct.order(:Equipment_Name)
    end
  end

  def group_items
    @equipment_name = params[:equipment_name]

    base_query = Equipment.where(Equipment_Name: @equipment_name)

    if params[:query].present?
      @items = base_query.where('LOWER("Equipment_Name") LIKE ? OR "Equipment_ID" = ?',
                               "%#{params[:query].downcase}%",
                               params[:query].to_i)
    else
      @items = base_query
    end

    @total_stock = Equipment.group_stock(@equipment_name)
    @available_stock = Equipment.available_stock(@equipment_name)
  end

  def show
  end

  def new
    @borrowing = Borrowing.new
    @clubs = Club.all
    @grouped_equipments = Equipment.grouped_for_selection
    @equipment = Equipment.new
    @form_url = equipments_path  # Set the form URL for the form submission
    @show_quantity_field = true # Set this flag to determine if the quantity field should be shown
    render partial: "form", locals: { equipment: @equipment, form_url: @form_url, show_quantity_field: @show_quantity_field }
  end

  def create
    quantity = params[:equipment][:quantity].to_i
    quantity = 1 if quantity < 1

    equipment_params_without_quantity = equipment_params.except(:quantity)

    begin
      ActiveRecord::Base.transaction do
        @equipments = []
        quantity.times do
          equipment = Equipment.new(equipment_params_without_quantity)
          equipment.save!
          @equipments << equipment
        end
      end

      render json: {
        success: true,
        redirect_url: equipments_path,
        notice: "#{quantity} Equipment record(s) created successfully!"
      }
    rescue => e
      Rails.logger.error("Equipment creation failed: #{e.message}")
      render json: {
        success: false,
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  def edit
    @form_url = equipment_path(@equipment)  # Set the form URL for the form submission
    @show_quantity_field = false # Or any condition to control the field visibility
    render partial: "form", locals: { equipment: @equipment, form_url: @form_url, show_quantity_field: @show_quantity_field }
  end

  def update
    if @equipment.update(equipment_params)
      render json: { success: true, redirect_url: equipment_path(@equipment), notice: "Equipment updated successfully!" }
    else
      render partial: "form", locals: { equipment: @equipment, form_url: equipment_path(@equipment), show_quantity_field: false }, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment2 = @equipment.Equipment_Name
    @equipment.destroy
    redirect_to "/equipments/group/#{@equipment2}", status: :see_other
  end

  def grouped_for_selection
    Equipment.select("Equipment_Name, COUNT(*) as total_count, SUM(CASE WHEN Status = 'Available' THEN stock ELSE 0 END) as available_stock")
            .group(:Equipment_Name)
            .order(:Equipment_Name)
  end

  private
  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(:Equipment_Name, :Financial_Record_Id, :Club_ID, :Vendor_ID, :quantity)
  end
end
