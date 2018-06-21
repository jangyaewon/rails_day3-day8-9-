# 20180620_Day9

#### 오전 퀴즈

- MVC 패턴에서 각각의 역할을 단어로 정의하기

### 다음 카페 만들기

- Session(Login)



### 간단과제

- BoardController는 완성했음
- User 모델과 UserController CRUD
  - columns: user_id, password, ip_address
  - show에서는 user_id와 ip_address만 보이게(pw제외)
  - delete는 없음
  - /user/new -> /sign_up
- Cafe 모델과 CafeController CRUD
  - columns: title, description
- View 까지!!!!
  - bootstrap4



### 기존과 같다! 그리고 다르다!

- 기존의 코드를 활용하여 model과 controller를 구성하는 코드는 동일하다. 이번 시간에는 route를 조금 더 RESTful 하게 바꿔보도록 하자.

*config/routes.rb*

```ruby
Rails.application.routes.draw do
    root 'board#index'
    get '/boards' => 'board#index' 
    get '/board/new' => 'board#new'
    get '/board/:id' => 'board#show'
    post '/boards' => 'board#create'
    get '/board/:id/edit' => 'board#edit'
    put '/board/:id' => 'board#update'
    patch '/board/:id' => 'board#update'
    delete '/board/:id' => 'board#destroy'
end
```

- 같은 url도 요청 방식에 따라 다른 action을 수행하게끔 할 수 있다. 현재까지 구현한 라우팅 중에 가장 RESTful한 형태이다. 
- 등록은 post, 수정은 put과 patch, 삭제는 delete, 조회는 get 방식으로 요청하게끔 라우팅을 구성하였다.
- 위와 같은 요청을 수행하기 위해서 일부 view 코드를 수정해야한다.

*app/views/board/edit*

```erb
<%= form_tag("/user/#{@user.id}", method: "PATCH") do %>
    <%= text_field_tag(:user_id, @user.user_id, readonly: true) %>
    <%= password_field_tag(:password) %>
    <%= submit_tag("가입하기") %>
<% end %>
```

- 수정의 경우 put과 patch 방식으로 요청을 받도록 되어 있는데 일부 브라우저에서 patch 방식을 지원하지 않는 경우가 있다. 위 코드로 작성된 html 코드는 다음과 같다.

```html
<form action="/board/2" accept-charset="UTF-8" method="post">
    <input name="utf8" type="hidden" value="✓">
    <input type="hidden" name="_method" value="patch">
    <input type="hidden" name="authenticity_token" value="tzziBXys6XXXVv6j/el+XNFK6uO8VbS0j75jtQWbV6k6DPD1pDq+N9QuLQjJz1myPudciv+wIThGU1uarbw1lA==">
    <input type="text" name="title" id="title" value="ㅁㄴㅇㄹ">
    <textarea name="contents" id="contents">ㅁㄴㅇㄹ</textarea>
    <input type="submit" name="commit" value="수정하기" data-disable-with="수정하기">
</form>
```

- 실제로 `form`태그의 method가 patch로 바뀌는 것이 아니라 다른 파라미터로 patch 방식이라고 넘어가게 된다.
- 삭제를 위한 delete의 요청 방식은 다음과 같이 구현할 수 있다.

```erb
<h2><%= @post.title %></h2>
<hr>
<p><%= @post.contents %></p>
<%= link_to "목록", "/" %>
<%= link_to "수정", "/board/#{@post.id}/edit" %>
<%= link_to "삭제", "/board/#{@post.id}", method: "delete" %>
```

- `link_to` 는 지난 시간에 배웠던 view helper 이다. 위와같이 작성하면 다음과 같은 html코드가 나온다.

```html
...
<h2>ㅁㄴㅇㄹ</h2>
<hr>
<p>ㅁㄴㅇㄹ</p>
<a href="/">목록</a>
<a href="/board/2/edit">수정</a>
<a rel="nofollow" data-method="delete" href="/board/2">삭제</a>
...
```

