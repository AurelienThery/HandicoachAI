class RoutinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_routine, only: [:show, :edit, :update, :destroy, :share, :unshare]
  before_action :authorize_routine, only: [:edit, :update, :destroy]

  def index
    @routines = current_user.accessible_routines
    @own_routines = current_user.routines
    @shared_routines = current_user.shared_routines
  end

  def show
    @chat_messages = @routine.chat_messages.ordered
  end

  def new
    @routine = current_user.routines.build
    @routine.visibility = "private"
  end

  def create
    @routine = current_user.routines.build(routine_params)
    @routine.visibility ||= "private"

    if @routine.save
      redirect_to @routine, notice: "Routine créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @routine.update(routine_params)
      redirect_to @routine, notice: "Routine mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy
    redirect_to routines_path, notice: "Routine supprimée."
  end

  # Share routine with another user
  def share
    user_email = params[:email]
    user_to_share = User.find_by(email: user_email)

    if user_to_share && user_to_share != current_user
      @routine.share_with(user_to_share)
      redirect_to @routine, notice: "Routine partagée avec #{user_email}."
    else
      redirect_to @routine, alert: "Utilisateur non trouvé ou invalide."
    end
  end

  def unshare
    user_id = params[:user_id]
    user_to_unshare = User.find_by(id: user_id)

    if user_to_unshare
      @routine.unshare_with(user_to_unshare)
      redirect_to @routine, notice: "Partage supprimé."
    else
      redirect_to @routine, alert: "Utilisateur non trouvé."
    end
  end

  private

  def set_routine
    @routine = Routine.find(params[:id])
    unless @routine.shared_with_user?(current_user.id) || @routine.user_id == current_user.id
      redirect_to routines_path, alert: "Accès non autorisé."
    end
  end

  def authorize_routine
    unless @routine.user_id == current_user.id
      redirect_to routines_path, alert: "Action non autorisée."
    end
  end

  def routine_params
    params.require(:routine).permit(:title, :description, :visibility, steps: [])
  end
end
