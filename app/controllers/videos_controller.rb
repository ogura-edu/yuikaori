class VideosController < ApplicationController
  before_action :set_all_videos, only: [:index, :destroy_index]
  before_action :set_video, only: [:show, :edit, :update]
  before_action :approved_user!, only: [:tmp, :destroy_index, :request_destroy]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @videos = Video.temporary.order('date DESC').page(params[:page]).per(50)
  end

  def search
    column = params[:column]
    selected = Video.send("selected_by_#{column}", search_params)
    @videos = selected.order('date DESC').page(params[:page]).per(50)
  end

  def destroy_index
  end

  def request_destroy
    Video.where(id: params[:video_ids]).update_all(tmp: true)
    redirect_back fallback_location: videos_path, notice: '削除申請を受け付けました'
  end

  def multiple
    #submitボタンのname属性によって処理を分岐
    if params[:destroy]
      #削除処理
      Video.remove(params[:video_ids])
      redirect_back fallback_location: tmp_videos_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:permit]
      #表示処理
      Video.where(id: params[:video_ids]).update_all(tmp: false)
      redirect_back fallback_location: tmp_videos_path, notice: '一覧に表示します'
    end
  end

  def index
  end

  def show
  end

  def edit
  end
  
  def update
    if @video.update(video_params)
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
    def set_all_videos
      @videos = Video.allowed.order('date DESC').page(params[:page]).per(50)
    end
    
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:video).permit(:since, :until, :member, :event, :tag, :media)
    end

    def video_params
      params.require(:video).permit(:member_id, :event_id, :tag_list, :date, :article_url, event_attributes: [:name])
    end
end
