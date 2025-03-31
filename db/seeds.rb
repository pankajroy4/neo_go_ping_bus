User.create([{ name: "Admin", email: "my@gmail.com", password: "111111", password_confirmation: "111111", role: "admin", confirmed_at: Date.current }, { name: "Satyam Kumar", email: "b@gmail.com", password: "111111", password_confirmation: "111111", role: "user", confirmed_at: Date.current }, { name: "Ram Sah", email: "c@gmail.com", password: "111111", password_confirmation: "111111", role: "user", confirmed_at: Date.current }])

bus_owner1 = User.create(name: "Pankaj Roy", email: "my@gmail.com", password: "111111", password_confirmation: "111111", role: "bus_owner", confirmed_at: Date.current, registration_no: "PANKAJ964494")

bus_owner2 = User.create(name: "Angad Saxena", email: "my@gmail.com", password: "111111", password_confirmation: "111111", role: "bus_owner", confirmed_at: Date.current, registration_no: "ANGAD7328902")

buses = Bus.create!([
  { name: "Red Bus M14", registration_no: "MP-05CD4622", route: "Indore - Bhopal", approved: true, user_id: bus_owner1.id, total_seat: 48 },
  { name: "RajHans Bus D96", registration_no: "DL-67GH7826", route: "Delhi - Bangalore", approved: true, user_id: bus_owner1.id, total_seat: 45 },
  { name: "RajHans Bus H24", registration_no: "UP-98RD9673", route: "Prayagraj - Amarnath", approved: true, user_id: bus_owner1.id, total_seat: 42 },
  { name: "RajHans Bus A20", registration_no: "HR-42PN6736", route: "Gurugram - Nagpur", approved: true, user_id: bus_owner1.id, total_seat: 49 },
  { name: "Volvo Bus BM22", registration_no: "JK-78HY7836", route: "Kashmir - Kanyakumari", approved: true, user_id: bus_owner2.id, total_seat: 48 },
  { name: "Volvo Bus DF78", registration_no: "RJ-90YM5392", route: "Raipur - Kota", approved: true, user_id: bus_owner2.id, total_seat: 45 },
  { name: "Volvo Bus KG56", registration_no: "HP-52GD7390", route: "Shimla - Manali", approved: true, user_id: bus_owner2.id, total_seat: 42 },
  { name: "Volvo Bus BV34", registration_no: "UP-33HY7839", route: "Chennai - Noida", approved: true, user_id: bus_owner2.id, total_seat: 49 }
])

image_files = [
  "seeds_images/bus1.png",
  "seeds_images/bus3.png",
  "seeds_images/bus4.png",
  "seeds_images/bus2.png",
  "seeds_images/bus6.png",
  "seeds_images/bus7.png",
  "seeds_images/bus8.png",
  "seeds_images/bus10.png"
]

buses.each_with_index do |bus, index|
  image_path = Rails.root.join(image_files[index])

  if File.exist?(image_path)
    bus.main_image.attach(
      io: File.open(image_path),
      filename: File.basename(image_path),
      content_type: "image/png"
    )
  end
end

puts "Seed data added successfully!"