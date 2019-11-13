class CreateRecaptchaRejections < ActiveRecord::Migration
  def change
    create_table :recaptcha_rejections do |t|
      t.text :details
      t.timestamps
    end
  end
end
