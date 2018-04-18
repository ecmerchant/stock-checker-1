class AddLeadtimeToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :leadtime, :integer
  end
end
