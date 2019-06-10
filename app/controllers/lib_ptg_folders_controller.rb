class LibPtgFoldersController < ApplicationController
  before_action :set_lib_ptg_folder, only: [:show, :edit, :update, :destroy]

  # GET /lib_ptg_folders
  # GET /lib_ptg_folders.json
  def index
    @lib_ptg_folders = LibPtgFolder.all
  end

  # GET /lib_ptg_folders/1
  # GET /lib_ptg_folders/1.json
  def show
  end

  # GET /lib_ptg_folders/new
  def new
    @lib_ptg_folder = LibPtgFolder.new
  end

  # GET /lib_ptg_folders/1/edit
  def edit
  end

  # POST /lib_ptg_folders
  # POST /lib_ptg_folders.json
  def create
    @lib_ptg_folder = LibPtgFolder.new(lib_ptg_folder_params)

    respond_to do |format|
      if @lib_ptg_folder.save
        format.html { redirect_to @lib_ptg_folder, notice: 'Lib ptg folder was successfully created.' }
        format.json { render :show, status: :created, location: @lib_ptg_folder }
      else
        format.html { render :new }
        format.json { render json: @lib_ptg_folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lib_ptg_folders/1
  # PATCH/PUT /lib_ptg_folders/1.json
  def update
    respond_to do |format|
      if @lib_ptg_folder.update(lib_ptg_folder_params)
        format.html { redirect_to @lib_ptg_folder, notice: 'Lib ptg folder was successfully updated.' }
        format.json { render :show, status: :ok, location: @lib_ptg_folder }
      else
        format.html { render :edit }
        format.json { render json: @lib_ptg_folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lib_ptg_folders/1
  # DELETE /lib_ptg_folders/1.json
  def destroy
    @lib_ptg_folder.destroy
    respond_to do |format|
      format.html { redirect_to lib_ptg_folders_url, notice: 'Lib ptg folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lib_ptg_folder
      @lib_ptg_folder = LibPtgFolder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lib_ptg_folder_params
      params.require(:lib_ptg_folder).permit(:name, :flavor, :month, :update)
    end
end
