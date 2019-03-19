require 'yaml'

module Backup
  class Database
    FILE_NAME_SUFFIX = '_demo_web_app_backup.sql.gz'

    attr_reader :config

    def initialize
      @config = YAML.load(ERB.new(File.read(File.join(Rails.root, 'config', 'database.yml'))).result)[Rails.env]
    end

    def dump
      db_file_name = File.join('tmp/backups', file_timestamp)

      FileUtils.mkdir_p(File.dirname(db_file_name))
      FileUtils.rm_f(db_file_name)
      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(*%w(gzip -1 -c), in: compress_rd, out: [db_file_name, 'w', 0600])
      compress_rd.close

      dump_pid =
        case config["adapter"]
        when /^mysql/ then
          print "Dumping MySQL database #{config['database']} ... "
          # Workaround warnings from MySQL 5.6 about passwords on cmd line
          ENV['MYSQL_PWD'] = config["password"].to_s if config["password"]
          spawn('mysqldump', *mysql_args, config['database'], out: compress_wr)
        when "postgresql" then
          print "Dumping PostgreSQL database #{config['database']} ... "
          pg_env
          pgsql_args = ["--clean"] # Pass '--clean' to include 'DROP TABLE' statements in the DB dump.

          spawn('pg_dump', *pgsql_args, config['database'], out: compress_wr)
        end
      compress_wr.close

      success = [compress_pid, dump_pid].all? do |pid|
        Process.waitpid(pid)
        $?.success?
      end

      report_success(success)
      raise Backup::Error, 'Backup failed' unless success
    end

    def restore
      db_file_name = search_backup
      db_file_name = File.join('tmp/backups', db_file_name)

      decompress_rd, decompress_wr = IO.pipe
      decompress_pid = spawn(*%w(gzip -cd), out: decompress_wr, in: db_file_name)
      decompress_wr.close

      restore_pid =
        case config["adapter"]
        when /^mysql/ then
          print "Restoring MySQL database #{config['database']} ... "
          # Workaround warnings from MySQL 5.6 about passwords on cmd line
          ENV['MYSQL_PWD'] = config["password"].to_s if config["password"]
          spawn('mysql', *mysql_args, config['database'], in: decompress_rd)
        when "postgresql" then
          print "Restoring PostgreSQL database #{config['database']} ... "
          pg_env
          spawn('psql', config['database'], in: decompress_rd)
        end
      decompress_rd.close

      success = [decompress_pid, restore_pid].all? do |pid|
        Process.waitpid(pid)
        $?.success?
      end

      report_success(success)
      abort Backup::Error, 'Restore failed' unless success
    end

    protected
    def file_timestamp
      "#{Time.current.strftime('%s_%Y_%m_%d_')}ver#{FILE_NAME_SUFFIX}"
    end

    def search_backup
      backup_path = 'tmp/backups'
      Dir.chdir(backup_path) do
        # check for existing backups in the backup dir
        if backup_file_list.empty?
          puts "No backups found in #{backup_path}"
          puts "Please make sure that file name ends with #{FILE_NAME_SUFFIX}"
          exit 1
        elsif backup_file_list.many? && ENV["BACKUP"].nil?
          puts 'Found more than one backup:'
          # print list of available backups
          puts " " + available_timestamps.join("\n ")
          puts 'Please specify which one you want to restore:'
          puts 'rake gitlab:backup:restore BACKUP=timestamp_of_backup'
          exit 1
        end

        db_file_name = if ENV['BACKUP'].present?
                     "#{ENV['BACKUP']}#{FILE_NAME_SUFFIX}"
                   else
                     backup_file_list.first
                   end

        unless File.exist?(db_file_name)
          puts "The backup file #{db_file_name} does not exist!"
          exit 1
        end

        return db_file_name
      end
    end

    def backup_file_list
      @backup_file_list ||= Dir.glob("*#{FILE_NAME_SUFFIX}")
    end

    def available_timestamps
      @backup_file_list.map {|item| item.gsub("#{FILE_NAME_SUFFIX}", "")}
    end

    def mysql_args
      args = {
        'host'      => '--host',
        'port'      => '--port',
        'socket'    => '--socket',
        'username'  => '--user',
        'encoding'  => '--default-character-set',
        # SSL
        'sslkey'    => '--ssl-key',
        'sslcert'   => '--ssl-cert',
        'sslca'     => '--ssl-ca',
        'sslcapath' => '--ssl-capath',
        'sslcipher' => '--ssl-cipher'
      }
      args.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact
    end

    def pg_env
      args = {
        'username'  => 'PGUSER',
        'host'      => 'PGHOST',
        'port'      => 'PGPORT',
        'password'  => 'PGPASSWORD',
        # SSL
        'sslmode'         => 'PGSSLMODE',
        'sslkey'          => 'PGSSLKEY',
        'sslcert'         => 'PGSSLCERT',
        'sslrootcert'     => 'PGSSLROOTCERT',
        'sslcrl'          => 'PGSSLCRL',
        'sslcompression'  => 'PGSSLCOMPRESSION'
      }
      args.each { |opt, arg| ENV[arg] = config[opt].to_s if config[opt] }
    end

    def report_success(success)
      if success
        puts '[DONE]'.color(:green)
      else
        puts '[FAILED]'.color(:red)
      end
    end
  end
end
