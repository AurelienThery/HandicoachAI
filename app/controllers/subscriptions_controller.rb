class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:pricing]

  def index
    @current_plan = current_user.subscription_plan
    @subscription_active = current_user.subscription_active?
  end

  def pricing
    # Public pricing page
  end

  def upgrade
    # Handle upgrade to pro plan
    # In a real app, this would integrate with Stripe/PayPal
    if params[:plan] == "pro"
      current_user.update(
        subscription_plan: "pro",
        subscription_expires_at: 1.month.from_now
      )
      redirect_to subscriptions_path, notice: "Félicitations ! Vous êtes maintenant sur le plan Pro."
    else
      redirect_to subscriptions_path, alert: "Plan invalide."
    end
  end
end
