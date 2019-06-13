class Dog

    attr_accessor :name, :breed, :id

    def initialize(**args)
        args.each {|key, value| self.send(("#{key}="), value)}
    end

    def save   
        if @id
            update
        else         
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, @name, @breed, @id)
    end

    def self.create(**args)
        dog = Dog.new(args)
        dog.save
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
        SQL

        row = DB[:conn].execute(sql, name, breed).first

        if row
            self.new_from_db(row)
        else
            self.create({name: name, breed: breed})
        end
    end

    def self.new_from_db(row)
        args = {
            id: row[0],
            name: row[1],
            breed: row[2]
        }        
        Dog.new(args)
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end
    
    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

end