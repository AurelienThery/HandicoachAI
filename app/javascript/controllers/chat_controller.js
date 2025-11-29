import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = {
    routineId: Number,
    userId: Number
  }

  connect() {
    this.scrollToBottom()
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    const consumer = createConsumer()
    const channelId = this.routineIdValue || this.userIdValue
    
    this.subscription = consumer.subscriptions.create(
      { channel: "ChatChannel", routine_id: this.routineIdValue || null },
      {
        received: (data) => {
          this.scrollToBottom()
        }
      }
    )
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
