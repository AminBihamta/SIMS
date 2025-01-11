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

    if params[:query].present?
      # Perform case-insensitive search for Equipment_Name using ILIKE (PostgreSQL)
      @items = Equipment.where(Equipment_Name: @equipment_name).where('LOWER("Equipment_Name") LIKE ? OR "Equipment_ID" = ?',
                                                                      "%#{params[:query].downcase}%",
                                                                      params[:query].to_i)
    else
      @items = Equipment.where(Equipment_Name: @equipment_name)
    end
  end

  def show
  end

  def new
    @equipment = Equipment.new
    @form_url = equipments_path  # Set the form URL for the form submission
    @show_quantity_field = true # Set this flag to determine if the quantity field should be shown
    render partial: "form", locals: { equipment: @equipment, form_url: @form_url, show_quantity_field: @show_quantity_field }
  end

  def create
    quantity = params[:equipment][:quantity].to_i
    quantity = 1 if quantity < 1 # Default to at least one record

    equipment_params_without_quantity = equipment_params.except(:quantity) # Remove quantity from strong parameters

    begin
      ActiveRecord::Base.transaction do
        @equipments = []
        quantity.times do
          @equipments << Equipment.create!(equipment_params_without_quantity)
        end
      end

      render json: { success: true, redirect_url: equipments_path, notice: "#{quantity} Equipment record(s) created successfully!" }
    rescue ActiveRecord::RecordInvalid => e
      @equipment = Equipment.new(equipment_params_without_quantity)
      flash.now[:alert] = "Error creating equipment: #{e.message}"
      render partial: "form", locals: { equipment: @equipment, form_url: equipments_path, show_quantity_field: true }, status: :unprocessable_entity
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
    @equipment.destroy
    redirect_to root_path, status: :see_other
  end

  private
  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(:Equipment_Name, :Financial_Record_Id, :Club_ID, :Vendor_ID, :quantity)
  end
end
