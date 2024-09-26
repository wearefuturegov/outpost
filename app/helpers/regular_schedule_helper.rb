module RegularScheduleHelper

    def pretty_weekday(s)
        weekdays.select{ |w| w[:value] === s["weekday"]}.last[:label]
    end

end