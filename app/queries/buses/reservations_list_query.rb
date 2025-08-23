module Buses
  class ReservationsListQuery
    def self.call(bus, date)
      Reservation
        .joins(:bus, :seat, :user)
        .where(reservations: { date: date, bus_id: bus.id })
        .group("reservations.id")
        .select(<<~SQL)
          reservations.id AS r_id,
          MAX(users.name) AS u_name,
          MAX(users.id)   AS u_id,
          MAX(seats.seat_no) AS s_n,
          MAX(seats.id)   AS s_id
        SQL
        .map(&:attributes)
    end
  end
end
