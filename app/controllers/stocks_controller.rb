class StocksController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'csv'
  require 'peddler'
  require 'typhoeus'

  before_action :authenticate_user!, except: [:regist]
  protect_from_forgery :except => [:regist]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def regist
    if request.post? then
      user = params[:email]
      password = params[:password]
      limit = params[:limit]
      new_user = User.find_or_initialize_by(email: user)
      new_user.update(
        password: password,
        admin_flg: false
      )
      account = Account.find_or_create_by(user: user)
      account.update(sku_limit: limit.to_i)
    end
    redirect_to root_url
  end


  def show
    user = current_user.email
    @admin_flg = current_user.admin_flg
    @stock = Stock.where(email: user)
    @account = Account.find_or_create_by(user: user)
    if @account.sku_limit == nil then
      @account.update(sku_limit: 20000)
    end

    if @stock != nil then
      @total_sku = @stock.count
      if @stock.first != nil then
        @start_date = @stock.first.access_date
      else
        @start_date = "-"
      end

      if @stock.last != nil then
        @end_date = @stock.last.access_date
      else
        @end_date = "-"
      end

      if @account != nil then
        @upload_date = @account.upload_date
        @report_id = @account.report_id
      else
        @upload_date = "-"
        @report_id = "-"
      end
    else
      @total_sku = 0
      @start_date = "-"
      @end_date = "-"
      @upload_date = "-"
      @report_id = "-"
    end
  end

  def import
    flash[:normal]
    if request.post?
      logger.debug("\n\nStart Debug!!")
      data = params[:file]
      logger.debug("\n\n")
      tuser = current_user.email
      @account = Account.find_by(user: tuser)
      if @account.sku_limit == nil then
        @account.update(sku_limit: 20000)
      end
      maxsku = Account.find_by(user: tuser).sku_limit
      st = Stock.where(email: tuser).count

      if st > maxsku.to_i then
        flash[:alarm] = "SKUが上限数を超えています"
        redirect_to stocks_import_path
      else
        if data != nil then
          temp = File.open(data.path)
          body = temp.read
          new_body = body.gsub(/\R/, "\n")
          #csv = CSV.table(data.path)
          csv = CSV.parse(new_body)
          logger.debug(csv[0])
          #if csv.headers.include?(:sku) then
          if csv[0][0] == "sku" then
            logger.debug("sku header")
            #td = csv[:sku]
            td = csv
            SkuImportJob.perform_later(td, current_user.email)
            flash[:success] = "インポート成功"
          end
        end
      end
    end
  end

  def setup
    user = current_user.email
    @account = Account.find_or_create_by(user: user)
    if @account.sku_limit == nil then
      @account.update(sku_limit: 20000)
    end
    if request.post? then
      @account.update(user_params)
    end
  end

  def list
    flash[:normal]
    user = current_user.email
    @stock = Stock.where(email: user).limit(20000)
    if request.post?
      logger.debug("\n\nStart Debug!!")
      data = params[:file]
      logger.debug("\n\n")
      tuser = current_user.email

      if data != nil then
        csv = CSV.table(data.path)
        logger.debug("data is ok")
        logger.debug(csv.headers)
        if csv.headers.include?(:sku) then
          logger.debug("sku header")
          td = csv[:sku]
          for snum in td
            dstock = @stock.find_by(sku: snum)
            if dstock != nil then
              dstock.delete
            end
          end
          flash[:success] = "削除成功"
        elsif csv.headers.include?(:deleteall) then
          logger.debug("data is delete")
          skus = Stock.where(email: tuser)
          skus.delete_all
          flash[:success] = "全SKU削除成功"
        end
      end
    end
  end

  def download
    user = current_user.email
    @stock = Stock.where(email: user)
    d = Date.today
    str = d.strftime("%Y%m%d")
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "sku_list_" + str + ".csv", type: :csv
      end
    end
  end

  def check
    logger.debug("監視開始")
    user = current_user.email
    @stock = Stock.where(email: user)
    AuctionCheckJob.perform_later(user)
    sleep(0.5)
    redirect_to stocks_show_path
  end

  def delete
    if request.post?
      tuser = current_user.email
      skus = Stock.where(email: tuser)
      skus.delete_all
      flash[:success] = "全SKU削除成功"
    end
    redirect_to stocks_setup_path
  end

  def upload
    logger.debug("\n\n")
    logger.debug("Upload Start")
    cuser = current_user.email
    FeedUploadJob.perform_later(cuser)
    redirect_to stocks_show_path
  end

  private
  def user_params
     params.require(:account).permit(:user, :seller_id, :aws_token, :relist_only, :sku_limit, :sku_header, :cw_room_id, :cw_api_token, :leadtime, :delete_sku)
  end

end
