class User < ApplicationRecord
    #post를 여러개 가질 수 있다.
    has_many :posts
end
