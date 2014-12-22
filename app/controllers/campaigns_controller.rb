class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:edit, :update]
  before_action :load_variables
  before_filter :ensure_authentication

  def new
    @campaign = Campaign.new
  end

  def edit
  end

  def create
    @campaign = Campaign.new(campaign_params.merge(status: Constants::STATUS[:SALA1]))
    @campaign.set_variables(params[:campaign][:variable_list])

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to root_path({ status: 'campaign', notice: "#{Campaign.model_name.human.capitalize} criada com sucesso" }) }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    status = params[:update_status] ? { status: params[:update_status] } : {}

    if params[:campaign][:variable_list]
      @campaign.variables.delete_all
      @campaign.set_variables(params[:campaign][:variable_list])
    end

    respond_to do |format|
      if @campaign.update(campaign_params.merge(status))
        format.html { redirect_to root_path({ status: 'campaign', notice: "#{Campaign.model_name.human.capitalize} atualizada com sucesso" }) }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_variables
    @variables = Variable.order(:name)
  end

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :ident,
      :name,
      :priority,
      :created_in_sprint,
      :updated_in_sprint,
      :campaign_origin,
      :channel,
      :communication_channel,
      :product,
      :criterion,
      :exists_in_legacy,
      :automatic_routine,
      :factory_criterion_status,
      :process_type,
      :crm_room_suggestion,
      :it_status,
      :notes,
      :owner,
      :status).merge(current_user_id: current_user.id)
  end
end
