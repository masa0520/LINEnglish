class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy set_time update_time]
  before_action :set_search, only: %I[ index my_posts ]

  # GET /posts
  def index
    @posts = @q.result.order(created_at: :desc).page(params[:page])
  end

  # GET /posts/1
  def show
    @word_meanings = WordMeaning.where(post_id: @post.id)
    @words = Word.where(post_id: @post.id)
    @meanings = Meaning.where(post_id: @post.id)
  end

  # GET /posts/new
  def new
    @post = Post.new
    @word = Word.new
    @meaning = Meaning.new
  end

  # GET /posts/1/edit
  def edit
    @word_meanings = WordMeaning.where(post_id: @post.id)
    @words = Word.where(post_id: @post.id)
    @meanings = Meaning.where(post_id: @post.id)
  end

  # POST /posts
  def create
    @post = current_user.posts.build(post_params)
    if @post.title.present?
      Post::WORDS_AND_MEANINGS.times do |i|
        input_word = params[:name][i.to_s].split(/[[:space:]]/) if params[:name][i.to_s].present?
        input_meaning = params[:description][i.to_s].split(/[[:space:]]/) if params[:description][i.to_s].present?
        if input_word.present? && input_meaning.present? && !(input_word.length >= 2 && input_meaning.length >= 2)
         @post.save unless @post.persisted?
         input_word.each do |word|
           word = current_user.words.find_or_create_by(name: word, post_id: @post.id)
           input_meaning.each do |mean|
             mean = current_user.meanings.find_or_create_by(description: mean, post_id: @post.id)
             WordMeaning.find_or_create_by(word_id: word.id, meaning_id: mean.id, post_id: @post.id)
           end
          end
        end
      end
      if @post.persisted?
        redirect_to @post, notice: t('posts.create.success') if @post.persisted?
      else#この処理は@post.titleは存在するが他がnilの場合
        @post = Post.new
        @word = Word.new
        @meaning = Meaning.new
        flash.now[:alert] = t('posts.create.failure')
        render :new, status: :unprocessable_entity
      end
    else
      @post = Post.new
      @word = Word.new
      @meaning = Meaning.new
      flash.now[:alert] = t('posts.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    # 既存の単語をすべて削除
    @post.word_meanings.destroy_all
    @post.words.destroy_all
    @post.meanings.destroy_all
    if @post.title.present?
      Post::WORDS_AND_MEANINGS.times do |i|
        input_word = params[:name][i.to_s].split(/[[:space:]]/) if params[:name][i.to_s].present?
        input_meaning = params[:description][i.to_s].split(/[[:space:]]/) if params[:description][i.to_s].present?
        if input_word.present? && input_meaning.present? && !(input_word.length >= 2 && input_meaning.length >= 2)
          @post.update(post_params) unless @post.changed?
          input_word.each do |word|
            word = current_user.words.find_or_create_by(name: word, post_id: @post.id)
            input_meaning.each do |mean|
              mean = current_user.meanings.find_or_create_by(description: mean, post_id: @post.id)
              WordMeaning.find_or_create_by(word_id: word.id, meaning_id: mean.id, post_id: @post.id)
            end
          end
        end
      end
      if @post.persisted?
        redirect_to @post, notice: t('posts.update.success') if @post.persisted?
      else#この処理は@post.titleは存在するが他がnilの場合
        @post = Post.new
        @word = Word.new
        @meaning = Meaning.new
        flash.now[:alert] = t('posts.update.failure')
        render :new, status: :unprocessable_entity
      end
    else
      @post = Post.new
      @word = Word.new
      @meaning = Meaning.new
      flash.now[:alert] = t('posts.update.failure')
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to posts_url, notice: t('posts.destroy.success')
  end

  def my_posts
    @my_posts = @q.result.where(user_id: current_user.id).order(created_at: :desc).page(params[:page])
  end

  def bookmarks
    @q = current_user.bookmark_posts.ransack(params[:q])
    @bookmark_posts = @q.result.order(created_at: :desc).page(params[:page])
  end

  def line_relations
    @q = current_user.line_relations.ransack(params[:q])
    @line_relations = @q.result.order(created_at: :desc).page(params[:page])
  end

  def set_time
    @line_post = current_user.line_posts.find_by(post_id: @post)
  end

  def update_time
    @line_post = current_user.line_posts.find_by(post_id: @post)
    if @line_post.update(line_post_params)
      redirect_to @post, notice: 'ライン通知の時間を設定しました'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :user_id, :genre_id)
    end

    def line_post_params
      params.require(:line_post).permit(:set_time)
    end

    def set_search
      @q = Post.ransack(params[:q])
    end
end
