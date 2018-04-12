class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.string :email
      t.string :sku
      t.string :title
      t.integer :current_price
      t.integer :fixed_price
      t.integer :quantity
      t.datetime :access_date
      t.boolean :validity

      t.timestamps
    end
  end
end
