<p align="center">
    <a href="https://outpost-staging.herokuapp.com/">
        <img src="https://github.com/wearefuturegov/outpost/blob/master/app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>         
</p>

---

# 💿 Data Import

There are two files included in this repository, [data-import--with-sample-data.csv](./data-import--with-sample-data.csv) and [data-import.csv](./data-import.csv). These files will allow you to run an initial import of your data to Outpost. 

* Each row in the document must have a unique numeric ID `import_id`. If this ID is missing the import script will not run.
* `name` - If there are duplicate service names - the script will output an error
* `organisation` - If no organisation exists by this name we will create it
* `organisation` - If this field is blank then we will create an Unnamed organisation for this service
* `visible` - If `visible_from` and `visible_to` are set then this field will be set to `FALSE`


**Multiple Rows**   
Some services can have multiple pieces of data assigned to them. `locations`, `cost`, `schedule`, `links` and `contacts`
In order to add multiple locations to a service you would create one entry for your service with the first location in that row. In order to add the second location you would create a new row, with the `import_id_reference` equal to the service row you created. You then fill in the columns with the additional data. 


## 🏠 Data structure

| Field title                                                                                                                       | Data format  | Description  | multiple rows | additional Info |
|---------------------------------------------------------------------------------------------------------------------------------|---|---|---|---|
| import_id                                                                                                                       | Int **unique**  | A unique number to reference this service for additional data  |  |
| import_id_reference                                                                                                             | Int  |  This field must correspond to the `import_id` of the service you are targetting  |  |  |
| name                                                                                                                            | String **unique**  |  The name of the service, activity or event |  |  |
| description                                                                                                                     | Text  |  A description of your service. Note that in some places this will be truncated. |  |  |
| organisation                                                                                                                    | String  | Name of the organisation, if no organisation exists by this name we will create it. This field can be left blank.  |  |  |
| url                                                                                                                             | String beginning with http or https  | The url of this service  |  |  |
| approved                                                                                                                        | Boolean  | TRUE or FALSE value to say whether this service has been approved. If this is set to false the service is shown as pending and requires an admin to verify the data.  |  |  |
| visible_from                                                                                                                    | Datetime YYYY-MM-DD (2022-05-17)  | Indicates the date from which this service becomes visible. Used on certain frontend applications to hide services that are not relevant at the time  |  |  |
| visible_to                                                                                                                      | Datetime YYYY-MM-DD (2022-05-17)  |   |  |  |
| visible                                                                                                                         |  Boolean | If true this service can be hidden on the frontend. `visible_from` and `visible_to` override this  |  |  |
| needs_referral                                                                                                                  | Boolean  |  Does this service require a referral in order to access it |  |  |
| min_age                                                                                                                         | Int  |  Can be left blank. Minimum age this service is suitable for. |  |  |
| max_age                                                                                                                         | Int  |  Can be left blank. Maximum age this service is suitable for. |  |  |
| notes                                                                                                                           | Text  |  Any internal notes about this service |  |  |
| service_taxonomies                                                                                                              |  Comma delimited list | A list of values you wish to use as taxonomies, hierarchy is not applied here.  |  |  |
| contact_name                                                                                                                    | String  | Name of the contact for this service | TRUE |  |
| contact_title                                                                                                                   |  String | The role of the contact you are creating  | TRUE |  |
| contact_visible                                                                                                                 |  Boolean | Is this contact visible through the API  | TRUE |  |
| contact_email                                                                                                                   | String (email)  | Contact email address  | TRUE |  |
| contact_phone                                                                                                                   | String (phone) |  Contact phone number | TRUE |  |
| location_name                                                                                                                   | String  | Name of location  | TRUE |  |
| location_latitude                                                                                                               | Float (15.1022 or -1.20202) | Latitude for location  | TRUE |  |
| location_longitude                                                                                                              | Float (15.1022 or -1.20202) | Longitude for location  | TRUE |  |
| location_address_1                                                                                                              |  String | Address line 1  | TRUE |  |
| location_city                                                                                                                   | String  |  City | TRUE |  |
| location_postcode                                                                                                               | String  | Postcode  | TRUE |  |
| location_visible                                                                                                                | Boolean  | Is this location sent through to the api  | TRUE  |  |
| mask_exact_address                                                                                                              | Boolean  | If this is someones home address or a sensitive location mask the address so only the general area is found  | TRUE |  |
| preferred_for_post                                                                                                              | Boolean  |  Use this address as the preferred postal location for this service | TRUE |  |
| location_accessibilities                                                                                                        | Comma delimited list  | Accessibilities provided by this location  | TRUE |  |
| free                                                                                                                            | Boolean  | Is this service free to use  |  |  |
| cost_option                                                                                                                     |   |   |  |  |
| cost_amount                                                                                                                     |   |   |  |  |
| cost_type                                                                                                                       |   |   |  |  |
| temporarily_closed                                                                                                              |   |   |  |  |
| schedules_opens_at                                                                                                              |   |   |  |  |
| schedules_closes_at                                                                                                             |   |   |  |  |
| scheduled_weekday                                                                                                               |   |   |  |  |
| links_label                                                                                                                     |   |   |  |  |
| links_url                                                                                                                       |   |   |  |  |
| labels                                                                                                                          |   |   |  |  |
| suitabilities                                                                                                                   |   |   |  |  |
| is_local_offer                                                                                                                  |   |   |  |  |
| Which SEND needs can you support?                                                                                               |   |   |  |  |
| Description of support provided                                                                                                 |   |   |  |  |
| Link to most recent SEND report                                                                                                 |   |   |  |  |
| What outcomes does your setting, service or activity aim to achieve for children and young people with SEND and their families? |   |   |  |  |
| What recent SEND-specific training has been completed by your staff and/or volunteers?                                          |   |   |  |  |
| How do you involve parents and how can I get involved?                                                                          |   |   |  |  |
| How will you share information with me about my child’s progress? What is additional for children with SEND?                    |   |   |  |  |
| How accessible is the environment (indoors and outdoors)?                                                                       |   |   |  |  |
| How can children and young people with SEND and their families start to use your service or activity?                           |   |   |  |  |
| What future plans do you have for developing your SEND provision?                                                               |   |   |  |  |


## Hints and Tips

If you are using google sheets you can dynamically create lists to track data you have inputted into certain fields. This will help you track down any typos and refine your data further.

This is useful for Organisations, Taxonomies, Suitabilities, Accessibilities, Labels and SEND needs. 

This formula will take all data from the 2nd row to infinity and create a unique list based off all the comma delimited lists you have entered.


```
=ArrayFormula(transpose(trim(split(TEXTJOIN(",",true,'Service Data'!O2:O),","))))
```


## TODO

- [ ] update .csv with final column titles once decided