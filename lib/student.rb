require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
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

    sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

    sql_update = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      SQL

    name = @name
    grade = @grade
    id = @id

    db_inst = DB[:conn].execute("SELECT * FROM students WHERE id = ?", id)


    if !db_inst.empty?
      DB[:conn].execute(sql_update, name, grade, id)
    else
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end


  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end


  def self.new_from_db(row)
    name = row[1]
    grade = row[2]
    id = row[0]
    student = Student.new(name, grade, id)
    student.save
    student
  end


  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM students
        WHERE name = ?
      SQL

    db_student = DB[:conn].execute(sql, name)
    db_student.flatten!
    db_name = db_student[1]
    db_grade = db_student[2]
    db_id = db_student[0]

    student = Student.new(db_name, db_grade, db_id)
    student
  end


  def update
    sql_update = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      SQL

    name = @name
    grade = @grade
    id = @id

    DB[:conn].execute(sql_update, name, grade, id)
  end


end
