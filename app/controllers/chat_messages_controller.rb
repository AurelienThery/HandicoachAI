class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = current_user.chat_messages.where(routine_id: nil).ordered
  end

  def create
    @message = current_user.chat_messages.build(message_params)
    @message.role = "user"

    if @message.save
      # Get AI response asynchronously
      AiResponseJob.perform_later(@message.id)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_messages_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "chat_messages/form") }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:chat_message).permit(:content, :routine_id)
  end
end
