require 'sqlite3'
require_relative 'question'
require_relative 'questions'
require_relative 'reply'
require_relative 'user'
require_relative 'questionlike'
require_relative 'modelbase'


class QuestionsFollow < ModelBase
  attr_accessor :user_id, :question_id
  attr_reader :id


  # def self.find_by_id(id)
  #   question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #   *
  #   FROM
  #   questions_follows
  #   WHERE
  #   id = ?
  #   SQL
  #   question_follow.empty? ? nil : QuestionFollow.new(question_follow.first)
  # end

  def self.followers_for_question_id(question_id)
    question_followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT DISTINCT users.id, users.fname, users.lname
    FROM users
    JOIN questions_follows ON users.id = questions_follows.user_id
    JOIN questions ON questions_follows.user_id = questions.user_id
    WHERE questions.id = ?
    SQL

    question_followers += QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT DISTINCT users.id, users.fname, users.lname
    FROM users
    JOIN replies ON replies.user_id = users.id
    WHERE replies.question_id = ?
    SQL

    raise "no followers" if question_followers.empty?
    question_followers.uniq.map { |question_follower| User.new(question_follower) }
  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT DISTINCT questions.id, questions.title, questions.body, questions.user_id
    FROM users
    JOIN questions_follows ON users.id = questions_follows.user_id
    JOIN questions ON questions_follows.user_id = questions.user_id
    WHERE users.id = ?
    SQL

    followed_questions += QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT DISTINCT questions.id, questions.title, questions.body, questions.user_id
    FROM questions
    JOIN replies ON replies.question_id = questions.id
    WHERE replies.user_id = ?
    SQL
    raise "no followers" if followed_questions.empty?
    followed_questions.uniq.map { |followed_question| Question.new(followed_question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT questions.id, questions.title, questions.body, questions.user_id
    FROM questions
    LEFT JOIN replies ON replies.question_id = questions.id
    GROUP BY questions.id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options ['question_id']
  end

end
