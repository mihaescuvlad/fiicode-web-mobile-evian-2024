# frozen_string_literal: true
class Admin::GreetController < AdminApplicationController
  before_action :authenticate_user!, :ensure_privileges!

  def index
  end
end
