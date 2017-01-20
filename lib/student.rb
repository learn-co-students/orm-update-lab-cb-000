require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @name, @grade, @id = name, grade, id
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students
        (name, grade) values(?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
    #binding.pry
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    new_from_db(DB[:conn].execute("SELECT * FROM students WHERE name=?",name)[0])
  end

  def self.new_from_db(a)
    Student.new(a[1],a[2],a[0])
  end

  def self.create(name, grade)
    Student.new(name, grade).tap(&:save)
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
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end



end
