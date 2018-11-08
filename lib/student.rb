require_relative "../config/environment.rb"

class Student


  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id = nil, name, grade)
      @id = id
      @name = name
      @grade = grade
  end


  def self.create(id = nil, name, grade)
    new_student = Student.new(id, name, grade)
    new_student.save
    new_student
  end

 def self.create_table
   sql = <<-SQL
      CREATE TABLE students(
        id INTEGER,
        name TEXT,
        grade INTEGER)
   SQL

   DB[:conn].execute(sql)

 end


 def self.drop_table
   sql = <<-SQL
     DROP TABLE students
   SQL

   DB[:conn].execute(sql)

 end


 def self.find_by_name(name)
   sql = <<-SQL
     SELECT * FROM students
     WHERE name = ?
   SQL

   student_data = DB[:conn].execute(sql, name)[0]
   Student.new(student_data[0], student_data[1], student_data[2])
  # student_data
 end



 def update
   sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
   SQL

   DB[:conn].execute(sql, @name, @grade, @id)

 end


 def self.new_from_db(row)

   Student.new( row[0], row[1],  row[2])
 end



 def save
   if self.id
     self.update
   else
   sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
   SQL

   DB[:conn].execute(sql, @name, @grade)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
   end

 end

end
