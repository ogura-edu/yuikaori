# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# CLEAR
User.delete_all
Member.delete_all

# CREATE
User.create(
  id:          1,
  email:       '272968442-twitter@example.com',
  password:    Devise.friendly_token,
  provider:    'twitter',
  uid:         '272968442',
  username:    'JAS',
  screen_name: 'justice_vsbr',
  image:       'https://pbs.twimg.com/profile_images/815809568265498628/d5L08luZ.jpg',
  admin:       true,
  approved:    true,
)
Member.create([
  { id: 1, name: 'ゆいかおり' },
  { id: 2, name: '小倉唯'     },
  { id: 3, name: '石原夏織'   },
])
