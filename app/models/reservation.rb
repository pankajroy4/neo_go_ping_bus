class Reservation < ApplicationRecord
  belongs_to :bus
  belongs_to :user
  belongs_to :seat
  validates :date, presence: { message: "should be given" }

  module Exception
    class InvalidTransaction < StandardError; end
  end

  def self.display_searched_date_seats(bus, date)
    return Seat.none if date < Date.current
    bus.seats.joins(:reservations).where(reservations: { date: date }).distinct
  end
end
