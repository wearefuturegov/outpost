module FeedbacksHelper

    def feedback_topics
        [
           {
                label: "Something is out of date",
                value: "out-of-date"
           },
           {
                label: "I have extra information to add",
                value: "extra-information-to-add"
           },
           {
                label: "The service is closed",
                value: "service-has-closed"
           },
           {
               label: "Something else",
               value: "something-else"
           }
         ]
    end

    def pretty_topic(topic)
        if topic
            topic.gsub('-', ' ').capitalize
        else
            "No topic"
        end
    end

end