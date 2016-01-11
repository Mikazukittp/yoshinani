FactoryGirl.define do
  factory :payment do
    amount 10000
    event 'ユークシンオークション'
    description 'ありゃ盗めねーわ'
    date Time.now
  end
end
