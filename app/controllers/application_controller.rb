class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :user_signed_in? #일부 메소드들을 뷰파일에서도 사용하기 위한 방법
  
  # 현재 로그인 된 상태니?
  def user_signed_in?
       #!session[:current_user].nil?#비어있으면 로그인된 상태가 아님  
      session[:current_user].present?
  end
  
   # 로그인 되어있지 않으면 로그인하는 페이지로 이동시켜줘
   # !가붙은 메소드 - 원형을 변경시킬 수 있는 메소드들 (뱅?)
   def authenticate_user!
      unless user_signed_in?
          redirect_to '/sign_in'
      end 
   end
  
  # 현재 로그인 된 사람이 누구니?
  def current_user
      if user_signed_in?
          # 되었다면 로그인 한 사람은 누구??
          @current_user = User.find(session[:current_user])
      end
  end
end
