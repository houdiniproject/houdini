class RemoveVerificationStatusOnNonprofit < ActiveRecord::Migration
  def up
    create_table :nonprofit_verification_backups do |t|
      t.string :verification_status
    end
    execute <<-SQL
      INSERT INTO nonprofit_verification_backups SELECT id, verification_status from nonprofits
    SQL
    remove_column :nonprofits, :verification_status
  end

  def down
    add_column :nonprofits, :verification_status, :string
    execute <<-SQL
      UPDATE nonprofits SET (verification_status) = (SELECT verification_status from nonprofit_verification_backups WHERE nonprofits.id = nonprofit_verification_backups.id)
    SQL

    drop_table :nonprofit_verification_backups
  end
end
