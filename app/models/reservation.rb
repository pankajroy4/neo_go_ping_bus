class Reservation < ApplicationRecord
  belongs_to :bus
  belongs_to :user
  belongs_to :seat
  validates :date, presence: { message: "should be given" }

  module Exception
    class InvalidTransaction < StandardError; end
  end

  def self.display_searched_date_seats(bus, date)
    bus.seats.joins(:reservations).where(reservations: { date: date }).distinct
  end

  def self.create_reservations(user_id, bus, seat_ids, date)
    return { success: false, errors: ["Select Date & Seats first!"] } if seat_ids.blank?
    return { success: false, errors: ["Bus must be approved to create a reservation"] } unless bus&.approved?
    return { success: false, errors: ["Date should not be in the past"] } if date.present? && date < Date.today

    existing_reservations = Reservation.where(bus_id: bus.id, date: date, seat_id: seat_ids)
    if existing_reservations.exists?
      return { success: false, errors: ["One or more seats are already booked"] }
    end

    reservations = seat_ids.map { |seat_id| Reservation.new(user_id: user_id, bus_id: bus.id, seat_id: seat_id, date: date) }

    errors = []
    begin
      ActiveRecord::Base.transaction do
        res = Reservation.import(reservations.compact, validate: true)
        if res.failed_instances.present?
          res.failed_instances.each do |invalid_record|
            errors << invalid_record.errors.full_messages
          end
          raise Exception::InvalidTransaction
        end
      end
    rescue Exception::InvalidTransaction
      return { success: false, errors: errors.flatten }
    end
    return {success: true, errors: errors.flatten}
  end
end
