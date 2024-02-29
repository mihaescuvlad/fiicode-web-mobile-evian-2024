class AdminApplicationController < ApplicationController
  layout 'admin_application'

  def ensure_privileges!
    unless current_user.administrator?
      render html: '<h1 class="text-lg">Access Denied</h1>'.html_safe, layout: 'admin_application', status: :unauthorized and return
    end
  end
end