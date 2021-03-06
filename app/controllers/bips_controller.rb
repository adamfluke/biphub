class BipsController < ApplicationController
  def new
    @school = School.find_by_id params[:school_id]
    @student = Student.find_by_id params[:student_id]
    @bip = Bip.new
  end

  def create
    school = School.find_by_id params[:school_id]
    student = Student.find_by_id params[:student_id]
    bip = Bip.new bip_params
    student.bips << bip
    if bip.save
      redirect_to school_student_path school, student
    else
      redirect_to new_school_student_bip_path school, student
    end
  end

  def show
    @user = current_user
    @school = School.find(params[:school_id])
    @student = Student.find_by_id params[:student_id]
    @bip = Bip.find_by_id params[:id]
    @goals = @bip.goals
  end

  def edit
    @bip = Bip.find_by_id params[:id]
    @student = @bip.student
    @school = @student.school
  end

  def update
    @school = School.find(params[:school_id])
    @student = Student.find_by_id params[:student_id]
    @bip = Bip.find_by_id params[:id]
    @bip.update_attributes(bip_params)
    redirect_to school_student_path @school, @student
  end

  def destroy
    @school = School.find_by_id params[:school_id]
    @student = Student.find_by_id params[:student_id]
    @bip = Bip.find_by_id params[:id]
    @bip.destroy
    redirect_to school_student_path @school, @student
  end

private
  def bip_params
    params.require(:bip).permit(:start, :finish)
  end
end
