module TaskListHelper

    def task_list_sections(custom_field_sections)
        sections = [
            [
              {
                title: "Name and description",
                key: "Name and description",
                description: "Set your service's name and description",
              },
              {
                title: "Website and social media",
                key: "Website and social media",
                description: "Add a link to your website and add links to your service's social media profiles or associated websites",
              },
              {
                title: "Visibility",
                key: "Visibility",
                description: "Set your service's visibility to the public, you can also show and hide your service on particular dates.",
              },
            ],
            [
              {
                title: "Locations",
                key: "Locations",
                description: "If your service has physical offices or places people can visit, add them here. You can add accessibility needs for each location here as well.",
              },
              {
                title: "Fees",
                key: "Fees",
                description: "Help people understand what your service costs. You can also let people know if your service is free.",
              },
              {
                title: "Opening and event times",
                key: "Opening times",
                description: "Adding opening or event times helps people understand when your service runs. You can also set your service to be temporarily closed here. If your service runs in multiple locations you can add different opening times for each location. ",
              },
              {
                title: "Contacts",
                key: "Contacts",
                description: "Add contact details for people or parts of your service.",
              },
              {
                title: "Ages",
                key: "Ages",
                description: "Use this section to show the age range this service can accommodate.",
              },
            ],
            [
              {
                title: "Special educational needs and disabilities",
                key: "Special educational needs and disabilities",
                description: "Is your service part of the SEND local offer? Explain how you can support people with special educational needs and disabilities here. Also known as the \"SEND local offer\".",
              },
              {
                title: "Suitable for",
                key: "Suitable for",
                description: "Who is this service suitable for? What needs does it meet?",
              },
            ],
          ]

        if custom_field_sections.length > 0
            sections.last << { 
                title: "Extra questions", 
                key: "Extra questions", 
                description: "This section contains additional questions about your service." 
            }
        end

        sections
    end

end