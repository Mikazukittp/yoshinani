step '次の情報でパスワードの作成を行う' do |table|

  params = { user:{} }
  table.hashes.each do |row|
    params[:user][:new_password]  = row['パスワード']     if row['パスワード']
    params[:user][:new_password_confirmation]    = row['確認用パスワード'] if row['確認用パスワード']
  end

  post api_passwords_path, params, { UID: @user['id'], TOKEN: @user['token'] }
end
