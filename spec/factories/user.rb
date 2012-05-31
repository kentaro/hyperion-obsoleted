require 'forgery'

FactoryGirl.define do
  factory :user do
    provider 'github'
    sequence(:uid) { |n| n }
    name  Forgery::Internet.user_name
    image 'http://example.com/image/1'
  end
end
