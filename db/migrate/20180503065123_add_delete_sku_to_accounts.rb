class AddDeleteSkuToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :delete_sku, :boolean
  end
end
