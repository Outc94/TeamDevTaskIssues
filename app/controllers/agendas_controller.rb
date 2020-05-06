class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end

  def destroy
   @agenda = Agenda.find(params[:id])
   destroy_agenda = @agenda
   if @agenda.present?
      @agenda.destroy
      team_id = destroy_agenda.team_id
      team_members = User.where(keep_team_id: team_id)
      team_members.each do |member|
        TeamMailer.mail_users(member).deliver
      end
      redirect_to dashboard_url,  notice: "The agenda is successfully destroyed and mails are sent to the users"
   end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
