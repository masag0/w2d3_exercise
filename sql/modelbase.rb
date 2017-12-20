require 'sqlite3'
require_relative 'questions'
require 'byebug'

class ModelBase

  def self.find_by_id(id)
    inter = ""
    if self == Reply
      inter = "replies"
    elsif self == QuestionsFollow
      inter = "questions_follows"
    elsif self == QuestionLike
      inter = "question_likes"
    else
      inter = self.to_s + 's'
    end

    array = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
      #{inter}
    WHERE
    id = ?
    SQL
    array.empty? ? nil : self.new(array.first)
  end

  def self.where(options)
    inter = ""
    if self == Reply
      inter = "replies"
    elsif self == QuestionsFollow
      inter = "questions_follows"
    elsif self == QuestionLike
      inter = "question_likes"
    else
      inter = self.to_s + 's'
    end
    where = []
    options.each do |k, v|
      where += QuestionsDatabase.instance.execute(<<-SQL, v)
      SELECT
        *
      FROM
        #{inter}
      WHERE
        #{k} = ?
      SQL
    end
    where.uniq
  end

end
