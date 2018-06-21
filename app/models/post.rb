class Post < ApplicationRecord
    #하나의 유저만 가질 수 있어서 유저의 종속된다.
    belongs_to :user
end
