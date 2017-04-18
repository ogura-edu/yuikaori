class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit]
  before_action :approved_user!, only: [:tmp, :destroy_index, :request]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @pictures = Picture.where("tmp IS true AND removed IS false").order('date DESC').page(params[:page]).per(50)
  end
  
  def search
    #columnの値によって処理を分岐
    case params[:column]
    when 'date'
      # since, untilの値から検索
      selected = Picture.where('date >= ? AND date <= ? AND tmp IS false AND removed IS false', params[:since], params[:until])
    when 'event'
      # 正規表現を使って検索
      event_ids = Event.where('event LIKE ?', "%#{params[:value]}%")[:id]
      selected = Picture.where('event_id IN ? AND tmp IS false AND removed IS false', event_ids)
    when 'tag'
      # 正規表現を使って検索
      tag_ids = Tag.where('tag LIKE ?', "%#{params[:value]}%")[:id]
      selected = Picture.where('tag_id IN ? AND tmp IS false AND removed IS false', tag_ids)
    when 'member_id'
      # valueの値から一致するものを検索
      selected = Picture.where('member_id = ? AND tmp IS false AND removed IS false', params[:value])
    when 'media'
      # 正規表現を使って検索
      selected = Picture.where('address LIKE ? AND tmp IS false AND removed IS false', "%#{params[:value]}%")
    end
    @pictures = selected.order('date DESC').page(params[:page]).per(50)
  end
  
  def destroy_index
    index
  end
  
  def request
    Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = true")
    redirect_back fallback_location: pictures_path, notice: '削除申請を受け付けました'
  end
  
  def multiple
    #submitボタンのname属性によって処理を分岐
    if params[:destroy]
      #削除処理
      params[:pictures].each do |id|
        picture = Picture.find(id)
        picture.update(removed: true)
        S3_BUCKET.object(picture.s3_address).delete
      end
      redirect_back fallback_location: tmp_pictures_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:permit]
      #表示処理
      Picture.where("id IN (#{params[:pictures].join(',')})").update_all("tmp = false")
      redirect_back fallback_location: tmp_pictures_path, notice: '一覧に表示します'
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
