class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_approved, except: [:booking, :download_pdf, :destroy]

  def new
    @user = current_user
    @reservation = Reservation.new
    @date = params[:date] || Date.today
    @available_seats = @bus.seats.all
    @booked_seats = Reservation.display_searched_date_seats(@bus, @date)
  end

  def create
    param = params[:reservation]
    bus_id = param[:bus_id]
    user_id = param[:user_id]
    seat_ids = param[:seat_ids]
    date = param[:date]
    parsed_date = Date.parse(date)
    res = Reservation.create_reservations(user_id, @bus, seat_ids, parsed_date)
    respond_to do |format|
      if (res[:success])
        format.html { redirect_to bookings_path(user_id), notice: "Booking successful!" }
        format.turbo_stream { redirect_to bookings_path(user_id), notice: "Booking successful!" }
        format.json { render json: { bookings: current_user.reservations, message: "Booking successfull!" } }
      else
        flash[:alert] = res[:errors][0]
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = res[:errors][0] }
        format.json { render json: { errors: res[:errors][0] }, status: :unprocessable_entity }
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
    # @user = params[:user_id]
    # @bookings = policy_scope(Reservation).includes(:seat, :bus, :user)  # Eager load associated records to avoid N+1 queries

    @bookings = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id").select("reservations.id as r_id, MAX(users.name) as u_name, MAX(users.id) as u_id, MAX(seats.seat_no) as s_n, MAX(buses.name) as b_n, MAX(buses.id) as b_id, MAX(buses.registration_no) as b_r_n, MAX(buses.route) as b_r, MAX(reservations.date) as j_date").map { |r| r.attributes }

    respond_to do |format|
      format.html { render :booking }
      format.json { render json: { bookings: @bookings, user: current_user.as_json(except: [:otp, :otp_sent_at]) } }
    end
  end

  # def download_pdf
  #   subpath = "download_pdf"
  #   reservations = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id").select("reservations.id as r_id, users.name as u_name, seats.seat_no as s_n, buses.name as b_n, buses.registration_no as b_r_n, buses.route as b_r, reservations.date as j_date").map { |r| r.attributes }

  #   data = WickedPdf.new.pdf_from_string(
  #     render_to_string(
  #       "reservations/#{subpath}",
  #       layout: "layouts/pdf_bg", locals: { user: current_user, reservations: reservations },
  #     ),
  #     header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
  #     footer: { right: "Thank You!", left: "Have a safe journey!" },
  #   )
  #   file_name = "ticket-#{Time.zone.now.to_i}-#{current_user.id}"
  #   save_path = Tempfile.new("your_bookings-#{Time.zone.now.to_i}-#{current_user.id}.pdf")
  #   File.open(save_path, "wb") do |file|
  #     file << data
  #   end
  #   current_user.ticket_pdf.purge if current_user.ticket_pdf.present?
  #   current_user.ticket_pdf.attach(io: File.open(save_path.path), filename: "#{file_name}.pdf", content_type: "pdf")
  #   save_path.unlink
  #   redirect_to rails_blob_url(current_user.ticket_pdf, disposition: "attachment")
  # end

  # def download_pdf
  #   subpath = "download_pdf"
  #   reservations = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id").select("reservations.id as r_id, users.name as u_name, seats.seat_no as s_n, buses.name as b_n, buses.registration_no as b_r_n, buses.route as b_r, reservations.date as j_date").map { |r| r.attributes }

  #   pdf_data = render_to_string(
  #     "reservations/#{subpath}",
  #     layout: "layouts/pdf_bg", locals: { user: current_user, reservations: reservations },
  #   )

  #   pdf_options = {
  #     header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
  #     footer: { right: "Thank You!", left: "Have a safe journey!" },
  #   }

  #   pdf = WickedPdf.new.pdf_from_string(pdf_data, pdf_options)

  #   temp_file = Tempfile.new(["ticket", ".pdf"])
  #   temp_file.binmode
  #   temp_file.write(pdf)
  #   temp_file.rewind

  #   current_user.ticket_pdf.attach(io: temp_file, filename: "ticket-#{Time.zone.now.to_i}-#{current_user.id}.pdf", content_type: "application/pdf")

  #   temp_file.close
  #   temp_file.unlink

  #   redirect_to rails_blob_url(current_user.ticket_pdf, disposition: "attachment")
  # end

  # For direct Download:
  def download_pdf
    subpath = "download_pdf"
    reservations = current_user.reservations.joins(:bus, :seat, :user).group("reservations.id, users.name, seats.seat_no, buses.name, buses.registration_no, buses.route, reservations.date ").select("reservations.id as r_id, users.name as u_name, seats.seat_no as s_n, buses.name as b_n, buses.registration_no as b_r_n, buses.route as b_r, reservations.date as j_date").map { |r| r.attributes }

    respond_to do |format|
      format.html do
        data = WickedPdf.new.pdf_from_string(
          render_to_string(
            "reservations/#{subpath}",
            layout: "layouts/pdf_bg", locals: { user: current_user, reservations: reservations },
          ),
          header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
          footer: { right: "Thank You", left: "Have a safe journey" },
        )

        file_name = "ticket-#{Time.zone.now.to_i}-#{current_user.id}"
        send_data(data, filename: file_name, type: "application/pdf", disposition: "attachment")
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
end
