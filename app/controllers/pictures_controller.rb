class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  def tmp
    @pictures = Picture.where("tmp IS true AND removed IS false").order('date DESC').page(params[:page]).per(50)
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
      Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = true")
      redirect_back fallback_location: pictures_path, notice: '削除申請を受け付けました'
    elsif params[:destroy]
      #削除処理
      params[:pictures].each do |id|
        picture = Picture.find(id)
        picture.update(removed: true)
        File.delete("#{Settings.media.root}#{picture.address}")
      end
      redirect_back fallback_location: pictures_tmp_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:permit]
      Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = false")
      redirect_back fallback_location: pictures_tmp_path, notice: '一覧に表示します'
    end
  end
  
  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.where("tmp IS false AND removed IS false").order('date DESC').page(params[:page]).per(50)
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/1/edit
  def edit
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:member_id, :address, :event_id, :date, :tmp, :removed, :tag_ids => [])
    end
end
