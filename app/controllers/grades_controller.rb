class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]
  before_action :student_logged_in, only: [:evaluate, :update_sec]

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end



#################
    def update_sec
      #debugger
      #flash={:info => "更新成功"}
      @grade=Grade.find_by_id(params[:id])
      if @grade.update_attributes(evaluate_params)
        flash={:info => "更新成功"}
      else
        flash={:warning => "更新失败"}
      end
      redirect_to evaluate_grades_path
      #redirect_to evaluate_courses_path, flash: flash
    end

    def evaluate
      if teacher_logged_in?
        @course=Course.find_by_id(params[:course_id])
        @grades=@course.grades
      elsif student_logged_in?
        @grades=current_user.grades
      else
        redirect_to root_path, flash: {:warning=>"请先登陆"}
      end
    end

    def show_eva
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
      if student_logged_in?


      else
        redirect_to root_path, flash: {:warning=>"请先登陆"}
      end
    end

#################


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
  def student_logged_in
     unless student_logged_in?
       redirect_to root_url, flash: {danger: '请登陆'}
     end
   end

   def  evaluate_params
     params.require(:grade).permit(:evaluate_score, :class_score, :homework_score, :difficulty_score, :harvest_score)

   end

end
