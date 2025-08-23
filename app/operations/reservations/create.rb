module Reservations
  class Create
    def self.call(params)
      new(params).process
    end

    def initialize(params)
      @user_id = params[:user_id]
      @bus_id = params[:bus_id]
      @seat_ids = params[:seat_ids]
      @date = params[:date].is_a?(String) ? Date.parse(params[:date]) : params[:date]
      @bus = Bus.find_by(id: @bus_id)
    end

    def process
      return Result.failure("Select Date & Seats first!") if @seat_ids.blank?
      return Result.failure("Bus must be approved to create a reservation") unless @bus&.approved?
      return Result.failure("Date should not be in the past") if @date < Date.current
      return Result.failure("One or more seats are already booked") if already_booked?
      return Result.failure("Bus not found") unless @bus

      reservations = build_reservations
      errors = []
      ActiveRecord::Base.transaction do
        result = Reservation.import(reservations, validate: true)
        if result.failed_instances.any?
          errors = result.failed_instances.flat_map { |r| r.errors.full_messages }
          raise ActiveRecord::Rollback
        end
      end

      # begin
      #   ActiveRecord::Base.transaction do
      #     result = Reservation.import(reservations.compact, validate: true)
      #     if result.failed_instances.present?
      #       result.failed_instances.each do |invalid_record|
      #         errors << invalid_record.errors.full_messages
      #       end
      #       raise Exception::InvalidTransaction
      #     end
      #   end
      # rescue Exception::InvalidTransaction
      #   return Result.failure(errors)
      # end

      errors.any? ? Result.failure(errors) : Result.success(reservations)
    end

    private

    def build_reservations
      @seat_ids.map do |seat_id|
        Reservation.new(user_id: @user_id, bus_id: @bus_id, seat_id: seat_id, date: @date)
      end
    end

    def already_booked?
      Reservation.where(bus_id: @bus.id, date: @date, seat_id: @seat_ids).exists?
    end
  end
end
