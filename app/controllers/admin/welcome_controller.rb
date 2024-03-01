# frozen_string_literal: true
class Admin::WelcomeController < AdminApplicationController
  before_action :authenticate_user!

  def index
  end
end
