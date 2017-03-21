require 'sqlite3'

class SQL_Client
  include SQLite3
  
  def initialize(db_name="development.sqlite3")
    @db = Database.new("#{$app_dir}db/#{db_name}")
  end
  
  def insert_into(table_name, dir_name, member_id)
    @db.transaction do
      Dir.foreach("#{$media_dir}#{dir_name}").each do |filename|
        filepath = dir_name + filename
        unless filename.match(/^\./)
          file = File.open("#{$media_dir}#{filepath}")
          begin
            @db.execute("INSERT INTO #{table_name}(member_id, address, date, created_at, updated_at) VALUES (?, ?, ?, ?, ?);",
                       member_id,
                       filepath,
                       file.mtime.strftime("%Y-%m-%d %H:%M:%S"),
                       Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                       Time.now.strftime("%Y-%m-%d %H:%M:%S"))
            puts filepath + " was successfully added"
          rescue SQLite3::ConstraintException
            puts filepath + " has already been added to database"
          end
        end
      end
    end
  end
  
  def add_label(column_name, value)
    @db.transaction do
      begin
        @db.execute("INSERT INTO #{column_name}s(#{column_name}) VALUES (?);", value)
      rescue
        puts "#{tag_name} has already been added to database"
      end
    end
  end
  
  def removed_addresses
    @db.execute("SELECT address FROM removed_addresses;").flatten
  end
  
  def close
    @db.close
  end
end
