namespace :feed_upload do
  desc "在庫改定CSVアップロード"

  task :feed_upload, [:user] => :environment do |task, args|
    cuser = args[:user]
    FeedUploadJob.perform_later(cuser)
  end
end
