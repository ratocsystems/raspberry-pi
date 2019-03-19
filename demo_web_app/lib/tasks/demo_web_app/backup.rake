namespace :demo_web_app do
  namespace :backup do

    desc "demo_web_app | Create a backup of demo_web_app data"
    task :create => :environment do
      puts "Dumping database ... ".color(:blue)

      Backup::Database.new.dump
      puts "done".color(:green)
    end

    desc "demo_web_app | Restore a previously create backup"
    task :restore => :environment do
      puts "Restoring database ... ".color(:blue)

      Backup::Database.new.restore
      puts "done".color(:green)
    end
  end
end

