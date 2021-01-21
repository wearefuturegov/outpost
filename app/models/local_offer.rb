class LocalOffer < ApplicationRecord
  belongs_to :service

  attr_accessor :skip_description_validation
  validates :description, presence: true, unless: :skip_description_validation

  def questions
    [
        { id: 1, text: "What outcomes does your setting, service or activity aim to achieve for children and young people with SEND and their families?" },
        { id: 2, text: "What recent SEND-specific training has been completed by your staff and/or volunteers?" },
        { id: 3, text: "How do you involve parents and how can I get involved?" },
        { id: 4, text: "How will you share information with me about my child’s progress? What is additional for children with SEND?" },
        { id: 5, text: "How accessible is the environment (indoors and outdoors)?" },
        { id: 6, text: "How can children and young people with SEND and their families start to use your service or activity?" },
        { id: 7, text: "What future plans do you have for developing your SEND provision?" },
    ]
  end
end
