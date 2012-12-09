class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :user_id
      t.string :repo_name, :owner, :owner_avatar_url, :description, :language, :homepage, :html_url, :full_name
      t.timestamps
    end
  end
end
