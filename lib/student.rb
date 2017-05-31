require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize name, grade
    @name, @grade = name, grade
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students(
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade INTEGER
    )
    ")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if self.id != nil
       self.update
       return self
     else
      sql = <<-SQL
        INSERT INTO students (name,grade)
        VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students").flatten.first
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create name, grade
    student = Student.new name, grade
    student.save
    student
  end

  def self.new_from_db row
    student = Student.new row[1], row[2]
    student.id = row[0]
    student
  end

  def self.find_by_name(name)
    sql =<<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    new_from_db(DB[:conn].execute(sql, name).flatten)
  end
end
