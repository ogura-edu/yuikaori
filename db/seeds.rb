# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create( email: '272968442-twitter@example.com', password: Devise.friendly_token, provider: 'twitter', uid: '272968442', username: 'JAS', admin: true )

Member.create([{ member: 'ゆいかおり' }, { member: '小倉唯' }, { member: '石原夏織' }])
Event.create( event: '---------------' )
