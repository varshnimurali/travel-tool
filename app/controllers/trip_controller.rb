class TripController < ApplicationController

  def show_form
    render({ :template => "templates/new_form" })
  end

  def show_results
    @the_image = params.fetch("image_param", "")
    @the_start_date = params.fetch("start_date_param", "")
    @the_end_date = params.fetch("end_date_param", "")
    @the_origin = params.fetch("origin_param", "")
    @the_transport = params.fetch("transport_param", [])
    @the_budget = params.fetch("budget_param", "")
    @the_description = params.fetch("description_param", "")
    
    c = OpenAI::Chat.new
    c.system("You are an expert travel advisor. The user will provide you with a start date, end date, origin city, preferred mode of transportation, budget, and any other preferences they have for the trip. Your job is to take all these considerations and create three different options for itineraries with recommended destinations, options for accommodations, and comprehensive activities separated by each day (keeping in mind the time of the year and the overall duration of the trip). You should also add an estimated cost for each itinerary option.")
    c.user(@the_start_date)
    c.user(@the_end_date)
    c.user(@the_origin)
    c.user("Preferred transportation mode(s): #{@the_transport.join(', ')}")
    c.user(@the_budget)
    c.user(@the_description)
    c.schema = '{
      "name": "travel_itineraries",
      "schema": {
        "type": "object",
        "properties": {
          "start_date": {
            "type": "string",
            "description": "The starting date of the trip."
          },
          "end_date": {
            "type": "string",
            "description": "The ending date of the trip."
          },
          "origin_city": {
            "type": "string",
            "description": "The city where the user will start their trip."
          },
          "transportation_mode": {
            "type": "string",
            "description": "Preferred mode of transportation for the trip."
          },
          "budget": {
            "type": "number",
            "description": "The total budget allocated for the trip."
          },
          "preferences": {
            "type": "object",
            "description": "Additional preferences for the trip.",
            "properties": {
              "accommodation_type": {
                "type": "string",
                "description": "Type of accommodation preferred."
              },
              "activity_preferences": {
                "type": "array",
                "description": "List of preferred activities.",
                "items": {
                  "type": "string"
                }
              }
            },
            "required": [
              "accommodation_type",
              "activity_preferences"
            ],
            "additionalProperties": false
          },
          "itineraries": {
            "type": "array",
            "description": "Different itinerary options based on user preferences.",
            "items": {
              "type": "object",
              "properties": {
                "destinations": {
                  "type": "array",
                  "description": "Recommended destinations for the itinerary.",
                  "items": {
                    "type": "string"
                  }
                },
                "accommodations": {
                  "type": "array",
                  "description": "Options for accommodations.",
                  "items": {
                    "type": "string"
                  }
                },
                "activities": {
                  "type": "array",
                  "description": "Activities included in the itinerary, broken down into granular details for each day of the trip (calculated by end_date minus start_date).",
                  "items": {
                    "type": "string"
                  }
                },
                "estimated_cost": {
                  "type": "number",
                  "description": "Estimated cost of the itinerary."
                }
              },
              "required": [
                "destinations",
                "accommodations",
                "activities",
                "estimated_cost"
              ],
              "additionalProperties": false
            }
          }
        },
        "required": [
          "start_date",
          "end_date",
          "origin_city",
          "transportation_mode",
          "budget",
          "preferences",
          "itineraries"
        ],
        "additionalProperties": false
      },
      "strict": true
    }'
    @structured_output = c.assistant!
    
    @itineraries = @structured_output.fetch("itineraries", [])

    render({ :template => "templates/form_results"})
  end

end
