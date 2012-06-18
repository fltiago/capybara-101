FactoryGirl.define do
  factory :user do |u|
    u.sequence(:email) { |n| "user#{n}@redu.com"}
    u.password "testpass"
  end
end
