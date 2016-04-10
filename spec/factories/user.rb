FactoryGirl.define do
  factory :user do
    account 'ganbaruhito'
    password 'password1!'
    email 'ganbaruhito@example.com'
    username 'ganbaruhito'

    # save時にvalidationをスキップする
    to_create do |instance|
      instance.save validate: false
    end 
  end
end
