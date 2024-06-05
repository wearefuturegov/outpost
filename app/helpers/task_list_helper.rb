module TaskListHelper

    def task_list_sections(custom_field_sections)
        sections = [
            [
                "Name and description",
                "Website and social media",
                "Visibility",
            ],
            [
                "Opening times",
                "Fees",
                "Locations",
                "Contacts",
                "Ages"
            ],
            [
                "Special educational needs and disabilities",
                "Suitable for"
            ]
        ]

        sections.last << "Extra questions" if custom_field_sections.length > 0

        sections
    end

end