# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :campaign do
    profile
    nonprofit
    sequence(:name) { |i| "name #{i}" }
    sequence(:slug) { |i| "slug_#{i}" }

    factory :campaign_with_things_set_1 do
      main_image { File.open("spec/fixtures/test_nonprofit_logo.png") }
      background_image { File.open("spec/fixtures/test_nonprofit_logo.png") }
      banner_image { File.open("spec/fixtures/test_nonprofit_logo.png") }
      name { "Everything" }
      slug { "a-slug-of-slugs1" }
      tagline { "tagline 1" }
      body { "body 1" }
      video_url { "http://first-video-url.com" }
      receipt_message { "receipt message 1" }
      youtube_video_id { "1" }
      summary { "summary1" }
      goal_amount { 15000 }
      reason_for_supporting { "great reason 3" }
    end

    factory :campaign_with_things_set_2 do
      main_image { File.open("spec/fixtures/test_new_nonprofit_logo.png") }
      background_image { File.open("spec/fixtures/test_new_nonprofit_logo.png") }
      banner_image { File.open("spec/fixtures/test_new_nonprofit_logo.png") }
      name { "Everything2" }
      slug { "a-slug-of-slugs2" }
      tagline { "tagline 2" }
      body { "body 2" }
      video_url { "http://second-video-url.com" }
      receipt_message { "receipt message 2" }
      youtube_video_id { "2" }
      summary { "summary2" }
      goal_amount { 10000 }
      reason_for_supporting { "great reason 1" }
    end

    factory :empty_campaign do
      goal_amount { 20000 }
      reason_for_supporting { "great reason empty" }
    end
  end
end
