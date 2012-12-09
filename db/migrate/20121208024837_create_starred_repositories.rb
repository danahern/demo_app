class CreateStarredRepositories < ActiveRecord::Migration
  def change
    create_table :starred_repositories do |t|
      t.integer :user_id
      t.string :repo_name, :owner, :owner_avatar_url, :description, :language, :homepage, :html_url, :full_name
      t.timestamps
    end
  end
end
