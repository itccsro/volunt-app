class CommunicationsController < ApplicationController
  include LoginConcern
  authorization_required
  before_action :set_communication, only: [:show, :edit, :update, :destroy]

  # GET /communications
  def index
    @communications = Communication.all.paginate(page: params[:page])
  end

  # GET /communications/1
  def show
  end

  # GET /communications/new
  def new
    @communication = Communication.new
  end

  # GET /communications/1/edit
  def edit
  end

  # POST /communications
  def create
    @communication = Communication.new(communication_params)

    if @communication.save
      redirect_to @communication, notice: 'Communication was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /communications/1
  def update
    if @communication.update(communication_params)
      redirect_to @communication, notice: 'Communication was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /communications/1
  def destroy
    @communication.destroy
    redirect_to communications_url, notice: 'Communication was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_communication
      @communication = Communication.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def communication_params
      params.require(:communication).permit(:name, :description, :template_id, :body, :status, :scheduled_time)
    end
end
