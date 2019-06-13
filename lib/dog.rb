
class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)

  end

  def save
    if self.id #if the object already has an id, means that it has been saved to the database
      self.update #in which case all we need to do is update the attributes within the database

    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]

    end

    self #returning the instance of the dog class

  end

  def update #this method already assumes that there is a Dog object with an id assigned to it, hence self.id
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    #recall that it's just easier to update all attributes in the database even if there's only one attribute change
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save #saving the Dog instance and its attribute to the database
    dog
  end


  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row) #creates and returns the object with the attributes from database

  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, hash[:name], hash[:breed])

    if !row.empty? #if the dog already exists in the database, all we need to do is create a new Dog object with the data

      dog_data = row[0]
      dog = Dog.new_from_db(dog_data)
      dog

    else #if the dog with the name and breed in the argument does not exist, then we'd be creating a new dog object and
      #saving that instance to the database

      dog = Dog.create(hash)

    end
  end

end
