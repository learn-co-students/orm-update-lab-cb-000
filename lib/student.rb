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
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  # creates a student object with name and grade attributes
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  # creates an instance with corresponding attribute values
    # This class method takes an argument of an array
    # When we call this method we will pass it the array that is the row returned from the database by the execution of a SQL query
    # We can anticipate that this array will contain three elements in this order: the id, name and grade of a student
    # The .new_from_db method uses these three array elements to create a new Student object with these attributes
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(id, name, grade)
  end

  # returns an instance of student that matches the name from the DB
    # This class method takes in an argument of a name
    # It queries the database table for a record that has a name of the name passed in as an argument
    # Then it uses the #new_from_db method to instantiate a Student object with the database row that the SQL query returns
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # updates the record associated with a given instance
  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, grade, id)
  end


end

=begin
  * Access the database connection anywhere in this class with DB[:conn]
=end
