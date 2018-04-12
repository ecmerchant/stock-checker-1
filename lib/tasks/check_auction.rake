namespace :check_auction do
  desc "オークション監視"

  task :auction_checker, [:user] => :environment do |task, args|
    cuser = args[:user]
    AuctionCheckJob.perform_later(cuser)
  end

end
