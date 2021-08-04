# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

Tag.destroy_all
ActivityCategory.destroy_all
Activity.destroy_all
Day.destroy_all
Trip.destroy_all
Category.destroy_all
User.destroy_all

puts "creating fake users..."
4.times do |number|
  user = User.new(email: "email_#{number}@gmail.com", password: "password")
  user.save!
  puts "Creating user #{user.id}"

end

puts "creating fake categories..."
['Nature', 'Religion', 'Museum', 'Art', 'Music', 'History', 'Sport', 'Shopping', 'Unmatch'].each do |item|
category = Category.new(name: item)
category.save!
puts "Creating category #{category.id}"

end

puts "creating Amadeus tags..."
puts "reading csv file..."
csv_text = Rails.root.join('lib', 'seeds', 'tags_category.csv')
puts "parsing csv file..."
puts "Creating tags..."
CSV.foreach(csv_text, headers: true) do |row|
  tag = Tag.new
  tag.word = row[1]
  category = Category.find_by_name(row[0])
  tag.category = category if category
  tag.save!
  puts "Creating tag #{tag.id}"
end

puts "creating fake trips..."
User.all.sample(4).each do |user|
  future = [true, false].sample
  start_date = future ? Date.today + rand(1..5) : Date.today - rand(1..5)
  end_date = future ? Date.today + rand(6..10) : Date.today - rand(6..10)
  trip = Trip.new(
             city: ['Marseille', 'Paris', 'Lyon', 'Nice', 'Reims'].sample,
             start_date: start_date,
             end_date: end_date,
             favourite: false,
             user: user)
  trip.save!
  puts "Creating trip #{trip.id}"
end

puts "creating fake day, activies and activity categories..."
Trip.all.each do |trip|
  (trip.start_date..trip.end_date).to_a.each do |day|
    day = Day.new(
               date: day,
               trip: trip)
    day.save!
    puts "Creating day #{day.id}"

    rand(1..4).times do
      activity = Activity.new(
                 picture_url: 'https://images.unsplash.com/photo-1508180588132-ec6ec3d73b3f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80.png',
                 name: ['A Museum', 'B Museum', 'X park', 'X Sprt Ground', 'X Church'].sample,
                 description: 'This is a beatiful place.',
                 link: 'https://en.wikipedia.org/wiki/Rue_de_Rivoli',
                 address: ['Rue de Rivoli, 75001 Paris', "1 Rue de la Légion d'Honneur, 75007 Paris", "Cité Internationale, 81 Quai Charles de Gaulle, 69006 Lyon", "86 Quai Perrache, 69002 Lyon", '1 Esp. J4, 13002 Marseille', '84 Av. Georges Clemenceau, 51100 Reims'].sample,
                 favourite: false,
                 trip: trip,
                 day: day)
      activity.save!
      puts "Creating activity #{activity.id}"

      Category.all.sample(3).each do |category|
        activity_category = ActivityCategory.new(
                 activity: activity,
                 category: category)
        activity_category.save!
        puts "Creating activity_category #{activity_category.id}"

      end
    end
  end
end
