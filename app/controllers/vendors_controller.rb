class VendorsController < ApplicationController
  layout "vendors"
  before_action :set_vendor, only: %i[ show edit update destroy ]

  def index
    if params[:query].present?
      query = params[:query].downcase
      @vendors = Vendor.where('LOWER("Name") LIKE ?', "%#{query}%")
    else
      @vendors = Vendor.all
    end
  end

  def show
  end

  def new
    @vendor = Vendor.new
    render partial: "form", locals: { vendor: @vendor }
  end

  def create
    @vendor = Vendor.new(vendor_params)

    if @vendor.save
      redirect_to @vendor, notice: "Vendor added successfully!"
    else
      render partial: "form", locals: { vendor: @vendor }
    end
  end

  def edit
    render partial: "form", locals: { vendor: @vendor }
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to @vendor, notice: "Vendor updated successfully!"
    else
      render partial: "form", locals: { vendor: @vendor }
    end
  end

  def destroy
    @vendor.destroy
    redirect_to vendors_path
  end

  private
  def set_vendor
    @vendor = Vendor.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:Name, :Address, :Phone_Number)
  end
end
