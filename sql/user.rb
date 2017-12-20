require 'sqlite3'
require_relative 'question'
require_relative 'questionsfollow'
require_relative 'reply'
require_relative 'questions'
require_relative 'questionlike'
require_relative 'modelbase'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
  #   # user = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   # SELECT
  #   # *
  #   # FROM
  #   # users
  #   # WHERE
  #   # id = ?
  #   # SQL
  #   # user.empty? ? nil : User.new(user.first)
  super(id)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    user.empty? ? nil : User.new(user.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def followed_questions
    QuestionsFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user(@id)
  end

  def average_karma
    question_likes = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      COUNT(DISTINCT questions.user_id) / CAST(COUNT(question_likes.user_id) AS FLOAT) AS average
    FROM
      questions
    LEFT JOIN
      question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.user_id = ?
    SQL
    question_likes.first['average']
    # question_likes['num_likes'] / question_likes['num_questions']
  end

  def save
    update if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "does not exist" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
    UPDATE
      users
    SET
      fname = ?, lname = ?
    WHERE
      id = ?
    SQL
  end

end
