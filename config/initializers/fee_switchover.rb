# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FEE_SWITCHOVER_TIME = ENV["FEE_SWITCHOVER_TIME"] && ENV["FEE_SWITCHOVER_TIME"].to_i != 0 && Time.at(ENV["FEE_SWITCHOVER_TIME"].to_i)
