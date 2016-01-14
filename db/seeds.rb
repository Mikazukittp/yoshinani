# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.create([
  {
    account: "haijima",
    username: "朏島一樹",
    email: "haijima@r.recruit.co.jp",
    password: "password1!",
    role: 1
  }, {
    account: "matsumatsu",
    username: "松山勇輝",
    email: "matsuyama@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "yusaku",
    username: "徳永優作",
    email: "tokunaga@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "tatsu",
    username: "石部達也",
    email: "ishibe@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "sarashiya",
    username: "晒谷亮介",
    email: "sarashiya@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "yuichi",
    username: "奥野悠一",
    email: "okuno@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "kenken",
    username: "越島健介",
    email: "koshijima@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "osako",
    username: "大迫正和",
    email: "osako@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "nori",
    username: "木村憲仁",
    email: "kimura@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }, {
    account: "honjo",
    username: "本庄智也",
    email: "honjo@r.recruit.co.jp",
    password: "password1!",
    role: 0
  }
])

groups = Group.create([{
  name: "研修1G",
  description: "俺らのグループ"
}])

users.each{ |user|
  GroupUser.create([
    group_id: groups[0].id,
    user_id: user.id
  ])
}

10.times.each{ |n|
  payment = Payment.create({
    amount: 5000+rand(10000),
    event: "event#{n+1}",
    description: "description",
    date: "2015-08-15",
    paid_user_id: users[rand(10)].id,
    group_id: groups[0].id
  })
  10.times.map{|n|n}.sample(rand(9)+1).each{ |n|
    Participant.create({
      payment_id: payment.id,
      user_id: users[n].id
    })
  }
}


Payment.all.each{ |payment|
  # 支払ユーザの支払総額に加算
  total = Total.where(group_id: groups[0].id, user_id: payment.paid_user_id).first_or_initialize
  total.paid = total.paid.to_f + payment.amount.to_f
  total.save!

  payment.participants.each{ |participant|
    # 参加者の借入総額に加算
    total = Total.where(group_id: payment.group_id, user_id: participant.id).first_or_initialize
    total.to_pay = total.to_pay.to_f + (payment.amount.to_f / payment.participants.size).round(2)
    total.save!
  }

}
