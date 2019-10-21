require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<~SQL
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

  def self.create(name, grade)
    student = new(name, grade)
    student.save
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    result = DB[:conn].execute(sql, name)

    new_from_db(result.first)
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def save
    if id
      update
      return
    end
    
    sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
    DB[:conn].execute(sql, name, grade)

    sql = "SELECT last_insert_rowid() FROM students"
    result = DB[:conn].execute(sql)
    @id = result[0][0]
  end

  def update
    sql = <<~SQL
            UPDATE students
            SET name = ?, grade = ?
            WHERE id = ?
            SQL

    DB[:conn].execute(sql, name, grade, id)
  end

end
