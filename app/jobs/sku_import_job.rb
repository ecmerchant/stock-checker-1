class SkuImportJob < ApplicationJob
  queue_as :default

  def perform(csv, user)
    # Do something later
    logger.debug("Import sku starts")
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
    end
  end
end
