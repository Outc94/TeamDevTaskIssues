class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy give_authority]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def give_authority
   if current_user.id == @working_team.owner_id
      assign = Assign.find(params[:assign])
      if @working_team.update(owner_id: assign.user.id)
          TeamOwnerMailer.mail_new_owner(assign.user.email).deliver
          redirect_back(fallback_location: team_path(@working_team))
     else
       redirect_to team_path(@working_team.id), notice: I18n.t('views.messages.failed_to_transfer_authority')
     end
   else
     redirect_to team_path(@working_team.id), notice: I18n.t('views.messages.failed_to_transfer_authority')
   end
 end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
