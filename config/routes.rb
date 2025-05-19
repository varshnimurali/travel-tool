Rails.application.routes.draw do

  get("/", { :controller => "trip", :action => "show_form"})
  post("/form_results", { :controller => "trip", :action => "show_results"})

  
end
