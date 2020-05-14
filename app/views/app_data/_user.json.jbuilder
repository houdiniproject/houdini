json.extract! user, :id, :created_at, :updated_at
json.unconfirmed_email user.unconfirmed_email
json.confirmed user.confirmed?

json.partial! render 'app_data/profile', profile: user.profile
