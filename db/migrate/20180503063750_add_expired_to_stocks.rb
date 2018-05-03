class AddExpiredToStocks < ActiveRecord::Migration[5.0]
  def change
    add_column :stocks, :expired, :boolean
  end
end
