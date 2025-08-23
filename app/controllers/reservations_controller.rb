class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_approved, except: [:booking, :download_pdf, :destroy]

  def new
    @user = current_user
    @reservation = Reservation.new
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @available_seats = @bus.seats
    @booked_seats = Reservation.display_searched_date_seats(@bus, @date)
  end

  def create
    result = Reservations::Create.call(reservation_params)
    respond_to do |format|
      if result.success?
        notice_msg = "Booking successful!"
        format.html { redirect_to bookings_path(reservation_params[:user_id]), notice: notice_msg }
        format.turbo_stream { redirect_to bookings_path(reservation_params[:user_id]), notice: notice_msg }
        format.json { render json: { bookings: result.data, message: notice_msg } }
      else
        error_msg = result.errors.first
        flash[:alert] = error_msg
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = error_msg }
        format.json { render json: { errors: error_msg }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reservation = Reservation.find_by(id: params[:id])
    # @user = @reservation&.user
    authorize @reservation, policy_class: ReservationPolicy
    if @reservation.destroy
      respond_to do |format|
        format.html { redirect_to bookings_path(current_user.id), alert: "Ticket cancelled!." }
        format.turbo_stream { flash.now[:alert] = "Ticket Cancelled!." }
      end
    else
      respond_to do |format|
        format.html { redirect_to bookings_path(current_user.id), status: :unprocessable_entity, notice: "Ticket cancellation failed." }
        format.turbo_stream { render turbo_stream: { message: "Ticket cancellation failed.", status: :unprocessable_entity } }
      end
    end
  end

  def booking
    @bookings = Reservations::BookingsQuery.call(current_user)
    respond_to do |format|
      format.html { render :booking }
      format.json { render json: { bookings: @bookings, user: current_user.as_json(except: [:otp, :otp_sent_at]) } }
    end
  end

  # Not in Use
  def download_pdf
    subpath = "download_pdf"
    pdf = Reservations::GenerateTicketPdf.call(user: current_user, subpath: subpath)
    redirect_to rails_blob_url(pdf, disposition: "attachment")
  end

  # For direct Download:(currently in use)
  def download_pdf
    subpath = "download_pdf"
    pdf = Reservations::GenerateTicketPdf.call(user: current_user, subpath: subpath)
    file_name = "ticket-#{Time.zone.now.to_i}-#{current_user.id}.pdf"

    respond_to do |format|
      format.html do
        send_data(pdf, filename: file_name, type: "application/pdf", disposition: "attachment")
      end
    end
  end

  private

  def require_approved
    @bus = Bus.find(params[:bus_id])
    unless @bus.approved
      redirect_to root_path, alert: "Bus not approved yet!"
    end
  end

  def reservation_params
    params.require(:reservation).permit(:user_id, :bus_id, :date, seat_ids: [])
  end
end
