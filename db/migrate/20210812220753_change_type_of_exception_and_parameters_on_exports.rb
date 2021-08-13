class ChangeTypeOfExceptionAndParametersOnExports < ActiveRecord::Migration[6.1]
  def change
    change_column :exports, :exception, :text
    change_column :exports, :parameters, :text
  end
end
