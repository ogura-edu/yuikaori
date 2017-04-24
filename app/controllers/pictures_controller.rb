class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update]
  before_action :approved_user!, only: [:tmp, :destroy_index, :request_destroy]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @pictures = Picture.where("tmp IS true AND removed IS false").order('date DESC').page(params[:page]).per(50)
  end
  
  def search
    #columnの値によって処理を分岐
    case params[:column]
    when 'date'
      selected = Picture.selected_by_date(search_params)
    when 'member'
      selected = Picture.selected_by_member(search_params)
    when 'event'
      selected = Picture.selected_by_event(search_params)
    when 'tag'
      selected = Picture.selected_by_tag(search_params)
    when 'media'
      selected = Picture.selected_by_media(search_params)
    end
    @pictures = selected.order('date DESC').page(params[:page]).per(50)
  end
  
  def destroy_index
    index
  end
  
  def request_destroy
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
  
  def update
    if @picture.update(picture_params)
      respond_to do |format|
        flash[:notice] = '更新完了しました'
        format.js {render 'show'}
      end
    else
      respond_to do |format|
        flash[:notice] = '更新に失敗しました。'
        format.js {render 'edit'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:picture).permit(:since, :until, :member, :event, :tag, :media)
    end
    
    def picture_params
      params.require(:picture).permit(:member_id, :event_id, :date, :article_url, event_attributes: [:event], tags_attributes: [:tag], tag_ids: [])
    end
end
