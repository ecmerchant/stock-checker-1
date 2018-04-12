class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :user
      t.string :seller_id
      t.string :aws_token
      t.boolean :relist_only
      t.integer :sku_limit

      t.timestamps
    end
  end
end
