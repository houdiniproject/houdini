class RecaptchaRejectionsToJson < ActiveRecord::Migration
  def up
    RecaptchaRejection.where("details like ?", "%\\u0000%").destroy_all
    execute <<-SQL
      ALTER TABLE "recaptcha_rejections" ALTER COLUMN "details" TYPE jsonb USING details::jsonb
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "recaptcha_rejections" ALTER COLUMN "details" TYPE text USING details::text
    SQL
  end
end
