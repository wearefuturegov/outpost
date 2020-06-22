class AddSurveyQuestionsToLocalOffer < ActiveRecord::Migration[6.0]
  def change
    add_column :local_offers, :survey_answers, :jsonb
  end
end
