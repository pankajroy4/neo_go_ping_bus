module Reservations
  class PdfDetailsQuery
    def self.call(user)
      new(user).process
    end

    def initialize(user)
      @user = user
    end

    def process
      @user.reservations
        .joins(:bus, :seat, :user)
        .group(<<-SQL)
        reservations.id, 
        users.name, 
        seats.seat_no, 
        buses.name, 
        buses.registration_no, 
        buses.route, 
        reservations.date
      SQL
        .select(<<-SQL)
        reservations.id as r_id,
        users.name as u_name,
        seats.seat_no as s_n,
        buses.name as b_n,
        buses.registration_no as b_r_n,
        buses.route as b_r,
        reservations.date as j_date
      SQL
    end
  end
end

# reservations = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id, users.name, seats.seat_no, buses.name, buses.registration_no, buses.route, reservations.date ").select("reservations.id as r_id, users.name as u_name, seats.seat_no as s_n, buses.name as b_n, buses.registration_no as b_r_n, buses.route as b_r, reservations.date as j_date").map { |r| r.attributes }
