require_relative "../config/environment.rb"

class Student
  attr_accessor :name,:grade
  attr_reader :id
  def initialize(name,grade,id=nil)
    @name=name
    @grade=grade
    @id=id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS students")
    end

    def save
      if self.id
        self.update
      else
        DB[:conn].execute("INSERT INTO students (name,grade) VALUES (?,?)",self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def self.create(name,grade)
      self.new(name,grade).save
    end

    def self.new_from_db(row)
      Student.new(row[1],row[2],row[0])
    end

    def self.find_by_name(name)
      s = DB[:conn].execute("SELECT * FROM students WHERE name = ?",name)[0]
      self.new_from_db(s)
    end

    def update
      if self.id
        DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?",self.name,self.grade,self.id)
      end
    end



  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
