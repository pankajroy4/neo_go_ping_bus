module Reservations
  class BookingsQuery
    def self.call(user)
      new(user).process
    end

    def initialize(user)
      @user = user
    end

    def process
      @user.reservations
        .joins(:bus, :seat, :user)
        .group("reservations.id")
        .select(<<~SQL)
          reservations.id as r_id,
          MAX(users.name) as u_name,
          MAX(users.id) as u_id,
          MAX(seats.seat_no) as s_n,
          MAX(buses.name) as b_n,
          MAX(buses.id) as b_id,
          MAX(buses.registration_no) as b_r_n,
          MAX(buses.route) as b_r,
          MAX(reservations.date) as j_date
        SQL
        .map(&:attributes)
    end
  end
end

# @bookings = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id").select("reservations.id as r_id, MAX(users.name) as u_name, MAX(users.id) as u_id, MAX(seats.seat_no) as s_n, MAX(buses.name) as b_n, MAX(buses.id) as b_id, MAX(buses.registration_no) as b_r_n, MAX(buses.route) as b_r, MAX(reservations.date) as j_date").map { |r| r.attributes }
