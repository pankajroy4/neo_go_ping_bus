import Swal from 'sweetalert2';
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert"
export default class extends Controller {
  static targets = ["btn"];
  static values = { text: String, confirm: String, cancel: String }
  connect() {
  }

  async confirmation(event) {
    try {
      this.flash = document.getElementById("flash")
      this.href = event.target.href;
      event.preventDefault();
      const confirmed = await this.confirmDialog();
      if (confirmed) {
        this.btnTarget.removeAttribute('href');
        this.insertLoader();
        const response = await fetch(this.href + '.turbo_stream', {
          method: 'DELETE',
          headers: {
            // 'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Content-Type': 'application/turbo_stream',
            'Accept': 'text/vnd.turbo-stream.html'
          }
        })

        if (!response.ok) {
          const errorMessage = `Server response: ${response.status} ${response.statusText}`;
          throw new Error(errorMessage);
        }
        const html = await response.text();
        Turbo.renderStreamMessage(html);
      }
    } catch (error) {
      this.btnTarget.setAttribute('href', this.href);
      this.flash.innerHTML = `<div class="flash__message bg-danger" data-controller="removals" data-action="animationend->removals#remove">${error}</div>`;
      event.preventDefault();
    }
  }

  async confirmDialog() {
    if (this.href) {
      const swalWithBootstrapButtons = Swal.mixin({
        customClass: {
          confirmButton: 'btn btn-success text-center m-1',
          cancelButton: 'btn btn-danger text-center m-1',
        }, buttonsStyling: false,
        width: '350px',
        reverseButtons: true,
      })

      const result = await swalWithBootstrapButtons.fire({
        title: 'Are you sure?',
        text: this.textValue,
        icon: 'warning',
        showCancelButton: true,
        cancelButtonText: this.cancelValue,
        confirmButtonText: this.confirmValue,
        padding: "0em",
      });

      return result.isConfirmed;
    }
  }
  
  insertLoader() {
    this.flash.innerHTML = '<div id="loader"><i class="fas fa-spinner fa-spin"></i></div>';
  }
  
}


// ==========================================================

// import Swal from 'sweetalert2';
// import { Controller } from "@hotwired/stimulus"

// // Connects to data-controller="alert"
// export default class extends Controller {
//   static targets = ["btn"];
//   static values = { text: String, confirm: String, cancel: String }
//   connect() {
//   }

//   confirmation(event) {
//     const href = event.target.href;
//     event.preventDefault();
//     const swalWithBootstrapButtons = Swal.mixin({
//       customClass: {
//         confirmButton: 'btn btn-success m-2',
//         cancelButton: 'btn btn-danger',
//       }, buttonsStyling: false,
//       width: '350px',
//       reverseButtons: true,
//     })
//     if(href) {
//       swalWithBootstrapButtons.fire({
//         title: 'Are you sure?',
//         text: this.textValue,
//         icon: 'warning',
//         showCancelButton: true,
//         cancelButtonText: this.cancelValue,
//         confirmButtonText: this.confirmValue,
//         padding: "0em",
//       }).then((result) => {
//         if (result.isConfirmed && href) {
//           this.btnTarget.removeAttribute('href');
//           fetch(href + '.turbo_stream', {
//             method: 'DELETE',
//             headers: {
//               // 'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
//               'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
//               'Content-Type': 'application/turbo_stream',
//               'Accept': 'text/vnd.turbo-stream.html'
//             }
//           })
//             .then(r => r.text())
//             .then(html => Turbo.renderStreamMessage(html))
//             .catch(event.preventDefault())
//         }
//       });
//     }
//   }
// }