- `data-method="delete"`로 코드가 생성된 것을 확인할 수 있다. 여기에 속성을 추가하여 지난번 처럼 `confirm` 메시지를 띄울 수도 있다.



### Login

- session과 cookie의 가장 큰 차이는 저장되는 위치이다. cookie는 사용자의 브라우저에 저장된다. session은 서버에 저장되고 session-id를 브라우저(클라이언트)에 저장한다. 사용자가 접속할 때마다 독립적인 session이 만들어지고 해당 session에 여러 정보를 저장하여 사용할 수 있다. 해당 정보는 DB와는 달리 휘발성이다.
- 우리가 로그인한 정보는 이 session에 저장된다. session에 개발자가 정해둔 key에 사용자 정보를 저장하면 원할때 꺼내서 사용할 수 있다. session에 새로운 key와 value를 저장하는 방법은 해쉬를 사용하는 방식과 유사하다. `session[:user_id] = user.id`의 방식으로 저장할 수 있다.

*config/routes.rb*

```ruby
...
	get '/sign_in' => 'user#sign_in'
    post '/sign_in' => 'user#user_sign_in'
...
```

*app/controllers/user_controller.rb*

```ruby
...
  def sign_in
  end
  
  def login
    # 유저가 입력한 ID, PW를 바탕으로
    # 실제로 로그인이 이루어지는 곳
    id = params[:user_id]
    pw = params[:password]
    user = User.find_by_user_id(id)
    if !user.nil? and user.password.eql?(pw)
      # 해당 user_id로 가입한 유저가 있고, 패스워드도 일치하는 경우
      session[:current_user] = user.id
      flash[:success] = "로그인에 성공했습니다."
      redirect_to '/users'
    else
      # 가입한 user_id가 없거나, 패스워드가 틀린경우
      flash[:error] = "가입된 유저가 아니거나, 비밀번호가 틀립니다."
      redirect_to '/sign_in'
    end
  end
...
```

- 사용자가 가입시 입력한 사용자의 id로 (DB table의 id 아님) 테이블에서 검색하여 비밀번호가 맞는지 확인하고 모두 맞다면 session에 유저의 정보(DB table의 id)를 담는다. 이때 입력한 session의 key는 반드시 기억해야 한다.
- 기타 정보가 아닌 id를 담는 이유는 해당 컬럼은 기본적으로 인덱싱이 완료되어 있고 타 값 검증 없이 유일값이라는 것이 보장되기 때문이다.

*app/views/user/sign_in.html.erb*

```erb
<h1>로그인</h1>
<%= form_tag do %>
    <%= text_field_tag(:user_id) %>
    <%= password_field_tag(:password) %>
    <%= submit_tag("로그인") %>
<% end %>
```

- 로그인 하는 페이지는 다음과 같이 구성된다.



### Logout

- 로그인 된 상태와 로그인되지 않은 상태는 무엇으로 구분할까. 두 상태의 차이는 session에 우리가 설정한 유저에 대한 키와 값의 존재 여부이다. 우리가 `current_user`로 설정한 값이 존재 한다면 로그인 된 상태이고 반대로 존재하지 않는다면 로그인되지 않은 상태이다.
- 로그인 된 상태에서 로그인 되지 않은 상태로 만드는 것이 로그아웃이다. 로그인 된 상태에서 로그아웃 상태로 바꾸려면 session에 등록된 `current_user` 정보를 삭제하면 된다. 이를 위해 구현되어 있는 메소드가 `session.delete(:key)`이다.

*app/controllers/user_controller.rb*

```ruby
...
  def logout
    session.delete(:current_user)
    flash[:success] = "로그아웃에 성공했습니다."
    redirect_to '/users'
  end
...
```

- 세션에 있는 키를 삭제하면 로그아웃시킬 수 있다.
- 추가적으로 로그인 된 상태에서는 로그아웃 버튼을, 로그아웃된 상태에서는 로그인 버튼을 보여주기 위한 코드는 다음과 같다.

