class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list ,:credit]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #UserMailer.password_reset.deliver_now
    #-------QiaoCode--------
    #所有可以选择的课程
    @course=Course.where(:open=>true)
    #除去已经选过的课程，留下将要选择的可选的课程
    @course=@course-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end

  ############### 添加下载 ###################
  def downloadcsv
    @course = current_user.courses.order(:course_code)
    respond_to do |format|
      format.html
      format.csv {send_data @course.to_csv}
      #format.xls {send_data @course.to_csv(col_sep: "\t") }
    end
  end
  ############# 添加下载结束 ####################

  def select
    @course=Course.find_by_id(params[:id])
    #处理冲突信息
    tmp=[]
    current_user.courses.each do |course|
      #判断当前所有的课程是否和新加入的课程时间上存在冲突
      if @course.course_time==course.course_time
        tmp<<course.name
      end
    end
    if tmp.size==0
      current_user.courses<<@course
      flash={:success => "成功选择课程: #{@course.name},上课时间：#{@course.course_time}"}
    else
      flash={:fail=> "选课不成功：#{@course.name}的上课时间和#{tmp}课程时间冲突"}
    end
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  ######################
  def credit
      @course=current_user.teaching_courses if teacher_logged_in?
      @course=current_user.courses if student_logged_in?
      tmp = []
      @course.each do |course|
        @current_user.grades.each do |grade|
          if grade.course_id == course.id && grade.grade != nil
            tmp <<course
          end
        end
      end
      @course = @course - tmp
  end

  def evaluate
      @grades=Grade.find_by_id(params[:id])
      if student_logged_in?

      else
        redirect_to root_path, flash: {:warning=>"请先登陆"}
      end

  end
  #######################

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
