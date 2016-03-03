step '次のユーザーが登録されている:' do |table|
  table.hashes.each do |row|
    attributes = {}
    attributes[:account] = row['アカウント'] if row['アカウント']
    attributes[:password] = row['パスワード'] if row['パスワード']
    create(:user, attributes)
  end
end

step 'ユーザー :account パスワード :password としてログインする' do |account, password|
  post sign_in_api_users_path, { account: account, password: password }
  @user = JSON.parse(response.body)
end
