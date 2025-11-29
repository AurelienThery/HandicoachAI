class AiResponseJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = ChatMessage.find(message_id)
    user = message.user
    routine = message.routine

    # Build conversation context
    messages = build_conversation_context(message)

    # Get AI response
    response = AiService.chat(messages, user: user)

    # Create AI response message
    ai_message = ChatMessage.create!(
      content: response[:content],
      role: "assistant",
      user: user,
      routine: routine
    )

    # Broadcast the AI response
    broadcast_target = "chat_#{routine&.id || user.id}"
    Turbo::StreamsChannel.broadcast_append_to(
      broadcast_target,
      target: "messages",
      partial: "chat_messages/message",
      locals: { message: ai_message }
    )
  end

  private

  def build_conversation_context(current_message)
    # Get recent messages from the same context (routine or user)
    if current_message.routine
      recent_messages = current_message.routine.chat_messages.ordered.last(10)
    else
      recent_messages = current_message.user.chat_messages.where(routine_id: nil).ordered.last(10)
    end

    recent_messages.map do |msg|
      { role: msg.role, content: msg.content }
    end
  end
end
