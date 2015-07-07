ActiveRecord::Schema.define(version: 20140407140000) do
  create_table 'posts', force: true do |t|
    t.text 'title'
    t.text 'body'
  end
end
