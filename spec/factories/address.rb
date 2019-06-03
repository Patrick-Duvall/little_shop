FactoryBot.define do
  factory :address, class: Address do
    user
    nick_name { "home" }
    sequence(:address) { |n| "address #{n}" }
    sequence(:city) { |n| "city #{n}" }
    sequence(:state) { |n| "state #{n}" }
    sequence(:zip) { |n| "zip #{n}" }

  end
end
