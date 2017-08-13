class CompanyController < ApplicationController

  def new
    @company = Company.new
  end

  def create
    @company = current_user.companies.create(company_params)

    if @company.save
      redirect_to @company
    else
      flash[:error] = 'Can not save company'
      redirect_back fallback_location: new_company_path
    end 
  end

  def destroy

    if current_user.role != 'super_admin'
      flash[:error] = 'You don\'t have permissions to do this operation'
    else
      company = Company.find(params[:id])
      company.destroy
      flash[:info] = "Company #{company.name} successfully deleted"
    end

    redirect_to root_path

  end

  def show
    @company = Company.find(params[:id])
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

end