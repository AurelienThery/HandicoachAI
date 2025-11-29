module Routines
  class ChatMessagesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_routine

    def index
      @messages = @routine.chat_messages.ordered
    end

    def create
      @message = @routine.chat_messages.build(message_params)
      @message.user = current_user
      @message.role = "user"

      if @message.save
        # Get AI response asynchronously
        AiResponseJob.perform_later(@message.id)

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to routine_path(@routine) }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "chat_messages/form") }
          format.html { render :index, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_routine
      @routine = Routine.find(params[:routine_id])
      unless @routine.shared_with_user?(current_user.id) || @routine.user_id == current_user.id
        redirect_to routines_path, alert: "Accès non autorisé."
      end
    end

    def message_params
      params.require(:chat_message).permit(:content)
    end
  end
end
