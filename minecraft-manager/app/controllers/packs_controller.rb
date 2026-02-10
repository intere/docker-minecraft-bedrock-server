class PacksController < ApplicationController
  before_action :set_pack, only: %i[destroy]

  def index
    @packs = Pack.all
  end

  def new
  end

  def create
    uploaded_file = params[:pack_file]
    unless uploaded_file
      redirect_to new_pack_path, alert: "Please select a file to upload."
      return
    end

    result = PackService.import(uploaded_file)
    if result[:success]
      redirect_to packs_path, notice: result[:message]
    else
      redirect_to new_pack_path, alert: result[:message]
    end
  end

  def destroy
    result = PackService.delete_pack(@pack)
    if result[:success]
      redirect_to packs_path, notice: result[:message]
    else
      redirect_to packs_path, alert: result[:message]
    end
  end

  private

  def set_pack
    @pack = Pack.find(params[:id])
  end
end
