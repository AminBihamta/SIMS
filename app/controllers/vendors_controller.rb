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
    @equipments = @vendor.equipments
  end

  def new
    @vendor = Vendor.new
    render partial: "form", locals: { vendor: @vendor }
  end

  def create
    @vendor = Vendor.new(vendor_params)

    if @vendor.save
      redirect_to vendors_path, notice: "Vendor was successfully created."
    else
      render partial: "form", locals: { vendor: @vendor }, status: :unprocessable_entity
    end
  end

  def edit
    @vendor = Vendor.find(params[:id])
    @form_url = vendor_path(@vendor)
    render partial: "form", locals: { 
      vendor: @vendor, 
      form_url: @form_url 
    }
  end

  def update
    if @vendor.update(vendor_params)
            redirect_to vendor_path(@vendor), notice: "Vendor was successfully updated."

    else
      render partial: "form", locals: { vendor: @vendor }, status: :unprocessable_entity
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
