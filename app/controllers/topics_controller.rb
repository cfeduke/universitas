class TopicsController < InheritedResources::Base
	respond_to :html, :js
	before_filter :load_presenter
	before_filter :authenticate_user!, :allow_members_only, :except => [:index, :show]
	belongs_to :forum
	
	def create
		@topic = parent.topics.build(:title => params[:topic][:title])
		if @topic.save && @topic.create_post(params[:topic][:post].merge(:author => current_user))
			flash[:notice] = t('topics.created')
			redirect_to group_forum_topic_path(parent.group, parent, @topic)
		else
			render :new
		end
	end
	
	def update
		resource.title = params[:title]
		if resource.valid?
			resource.save
		else
			resource.reload
		end
	end
	
	def show
		@posts = resource.posts
		super
	end
	
	def destroy
		destroy!{group_forum_path(@forum.group, @forum)}
	end
	
  private

	def allow_members_only
		unless current_user.member_of?(parent.group)
			flash[:error] = t('forums.not_allowed')
			redirect_to group_path(parent.group)
		end
	end

	def load_presenter
		@presenter = TopicsPresenter.new(current_user, parent.group)
	end

	def set_breadcrumbs
		add_breadcrumb(parent.group.name.truncate(50), group_path(parent.group))
		add_breadcrumb(I18n.t("forums.all"), group_forums_path(parent.group))
		add_breadcrumb(parent.title.truncate(50), group_forum_path(parent.group, parent))
		add_breadcrumb(resource.title.truncate(50), group_forum_topic_path(parent.group, parent, resource)) if params[:id]
	end
end
