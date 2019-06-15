class Dog
  attr_accessor :name, :breed
  attr_reader :id

 def initialize(id: nil, name:, breed:)
   @id = id
   @name = name
   @breed = breed
 end

 def self.create_table
   sql = <<-SQL
   CREATE TABLE IF NOT EXISTS dogs(
     id INTEGER PRIMARY KEY,
     name TEXT,
     breed TEXT
   )
   SQL
   DB[:conn].execute(sql)
 end

 def self.drop_table
   DB[:conn].execute("DROP TABLE dogs");
 end

 def save
   sql = <<-SQL
   INSERT INTO dogs(name, breed)
   VALUES (?, ?)
   SQL
    DB[:conn].execute(sql, self.name, self.breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   new_dog = Dog.new(id: self.id, name: self.name, breed: self.breed)
   new_dog
 end

 def self.create(hash)
   new_dog = Dog.new(hash)
   new_dog.save
   new_dog
 end

 def self.find_by_id(num)
   sql = <<-SQL
   SELECT *
   FROM dogs
   WHERE id = ?
   SQL
   dog = DB[:conn].execute(sql, num)[0]
   new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
 end

 def self.find_or_create_by(hash)
   sql = <<-SQL
   SELECT * FROM dogs
   WHERE name = ? AND breed = ?
   SQL
   dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(hash)
    end
    dog
  end

end
