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
    c.system("You are an expert travel advisor. The user will provide you with a start date, end date, origin city, preferred mode of transportation, budget, and any other preferences they have for the trip. Your job is to take all these considerations and create three different options for itineraries with recommended destinations, options for accommodations, and activities. You should also add an estimated cost for each itinerary option.")
    c.user(@the_start_date)
    c.user(@the_end_date)
    c.user(@the_origin)
    c.user("Preferred transportation mode(s): #{@the_transport.join(', ')}")
    c.user(@the_budget)
    c.user(@the_description)
    c.schema = '{
    "name": "trip_itineraries",
    "schema": {
      "type": "object",
      "properties": {
        "origin_city": {
          "type": "string",
          "description": "The origin city from which the trip will start."
        },
        "preferred_mode_of_transportation": {
          "type": "string",
          "description": "The mode of transportation preferred for the trip."
        },
        "budget": {
          "type": "number",
          "description": "The budget allocated for the trip."
        },
        "preferences": {
          "type": "object",
          "description": "Any other preferences for the trip.",
          "properties": {
            "accommodation_type": {
              "type": "string",
              "description": "Type of accommodation preferred (e.g., hotel, hostel, apartment)."
            },
            "activities": {
              "type": "array",
              "description": "List of preferred activities during the trip.",
              "items": {
                "type": "string"
              }
            }
          },
          "required": [
            "accommodation_type",
            "activities"
          ],
          "additionalProperties": false
        },
        "itinerary_options": {
          "type": "array",
          "description": "Different options for itineraries based on the user preferences.",
          "items": {
            "type": "object",
            "properties": {
              "destinations": {
                "type": "array",
                "description": "Recommended destinations for this itinerary option.",
                "items": {
                  "type": "string"
                }
              },
              "accommodation": {
                "type": "string",
                "description": "Recommended options for accommodation."
              },
              "activities": {
                "type": "array",
                "description": "Recommended activities for this itinerary option.",
                "items": {
                  "type": "string"
                }
              },
              "estimated_cost": {
                "type": "number",
                "description": "Estimated cost for this itinerary option."
              }
            },
            "required": [
              "destinations",
              "accommodation",
              "activities",
              "estimated_cost"
            ],
            "additionalProperties": false
          }
        }
      },
      "required": [
        "origin_city",
        "preferred_mode_of_transportation",
        "budget",
        "preferences",
        "itinerary_options"
      ],
      "additionalProperties": false
    },
    "strict": true
  }'
    @structured_output = c.assistant!

    @results_itinerary_options = @structured_output.fetch("itinerary_options", [])

    render({ :template => "templates/form_results"})
  end

end
