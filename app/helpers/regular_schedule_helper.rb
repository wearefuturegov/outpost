module RegularScheduleHelper

    def pretty_weekday(s)
        weekdays.select{ |w| w[:value] === s["weekday"]}.last[:label]
    end

    def weekdays
        [
            {
                label: "Monday",
                value: 1
            },
            {
                label: "Tuesday",
                value: 2
            },
            {
                label: "Wednesday",
                value: 3
            },
            {
                label: "Thursday",
                value: 4
            },
            {
                label: "Friday",
                value: 5
            },
            {
                label: "Saturday",
                value: 6
            },
            {
                label: "Sunday",
                value: 7
            },
        ]
    end

end