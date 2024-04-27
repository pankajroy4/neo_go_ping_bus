# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create([{ name: "Admin", email: "a@gmail.com", password: "111111", password_confirmation: "111111", role: "admin", confirmed_at: Date.current }, { name: "Satyam Kumar", email: "b@gmail.com", password: "111111", password_confirmation: "111111", role: "user", confirmed_at: Date.current }, { name: "Ram Sah", email: "c@gmail.com", password: "111111", password_confirmation: "111111", role: "user", confirmed_at: Date.current }])

bus_owner1 = User.create(name: "Pankaj Roy", email: "d@gmail.com", password: "111111", password_confirmation: "111111", role: "bus_owner", confirmed_at: Date.current, registration_no: "PANKAJ964494")

bus_owner2 = User.create(name: "Angad Saxena", email: "e@gmail.com", password: "111111", password_confirmation: "111111", role: "bus_owner", confirmed_at: Date.current, registration_no: "ANGAD7328902")

Bus.create([
  { name: "Red Bus M14", registration_no: "MP-05CD4622", route: "Inodre - Bhopal", approved: true, user_id: bus_owner1.id, total_seat: 48 },
  { name: "RajHans Bus D96", registration_no: "DL-67GH7826", route: "Delhi - Banglore", approved: true, user_id: bus_owner1.id, total_seat: 45 },
  { name: "RajHans Bus H24", registration_no: "UP-98RD9673", route: "Prayagraj - Amarnath", approved: true, user_id: bus_owner1.id, total_seat: 42 },
  { name: "RajHans Bus A20", registration_no: "HR-42PN6736", route: "Gurugram - Nagpur", approved: true, user_id: bus_owner1.id, total_seat: 49 },
  { name: "Volvo Bus BM22", registration_no: "JK-78HY7836", route: "Kashmir - Kanyakumari", approved: true, user_id: bus_owner2.id, total_seat: 48 },
  { name: "Volvo Bus DF78", registration_no: "RJ-90YM5392", route: "Raipur - Kota", approved: true, user_id: bus_owner2.id, total_seat: 45 },
  { name: "Volvo Bus KG56", registration_no: "HP-52GD7390", route: "Shimla - Manali", approved: true, user_id: bus_owner2.id, total_seat: 42 },
  { name: "Volvo Bus BV34", registration_no: "UpP-33HY7839", route: "Chennai - Noida", approved: true, user_id: bus_owner2.id, total_seat: 49 },
])
