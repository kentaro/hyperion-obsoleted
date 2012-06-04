FactoryGirl.define do
  factory :service do
    name        'test service'
    description 'test service description'

    trait :with_hosts do
      host_services {
        [
          create(:host_service, host: create(:host))
        ]
      }
    end
  end
end
