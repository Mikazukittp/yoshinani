step '次のグループが登録されている:' do |table|
  table.hashes.each do |row|
    attributes = {}
    attributes[:name] = row['グループ名'] if row['グループ名']
    attributes[:description] = row['説明'] if row['説明']
    create(:group, attributes)
  end
end

step "ユーザー :accout はグループ :name に所属している" do |account, name|
  user = User.find_by(account: account)
  group = Group.find_by(name: name)
  create(:group_user, user_id: user.id, group_id: group.id, status: 'active')
end

step '次のグループを作成する' do |table|
  params = { group: {} }
  table.hashes.each do |row|
    params[:group][:name] = row['グループ名'] if row['グループ名']
    params[:group][:description] = row['説明'] if row['説明']
  end

  post api_groups_path, params, { UID: @user['id'], TOKEN: @user['token'] }
end

step "groupの一覧が閲覧できること" do
  get api_groups_path, {}, { UID: @user['id'], TOKEN: @user['token'] }
  expect(response).to be_success
  expect(response.status).to eq 200
  expect(JSON.parse(response.body)).not_to be_empty
end

step "ユーザー :accout はグループ :name に参加していること" do |account, name|
  user = User.find_by(account: account)
  group = Group.find_by(name: name)
  group_user = GroupUser.find_by(user_id: user.id, group_id: group.id, status: 'active')

  expect(group_user).not_to be_nil
end

step "ユーザー :accout はグループ :name に招待されていること" do |account, name|
  user = User.find_by(account: account)
  group = Group.find_by(name: name)
  group_user = GroupUser.find_by(user_id: user.id, group_id: group.id, status: 'inviting')

  expect(group_user).not_to be_nil
end
