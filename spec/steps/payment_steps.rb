step '次の支払情報が登録されている:' do |table|
  table.hashes.each do |row|
    attributes = {}
    attributes[:amount]      = row['金額']     if row['金額']
    attributes[:event]       = row['イベント'] if row['イベント']
    attributes[:description] = row['説明']     if row['説明']
    attributes[:date]        = row['日付']     if row['日付']
    create(:payment, attributes)
  end
end

step '次の支払情報を登録する' do |table|
  table.hashes.each do |row|
    params = { payment: {} }
    params[:payment][:amount]       = row['金額']     if row['金額']
    params[:payment][:event]        = row['イベント'] if row['イベント']
    params[:payment][:description]  = row['説明']     if row['説明']
    params[:payment][:date]         = row['日付']     if row['日付']
    params[:payment][:paid_user_id] = @user['id']
    params[:payment][:group_id]     = Group.find_by(name: row['グループ名']).id if row['グループ名']
    if row['参加者']
      params[:payment][:participants_ids] = []

      row['参加者'].split(',').each do |account|
        params[:payment][:participants_ids] << User.find_by(account: account).id
      end
    end

    post api_payments_path, params, { UID: @user['id'], TOKEN: @user['token'] }
  end
end

step ':event の支払情報を削除する' do |event|
  payment = Payment.find_by(event: event)

  delete api_payment_path(payment), {}, { UID: @user['id'], TOKEN: @user['token'] }
end
