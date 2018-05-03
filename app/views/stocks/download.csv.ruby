require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(SKU '商品名' '更新日時' '在庫有無' '期限切れ')
  csv << csv_column_names
  @stock.each do |stock|
    csv_column_values = [
      stock.sku,
      stock.title,
      stock.access_date,
      stock.validity,
      stock.expired
    ]
    csv << csv_column_values
  end
end
