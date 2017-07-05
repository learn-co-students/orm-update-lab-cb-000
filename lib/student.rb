require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
    attr_reader :id

  def initialize( id = nil, name, grade )
    @id = id
    @name = name
    @grade = grade
  end

  def self.find_by_name( name )
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name).flatten
    #puts "Result 0:#{result[0][0]}"
    #puts "Result 1:#{result[0][1]}"
    #puts "Result 2:#{result[0][2]}"

    Student.new( result[0], result[1], result[2] )
  end

  def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS students (
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
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?)
          SQL

            DB[:conn].execute(sql, self.name, self.grade)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        end
    end

    def update

      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)

    end

    def self.create( name, grade )
        newStudent = Student.new( name, grade )
        newStudent.save
        #newStudent
    end

    def self.new_from_db( row )
      #puts "0:#{row[0]}"
      #puts "1:#{row[1]}"
      #puts "2:#{row[2]}"
      newStudent = Student.new( row[0], row[1], row[2] )
      newStudent
    end

end
