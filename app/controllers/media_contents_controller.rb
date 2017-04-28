class MediaContentsController < ApplicationController
  before_action :set_media_content, only: [:show, :edit, :update]
  before_action :approved_user!, only: [:tmp, :destroy_index, :request_destroy]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @media_contents = MediaContent.temporary.desc_order.pagenate(params[:page])
  end
  
  def search
    column = params[:column]
    selected_pictures = Picture.send("selected_by_#{column}", search_params)
    selected_videos = Video.send("selected_by_#{column}", search_params)
    selected = [selected_pictures, selected_videos].flatten
    @media_contents = selected.order('date DESC').page(params[:page]).per(50)
  end
  
  def destroy_index
    @media_contents = MediaContent.allowed.desc_order.pagenate(params[:page])
  end
  
  def request_destroy
    if Picture.where(id: params[:picture_ids]).update_all(tmp: true) && Video.where(id: params[:video_ids]).update_all(tmp: true)
      redirect_back fallback_location: media_contents_path, notice: '削除申請を受け付けました'
    else
      redirect_back fallback_location: media_contents_path, alert: '削除申請に失敗しました'
    end
  end
  
  def multiple
    if params[:destroy] && Picture.remove(params[:picture_ids]) && Video.remove(params[:video_ids])
      redirect_back fallback_location: tmp_media_contents_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:permit] && Picture.where(id: params[:picture_ids]).update_all(tmp: false) && Video.where(id: params[:video_ids]).update_all(tmp: false)
      redirect_back fallback_location: tmp_media_contents_path, notice: '一覧に表示します'
    else
      redirect_back fallback_location: tmp_media_contents_path, alert: '更新に失敗しました'
    end
  end

  def index
    @media_contents = MediaContent.allowed.order('date DESC').page(params[:page]).per(50)
  end

  def show
  end

  def edit
  end
  
  def update
    if @media_content.update(media_content_params)
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
    def set_media_content
      if picture?
        @media_content = 
      elsif video?
        @media_content = 
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:media_content).permit(:since, :until, :member, :event, :tag, :media)
    end
    
    def media_content_params
      params.require(:media_content).permit(:member_id, :event_id, :tag_list, :date, :article_url, event_attributes: [:name])
    end
end
