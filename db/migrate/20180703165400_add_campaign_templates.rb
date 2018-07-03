class AddCampaignTemplates < ActiveRecord::Migration
  def change
    create_table :campaign_templates do |t|
      t.string :template_name, null: false
  		t.string :name
  		t.string :tagline
  		t.integer :goal_amount
  		t.string :main_image
  		t.text :video_url
  		t.string :vimeo_video_id
  		t.string :youtube_video_id
  		t.text :summary
  		t.text :body

      t.timestamps
    end

    change_table :campaigns do |t|
      t.references :campaign_template
    end
  end
end
