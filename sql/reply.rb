require 'sqlite3'
require_relative 'question'
require_relative 'questionsfollow'
require_relative 'questions'
require_relative 'user'
require_relative 'questionlike'
require_relative 'modelbase'

class Reply < ModelBase
  attr_accessor :body, :question_id, :reply_id, :user_id
  attr_reader :id


  # def self.find_by_id(id)
  #   reply = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #   *
  #   FROM
  #   replies
  #   WHERE
  #   id = ?
  #   SQL
  #   reply.empty? ? nil : Reply.new(reply.first)
  # end

  def self.find_by_user_id(user_id)
    replys = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT *
    FROM replies
    WHERE user_id = ?
    SQL

    replys.empty? ? nil : replys.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replys = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT *
    FROM replies
    WHERE question_id = ?
    SQL
    replys.empty? ? nil : replys.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options ['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
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

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
    SELECT
      *
    FROM
      questions
    WHERE id = ?
    SQL
    Question.new(question.first)
  end

  def parent_reply
    raise "no parent exists" if @reply_id.nil?
    parent = QuestionsDatabase.instance.execute(<<-SQL, @reply_id)
    SELECT
      *
    FROM
      replies
    WHERE id = ?
    SQL
    Reply.new(parent.first)
  end

  def child_replies
    children = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE reply_id = ?
    SQL
    raise "no children exist" if children.empty?
    children.map { |child| Reply.new(child) }
  end

  def save
    update if @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @reply_id, @user_id)
    INSERT INTO
      replies (body, question_id, reply_id, user_id)
    VALUES
      (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "does not exist" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @reply_id, @user_id, @id)
    UPDATE
      replies
    SET
      body = ?, question_id = ?, reply_id = ?, user_id = ?
    WHERE
      id = ?
    SQL
  end
end
