require 'pry'

class Dog 
  attr_accessor :id, :name, :breed
  def initialize(dog_details)
    @id, @name, @breed = dog_details[:id], dog_details[:name], dog_details[:breed]
  end
  
  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    
    DB[:conn].execute(sql)
  end
  
  def self.create(details)
  
    new_dog = self.new(name: details[:name], breed: details[:breed])
    new_dog.save
    new_dog
  end
  
  def self.new_from_db(row)
    #binding.pry
    dog_details = {}
    dog_details[:id] = row[0]
    dog_details[:name] = row[1]
    dog_details[:breed] = row[2]
    self.new(dog_details)
  end
  
  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    #binding.pry
    DB[:conn].execute(sql, id_num).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *  FROM dogs WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? ", name, breed)
    
    if !dog.empty?
      dog_data = dog[0]
      dog_details = {id: dog_data[0], name: dog_data[1], breed: dog_data[2]}
      dog = self.new(dog_details) 
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def save
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   self
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end