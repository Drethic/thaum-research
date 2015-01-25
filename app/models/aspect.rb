class Aspect < ActiveRecord::Base
    validates :aspect, presence: true
    validates :keywords, presence: true
    validates :component1, presence: true
end
