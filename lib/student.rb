require_relative "../config/environment.rb"

class Student
  # has a name and a grade
  # has an id that defaults to `nil` on initialization
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # creates the students table in the database
    # This class method creates the students table with columns that match the attributes of our individual students:
    # an id (which is the primary key), the name and the grade
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  # drops the students table from the database
    # This class method should be responsible for dropping the students table
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  # saves an instance of the Student class to the database and then sets the given students `id` attribute
  # updates a record if called on an object that is already persisted
    # This instance method inserts a new row into the database using the attributes of the given object
    # This method also assigns the id attribute of the object once the row has been inserted into the database.
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  # creates a student object with name and grade attributes
  def create
  end

  # creates an instance with corresponding attribute values
  def new_from_db
  end

  # returns an instance of student that matches the name from the DB
  def find_by_name
  end

  # updates the record associated with a given instance
  def update
  end


end

=begin
  * Access the database connection anywhere in this class with DB[:conn]
=end
