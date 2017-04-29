class MediaContentsController < ApplicationController
  before_action :set_media_content, only: [:show, :edit, :update]
  before_action :approved_user!, only: [:tmp, :deletion_request, :destroy]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @media_contents = MediaContent.temporary.desc_order.paginate(params[:page])
  end
  
  def multiple
    if params[:remove] && MediaContent.remove(params[:media_content_ids])
      redirect_back fallback_location: tmp_media_contents_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:show] && MediaContent.where(id: params[:media_content_ids]).update_all(tmp: false)
      redirect_back fallback_location: tmp_media_contents_path, notice: '一覧に表示します'
    else
      redirect_back fallback_location: tmp_media_contents_path, alert: '更新に失敗しました'
    end
  end
  
  def search
    @media_contents = MediaContent.send("selected_by_#{params[:column]}", search_params).desc_order.paginate(params[:page])
  end
  
  def deletion_request
    @media_contents = MediaContent.allowed.desc_order.paginate(params[:page])
  end
  
  def hide
    if MediaContent.where(id: params[:media_content_ids]).update_all(tmp: true)
      redirect_to media_contents_path, notice: '削除申請を受け付けました'
    else
      redirect_back fallback_location: media_contents_path, alert: '削除申請に失敗しました'
    end
  end

  def index
    @media_contents = MediaContent.allowed.desc_order.paginate(params[:page])
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
      @media_content = MediaContent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:media_content).permit(:since, :until, :member, :event, :tag, :media)
    end
    
    def media_content_params
      params.require(:media_content).permit(:member_id, :event_id, :tag_list, :date, :article_url, event_attributes: [:name])
    end
end
