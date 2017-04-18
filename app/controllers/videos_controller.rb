class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit]
  before_action :approved_user!, only: [:tmp, :destroy_index, :request_destroy]
  before_action :admin_user!, only: [:multiple]

  def tmp
    @videos = Video.where('tmp IS true AND removed IS false').order('date DESC').page(params[:page]).per(50)
  end

  def search
    #columnの値によって処理を分岐
    case params[:column]
    when 'date'
      # since, untilの値から検索
      selected = Video.where('date >= ? AND date <= ? AND tmp IS false AND removed IS false', params[:since], params[:until])
    when 'event'
      # 正規表現を使って検索
      event_ids = Event.where('event LIKE ?', "%#{params[:value]}%")[:id]
      selected = Video.where('event_id IN ? AND tmp IS false AND removed IS false', event_ids)
    when 'tag'
      # 正規表現を使って検索
      tag_ids = Tag.where('tag LIKE ?', "%#{params[:value]}%")[:id]
      selected = Video.where('tag_id IN ? AND tmp IS false AND removed IS false', tag_ids)
    when 'member_id'
      # valueの値から一致するものを検索
      selected = Video.where('member_id = ? AND tmp IS false AND removed IS false', params[:value])
    when 'media'
      # 正規表現を使って検索
      selected = Video.where('address LIKE ? AND tmp IS false AND removed IS false', "%#{params[:value]}%")
    end
    @videos = selected.order('date DESC').page(params[:page]).per(50)
  end

  def destroy_index
    index
  end

  def request_destroy
    Video.where("id IN (#{params[:video].join(',')})").update_all("tmp = true")
    redirect_back fallback_location: videos_path, notice: '削除申請を受け付けました'
  end

  def multiple
    #submitボタンのname属性によって処理を分岐
    if params[:destroy]
      #削除処理
      params[:videos].each do |id|
        video = Video.find(id)
        video.update(removed: true)
        S3_BUCKET.object(video.s3_address).delete
        S3_BUCKET.object(video.s3_ss_address).delete
      end
      redirect_back fallback_location: tmp_videos_path, notice: 'データベース及びストレージからの削除完了しました'
    elsif params[:permit]
      Video.where("id IN (#{params[:videos].join(',')})").update_all("tmp = false")
      redirect_back fallback_location: tmp_videos_path, notice: '一覧に表示します'
    end
  end

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.where('tmp IS false AND removed IS false').order('date DESC').page(params[:page]).per(50)
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/1/edit
  def edit
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:member_id, :event_id, :address, :date, :tmp, :removed, tag_ids: [])
    end
end
