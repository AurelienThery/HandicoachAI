class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params[:routine_id]
      # Subscribe to routine-specific chat
      routine = Routine.find(params[:routine_id])
      if routine.shared_with_user?(current_user.id) || routine.user_id == current_user.id
        stream_from "chat_#{routine.id}"
      else
        reject
      end
    else
      # Subscribe to user's personal chat
      stream_from "chat_#{current_user.id}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
