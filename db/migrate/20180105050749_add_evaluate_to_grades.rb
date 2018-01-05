class AddEvaluateToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :evaluate_score, :integer
    add_column :grades, :class_score, :integer
    add_column :grades, :homework_score, :integer
    add_column :grades, :difficulty_score, :integer
    add_column :grades, :harvest_score, :integer
  end
end
