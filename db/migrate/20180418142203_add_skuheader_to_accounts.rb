class AddSkuheaderToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :sku_header, :string
  end
end