*app/views/user/index.html.erb*

```erb
<% if @current_user.nil? %>
    <!-- 로그인 되지 않은 상태 -->
    <%= link_to '로그인', '/sign_in' %>
<% else %>
    <!-- 로그인 된 상태 -->
    <p>현재 로그인된 유저: <%= @current_user.user_id %></p>
    <%= link_to '로그아웃', '/logout' %>
<% end %>
...
```

*app/controllers/user_controller.rb*

```ruby
...  
  def index
    @users = User.all
    @current_user = User.find(session[:current_user]) if session[:current_user]
  end
...
```

- `@current_user` 변수에 세션에 저장되어있는 table id 값으로 검색하여 유저 정보를 저장한다. 위와 같은 방식으로 현재 접속한 유저 정보를 확인하고 사용할 수 있다.
- 




20180621_ Day 10

검색

- 무언가 사용자 혹은 개발자가 원하는 데이터를 찾고자 할때
- 검색방법
  - 일치
  - 포함
  - 범위
  - ...
- 우리가 그동안에 검색했던 방법은 일치. Table에 있는 id와 일치하는 것. 이 컬럼은 인덱싱이 되어 있기 때문에 검색속도가 매우 빠르고 항상 고유한 값을 가진다.
  - Table에 있는 id로 검색을 할 때엔 Model.find(id)를 사용한다.
- Table에 있는 id값으로 해결하지 못하는 경우?
  - 사용자가 입력했던 값으로 검색해야하는 경우(user_name)
  - 게시글을 검색하는데 작성자, 제목으로 검색할 경우
    - find는 id 값으로면 찾을 수 있지만 다른 경우엔 사용할 수 없다.
  - Table에 있는 다른 컬럼으로 검색할 경우 Model.find_by_컬럼명(value),  Model.find_by(컬러명: value)
  - find_by의 특징은 1개만 검색 된다. 일치하는 값이 없는 경우 nil
    - 여러 값이 있더라도 제일 처음에 넣은 하나만 출력
    - Day 9에서도 사용 아마 user_Controller에서 인듯

    rails c
    u = User.find_by_user_id("xzcv")
    => nil
    u = User.find_by_user_id("hello")
    => hello의 값을 가진 객체가 나온다??

- 추가적인 겁색 방법 : Model.where(컬럼명: 검색어값)
  - User.where(user_name: "Hello")
  - where의 특징 : 검색결과가 여러개. 결과값이 배열형태. 일치하는 값이 없는 경우에도 빈 배열이 나온다.
    - 컬럼에 일치하는 값을 모두 찾아준다. 
    - 결과값이 비어있는 경우에 nil? 메소드의 결과값이 false 

    rail c
    User.where(user_id: "xzcv")
    => #<ActiveRecord:: Relation []> ##내일 과제로 나갈 덕타이핑
    User.where(user_id: "xzcv").nil?
    => flase

- 포함?
  - 텍스트가 특정 단어/문장을 포함하고 있는가?
  - Model.where("컬럼명 LIKE?", "%#{value}%")
  - Model.where("컬럼명 LIKE? '%#{value}%'")되기는 하지만 쓰면 안된다.
    - 사용하면 안되는 이유?
      - SQL Injection(해킹)  
- 텍스트 패킹?? 

    2.3.4 :006 > User.where("user_id LIKE ?", "%h%")
      User Load (0.4ms)  SELECT "users".* FROM "users" WHERE (user_id LIKE '%h%')
     => #<ActiveRecord::Relation [#<User id: 1, user_id: "hello", password: nil, ip_address: nil, created_at: "2018-06-21 01:19:46", updated_at: "2018-06-21 01:19:46">]> 

*** 범위는 나중에 하기로!!

