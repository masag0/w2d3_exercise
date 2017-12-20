require 'sqlite3'
require_relative 'question'
require_relative 'questionsfollow'
require_relative 'reply'
require_relative 'user'
require_relative 'questions'
require_relative 'modelbase'


class QuestionLike < ModelBase
  attr_accessor :question_id, :user_id
  attr_reader :id


  # def self.find_by_id(id)
  #   question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #   *
  #   FROM
  #   question_likes
  #   WHERE
  #   id = ?
  #   SQL
  #   question_like.empty? ? nil : QuestionLike.new(question_like.first)
  # end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    likers.map { |liker| User.new(liker) }
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*) AS Count
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    likes.first['Count']
  end

  def self.liked_questions_for_user(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    WHERE
      questions.id IN (
        SELECT
          question_likes.question_id
        FROM
          users
        JOIN
          question_likes ON question_likes.user_id = users.id
        WHERE
          question_likes.user_id = ?
      )
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT questions.id, questions.title, questions.body, questions.user_id
    FROM questions
    JOIN question_likes ON question_likes.question_id = questions.id
    GROUP BY questions.id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options ['question_id']
    @user_id = options['user_id']
  end



end
