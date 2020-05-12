class AddTopicToFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :topic, :string
  end
end
