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

step 'ユーザー :account パスワード :password としてログインできること' do |account, password|
  post sign_in_api_users_path, { account: account, password: password }
  expect(response).to be_success
  expect(response.status).to eq 200
end

step ':name のOAuth経由で新規会員登録を行う' do |name|
  oauth = Oauth.find_by(name: name)
  params = {
            oauth_registration: {
              third_party_id: "1234",
              oauth_id: oauth.id,
              sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
            }
          }

  post api_oauth_registrations_path, params
  @user = JSON.parse(response.body)
end

step '次の情報でユーザー情報の更新を行う' do |table|
  params = { user:{} }
  table.hashes.each do |row|
    params[:user][:account]  = row['アカウント']     if row['アカウント']
    params[:user][:email]    = row['メールアドレス'] if row['メールアドレス']
    params[:user][:username] = row['ユーザネーム']   if row['ユーザネーム']
    params[:user][:password] = row['パスワード']     if row['パスワード']
  end

  patch api_user_path(@user), params, { UID: @user['id'], TOKEN: @user['token'] }
  @json = JSON.parse(response.body)
end
