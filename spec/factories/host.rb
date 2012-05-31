FactoryGirl.define do
  factory :host do
    sequence(:hostname)   { |n| "test#{n}.example.com" }
    sequence(:ip_address) { |n| "192.168.0.#{n}" }
  end
end
