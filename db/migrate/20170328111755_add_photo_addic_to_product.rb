class AddPhotoAddicToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :photo_addic, :string
  end
end
