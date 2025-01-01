class EquipmentsController < ApplicationController
  layout "equipments"
  before_action :set_equipment, only: %i[ show edit update destroy ]
  def index
    @equipments = Equipment.all
    @equipment = Equipment

    if params[:query].present?
      query = params[:query].downcase
      @unique_equipments = Equipment.where('LOWER("Equipment_Name") LIKE ?', "%#{query}%").distinct
    else
      @unique_equipments = Equipment.select(:Equipment_Name).distinct
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
    render partial: "form", locals: { equipment: @equipment }
  end

  def create
    @equipment = Equipment.new(equipment_params)

    if @equipment.save
      redirect_to @equipment, notice: "Equipment added successfully!"
    else
      render partial: "form", locals: { equipment: @equipment }
    end
  end

  def edit
    render partial: "form", locals: { equipment: @equipment }
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to @equipment, notice: "Equipment updated successfully!"
    else
      render partial: "form", locals: { equipment: @equipment }
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
    params.require(:equipment).permit(:Equipment_Name, :Financial_Record_Id, :Club_ID, :Vendor_ID)
  end
end
