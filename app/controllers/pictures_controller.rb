class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  def tmp
    @pictures = Picture.where("tmp = 't'").order('date DESC').page(params[:page]).per(50)
  end
  
  def search
    column = params[:column]
    value = params[:value]
    selected = Picture.where("#{column} = #{value} AND tmp = 'f'")
    @pictures = selected.order('date DESC').page(params[:page]).per(50)
  end
  
  def destroy_index
    index
  end
  
  def multiple
    #submitボタンのname属性によって処理を分岐
    if params[:request]
      Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = 't'")
    elsif params[:destroy]
      puts "DESTROY"
#      削除処理
#      picturesテーブルから削除＆removed_addressesテーブルに格納＆元画像削除を書く必要あり。
#      params[:pictures].each do |id|
#        @picture = Picture.find(id)
#        @picture.destroy
#        File.delete("app/assets/images/#{@picture.address}")
#      end
#      respond_to do |format|
#        format.html { redirect_back fallback_location: pictures_path, notice: 'Picture was successfully destroyed.' }
#        format.json { head :no_content }
#      end
    elsif params[:permit]
      Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = 'f'")
    end
  end
  
  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.where("tmp = 'f'").order('date DESC').page(params[:page]).per(50)
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)

    respond_to do |format|
      if @picture.save
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to pictures_path(page: params[:page]), notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    # delete from database
    @picture.destroy
    # delete picture from directory
    File.delete("app/assets/images/#{@picture.address}")
    respond_to do |format|
      format.html { redirect_back fallback_location: pictures_path, notice: 'Picture was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:member_id, :address, :event_id, :date, :tmp, :tag_ids => [])
    end
end
