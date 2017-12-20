require 'sqlite3'
require_relative 'questions'
require_relative 'questionsfollow'
require_relative 'reply'
require_relative 'user'
require_relative 'questionlike'
require_relative 'modelbase'

class Question < ModelBase
  attr_accessor :title, :body, :user_id
  attr_reader :id


  # def self.find_by_id(id)
  #   question = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #   *
  #   FROM
  #   questions
  #   WHERE
  #   id = ?
  #   SQL
  #   question.empty? ? nil : Question.new(question.first)
  # end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
    *
    FROM
    questions
    WHERE
    user_id = ?
    SQL
    questions.empty? ? nil : questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionsFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options ['user_id']
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
    SELECT
      *
    FROM
      users
    WHERE id = ?
    SQL
    User.new(author.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionsFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save
    update if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
    INSERT INTO
      questions (title, body, user_id)
    VALUES
      (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "does not exist" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
    UPDATE
      questions
    SET
      title = ?, body = ?, user_id = ?
    WHERE
      id = ?
    SQL
  end
end