- 세션 : 원하는 키를 넣고 계속 사용할 수 있는?? 현재접속한 유저에 대한 정보뿐만 아니라 넣고자 하는 모든 정보를 넣을 수 있다. Hash 형태로 들어가 있다. 
  - 검색방법으로는 u.empty? , length== 0  : 비어있는가? 
  - u1.nil? : 값 자체가 없을 경우 
  - present : 존재하는가??
  - 꺼내서 쓸 때
    - User.find(session[:current_user]) 형식으로!!
      ----- BoardController
      def show
          #@post = Post.find(params[:id])
          set_post
          puts @post # @가 찍힌 변수??는 한 요청 안에서는 얼마든지 사용가능
        end
      
      def update
          # post = Post.find(params[:id])
          # post.title = params[:title]
          # post.contents = params[:contents]
          # post.save
          
          set_post
          @post.title = params[:title]
          @post.contents = params[:contents]
          @post.save
          redirect_to "/board/#{@post.id}"
        end
      
       def set_post
          @post = Post.find(params[:id])
        end
  - http://guides.rubyonrails.org/action_controller_overview.html     
    8 Filters
        class ApplicationController < ActionController::Base
          before_action :set_post, only: [:show, :edit, :update, :destroy] # 괄호 안에 있는 뷰를 실행하기 전에 set_post가 미리 실행하기에 각각의 정의(?) 안에 set_post를 쓰지 않아도 된다.
          before_action :set_post, except: [:index, :create] # 위와 동일
            
          def show
            #set_post  
            #@post = Post.find(params[:id])
            puts @post # @가 찍힌 변수??는 한 요청 안에서는 얼마든지 사용가능
          end
            
        end
        class ApplicationController < ActionController::Base
          protect_from_forgery with: :exception # csrf를 방지하는???
        end
        
- Helper_Method : 일반적으로 CMV의 순서를 역행하는 경우는 없으나 뷰에서 콘트롤러의 메소드를 사용하기 위한 방법이다.
- View Helper : 
- 쿠키 : 

    -----user.rb
    class User < ApplicationRecord
        #post를 여러개 가질 수 있다.
        has_many :posts
    end
    ------post.rb
    class Post < ApplicationRecord
        #하나의 유저만 가질 수 있어서 유저의 종속된다.
        belongs_to :user
    end

    $rails c
    
     u = User.new
     => #<User id: nil, user_name: nil, password: nil, ip_address: nil, created_at: nil, updated_at: nil> 
     
    2.3.4 :004 > u.save
       (0.1ms)  begin transaction
      SQL (0.6ms)  INSERT INTO "users" ("user_name", "password", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["user_name", "haha"], ["password", "1234"], ["created_at", "2018-06-21 05:12:26.864908"], ["updated_at", "2018-06-21 05:12:26.864908"]]
       (8.5ms)  commit transaction
     => true 
    2.3.4 :005 > p =Post.new
     => #<Post id: nil, title: nil, contents: nil, user_id: nil, created_at: nil, updated_at: nil> 
    2.3.4 :010 > p.user_id = u.id
     => 1 
    2.3.4 :011 > p.save
       (0.2ms)  begin transaction
      User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
      SQL (0.4ms)  INSERT INTO "posts" ("title", "contents", "user_id", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "simple"], ["contents", "relation"], ["user_id", 1], ["created_at", "2018-06-21 05:13:52.520212"], ["updated_at", "2018-06-21 05:13:52.520212"]]
       (8.3ms)  commit transaction
     => true 
    
    2.3.4 :014 > u.posts
      Post Load (0.3ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?  [["user_id", 1]]
     => #<ActiveRecord::Associations::CollectionProxy [#<Post id: 1, title: "simple", contents: "relation", user_id: 1, created_at: "2018-06-21 05:13:52", updated_at: "2018-06-21 05:13:52">]> 
    2.3.4 :015 > p.user
     => #<User id: 1, user_name: "haha", password: "1234", ip_address: nil, created_at: "2018-06-21 05:12:26", updated_at: "2018-06-21 05:12:26"> 


