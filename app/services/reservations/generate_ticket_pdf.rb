#For Direct download
module Reservations
  class GenerateTicketPdf
    def self.call(user:, subpath: "download_pdf")
      new(user, subpath).process
    end

    def initialize(user, subpath)
      @user = user
      @subpath = subpath
    end

    def process
      reservations = Reservations::PdfDetailsQuery.call(@user)

      WickedPdf.new.pdf_from_string(
        ActionController::Base.new.render_to_string(
          template: "reservations/#{@subpath}",
          layout: "layouts/pdf_bg",
          locals: { user: @user, reservations: reservations },
        ),
        header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
        footer: { right: "Thank You", left: "Have a safe journey" },
      )
    end
  end
end

# #Not in Use
# module Reservations
#   class GenerateTicketPdf
#     def self.call(user:, subpath: "download_pdf")
#       new(user, subpath).process
#     end

#     def initialize(user, subpath)
#       @user = user
#       @subpath = subpath
#     end

#     def process
#       reservations = Reservations::PdfDetailsQuery.call(@user)

#       pdf_data = ActionController::Base.new.render_to_string(
#         template: "reservations/#{@subpath}",
#         layout: "layouts/pdf_bg",
#         locals: { user: @user, reservations: reservations },
#       )

#       pdf_options = {
#         header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
#         footer: { right: "Thank You!", left: "Have a safe journey!" },
#       }

#       pdf_file = WickedPdf.new.pdf_from_string(pdf_data, pdf_options)
#       attach_pdf(pdf_file)
#     end

#     private

#     def attach_pdf(pdf_file)
#       temp_file = Tempfile.new(["ticket", ".pdf"])
#       temp_file.binmode
#       temp_file.write(pdf_file)
#       temp_file.rewind

#       # @user.ticket_pdf.purge if @user.ticket_pdf.attached?
#       @user.ticket_pdf.attach(
#         io: temp_file,
#         filename: "ticket-#{Time.zone.now.to_i}-#{@user.id}.pdf",
#         content_type: "application/pdf",
#       )

#       temp_file.close
#       temp_file.unlink
#       @user.ticket_pdf
#     end
#   end
# end

