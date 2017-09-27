require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

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

  def self.drop_table
    sql = <<-SQL
        DROP TABLE students
      SQL
      DB[:conn].execute(sql)
  end

  def save
    if @id == nil
        sql = <<-SQL
            INSERT INTO students (name, grade) VALUES (?,?)
          SQL
          DB[:conn].execute(sql,@name,@grade)

          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
    student
  end

  def self.new_from_db(arr)
    Student.new(arr[1], arr[2], arr[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM students WHERE name = ?
              SQL
      DB[:conn].execute(sql,name).map {|row| Student.new_from_db(row)}[0]
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
