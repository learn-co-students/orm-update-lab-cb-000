require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id, :saved

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
    @saved = false
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    return student
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    row = DB[:conn].execute("SELECT * FROM students WHERE name = (?)", name)[0]
    student = self.new_from_db(row)
    return student
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if @saved
      DB[:conn].execute("UPDATE students SET name = ? WHERE id = ?", @name, @id)
    else
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?)", @name, @grade)
      @id = DB[:conn].execute("SELECT id FROM students WHERE name = (?)", @name)[0][0]
      @saved = true
    end
  end

  def update
    self.save
  end

end
