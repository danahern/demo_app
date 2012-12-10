class AddRecommendationsGeneratedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recommendations_generated_at, :datetime
  end
end