require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
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

  def update
    sql = "UPDATE students SET name=?,grade=? WHERE id=?"
    DB[:conn].execute(sql, name, grade, id)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students(name, grade)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    song = self.new(name, grade)
    song.save

  end

  def self.new_from_db(row)
    #bring in database and map to object creating new ones

    student_id = row[0]
    student_name = row[1]
    student_grade = row[2]
    student = self.new(student_id, student_name, student_grade)
    student

  end

  def self.find_by_name(name)
    #returns an instance of student that matches the name from DB
    sql = "SELECT * FROM students WHERE name=? LIMIT 1"
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first

  end


  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
