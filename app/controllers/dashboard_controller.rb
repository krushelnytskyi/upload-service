class DashboardController < ApplicationController

	def index
		if !user_signed_in?
			redirect_to new_user_session_path
		else 
      @companies = Company.search(params[:search]).order(created_at: :desc).paginate(page: params[:page], per_page: 20)
      @year_range = Company.year_range(5)
    end
	end

end