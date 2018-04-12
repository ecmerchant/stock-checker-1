class AddUploadinfoToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :upload_date, :datetime
    add_column :accounts, :report_id, :string
  end
end
