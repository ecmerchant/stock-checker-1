class SkuImportJob < ApplicationJob
  queue_as :sku_import

  def perform(csv, user)
    # Do something later
    logger.debug("Import sku starts")
    maxsku = Account.find_by(user: user).sku_limit.to_i
    for row in csv do
      sku = row.to_s
      sku.gsub!(" ", "")
      sku.gsub!("\n", "")
      sku.gsub!("\r", "")
      sku.gsub!("\t", "")
      logger.debug("Import sku :" + sku)
      temp = Stock.find_or_initialize_by(email: user, sku: sku)
      temp.update(
        email: user,
        sku: sku,
        title: nil,
        current_price: nil,
        fixed_price: nil,
        quantity: nil,
        access_date: nil,
        validity: nil,
        expired: false
      )
      if Stock.where(email: user).count > maxsku then
        break
      end
    end
  end
end
