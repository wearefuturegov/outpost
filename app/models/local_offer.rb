class LocalOffer < ApplicationRecord
  belongs_to :service

  validates :description, presence: true

  serialize :survey_answers

  def questions
    [
      "What outcomes does your setting, service or activity aim to achieve for children and young people with SEND and their families?",
      "What recent SEND-specific training has been completed by your staff and/or volunteers?",
      "How do you involve parents and how can I get involved?",
      "How will you share information with me about my child’s progress? What is additional for children with SEND?",
      "How accessible is the environment (indoors and outdoors)?",
      "How can children & young people with SEND and their families start to use your service or activity?",
      "What future plans do you have for developing your SEND provision?",
    ]
  end
end
