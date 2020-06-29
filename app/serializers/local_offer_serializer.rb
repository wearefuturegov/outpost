class LocalOfferSerializer < ActiveModel::Serializer
    attributes :description
    attributes :link
    attributes :survey_answers

    def survey_answers
        object.survey_answers.map { |a| {
            question: object.questions.find{ |q| q[:id] === a["id"] }[:text],
            answer: a["answer"]
        }}
    end
end