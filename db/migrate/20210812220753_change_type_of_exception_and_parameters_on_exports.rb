class ChangeTypeOfExceptionAndParametersOnExports < ActiveRecord::Migration
  def change
    change_column :exports, :exception, :text
    change_column :exports, :parameters, :text
  end
end
