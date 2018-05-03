class FeedUploadJob < ApplicationJob
  queue_as :default
  require 'csv'
  require 'peddler'

  def perform(cuser)
    # Do something later
    current_email = cuser
    user = Account.find_by(user: cuser)
    user.update(
      upload_date: Time.now,
      report_id: "実行中"
    )
    leadtime = user.leadtime
    delete_sku = user.delete_sku
    aws = ENV["AWS_ACCESS_KEY_ID"]
    skey = ENV["AWS_SECRET_ACCESS_KEY"]
    sid = user.seller_id
    token = user.aws_token

    header = CSV.read('public/Flat_File_Price_Inventory_Updates_JP.csv', encoding: "Shift_JIS:UTF-8")

    client = MWS.feeds(
      primary_marketplace_id: "A1VC38T7YXB528",
      merchant_id: sid,
      aws_access_key_id: aws,
      aws_secret_access_key: skey,
      auth_token: token
    )
    relist = user.relist_only
    stock = Stock.where(email: cuser)
    data = stock.pluck(:sku, :quantity, :validity, :expired)
    feed_body = ""
    logger.debug(data)
    k = 0
    while k < data.length
      buf = []
      for i in 0..15
        buf[i] = ""
        case i
          when 0 then
            buf[i] = data[k][0]
          when 4 then
            if relist == true then
              if data[k][2] == true then
                buf[i] = data[k][1]
              else
                buf[i] = ""
              end
            else
              buf[i] = data[k][1]
            end
          when 5 then
            if leadtime != nil then
              buf[i] = leadtime
            end
          when 6 then
            if delete_sku == true then
              if data[k][3] == true then
                buf[i] = "Delete"
              else
                buf[i] = "PartialUpdate"
              end
            else
              buf[i] = "PartialUpdate"
            end
        end
      end
      feed_body = feed_body + buf.join("\t")
      feed_body = feed_body + "\n"
      k += 1
    end

    k = 0
    feed_body = header.join("\n") + "\n" + feed_body
    logger.debug(feed_body)
    new_body = feed_body.encode(Encoding::Windows_31J)

    feed_type = "_POST_FLAT_FILE_LISTINGS_DATA_"
    parser = client.submit_feed(new_body, feed_type)
    doc = Nokogiri::XML(parser.body)

    submissionId = doc.xpath(".//mws:FeedSubmissionId", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text

    process = ""
    err = 0
    while process != "_DONE_" do
      sleep(25)
      list = {feed_submission_id_list: submissionId}
      parser = client.get_feed_submission_list(list)
      doc = Nokogiri::XML(parser.body)
      process = doc.xpath(".//mws:FeedProcessingStatus", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text
      logger.debug(process)
      err += 1
      if err > 1 then
        break
      end
    end
    logger.debug("\n\n")
    generatedId = doc.xpath(".//mws:FeedSubmissionId", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text
    logger.debug(generatedId)
    user.update(
      upload_date: Time.now,
      report_id: generatedId
    )
  end
end
