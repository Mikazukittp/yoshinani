step '次のSNSが登録されている:' do |table|
  table.hashes.each do |row|
    attributes = {}
    attributes[:name] = row['SNS名'] if row['SNS名']
    create(:oauth, attributes)
  end
end
