require_relative "../config/environment.rb"

class Student

  TABLE_NAME = "students"

  class << self
    def create_table()
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS #{TABLE_NAME} " +
                            "(id INTEGER PRIMARY KEY, name TEXT, grade TEXT)")
    end

    def drop_table()
      DB[:conn].execute("DROP TABLE IF EXISTS #{TABLE_NAME};")
    end

    def create(name, grade)
      return Student.new(name, grade).save
    end

    def new_from_db(row)
     return self.new(row[0], row[1], row[2])
    end

    def all
      return DB[:conn].execute("SELECT * FROM #{TABLE_NAME}").collect { |row|
        self.new_from_db(row)
      }
    end

    def find_by_name(name)
      sql = "SELECT * FROM #{TABLE_NAME} WHERE name = ? LIMIT 1"
      return DB[:conn].execute(sql,name).collect { |row| self.new_from_db(row) }.first
    end
  end

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    self.name = name
    self.grade = grade
  end

  def save()
    if self.id.nil?
      sql = "INSERT INTO #{TABLE_NAME} (name, grade) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{TABLE_NAME}")[0][0]
    else
      self.update
    end
    return self
  end

  def update()
    sql = "UPDATE #{TABLE_NAME} SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    return self
  end
end
