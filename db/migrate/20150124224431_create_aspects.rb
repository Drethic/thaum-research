class CreateAspects < ActiveRecord::Migration
  def change
    create_table :aspects do |t|
      t.string :aspect
      t.string :keywords
      t.string :component1
      t.string :component2
      t.string :sources

      t.timestamps
    end
  end
end
