import { Controller } from "@hotwired/stimulus";

//  Connects to data-controller="timer"
export default class extends Controller {
  connect() {
    this.form = this.element.querySelector("#resend_otp_form");
    this.resendButton = this.element.querySelector("#resend_otp_button");
    this.resendTimer = this.element.querySelector("#resend_timer");
    this.inputFiled = this.element.querySelector("input[type = 'text']");
    
    this.startTimer();
    this.form.addEventListener("turbo:submit-end", this.startTimer.bind(this));
  }

  startTimer() {
    this.inputFiled.focus();
    this.resendButton.disabled = true;
    let endTime = Date.now() + 60000; 

    const updateTimer = () => {
      let remainingTime = Math.max(0, endTime - Date.now());
      let seconds = Math.floor((remainingTime / 1000) % 60);
      this.resendTimer.textContent = `Resend in ${seconds} seconds`;

      if (remainingTime <= 0) {
        this.resendButton.disabled = false;
        this.resendTimer.textContent = "";
      } else {
        requestAnimationFrame(updateTimer);
      }
    };

    updateTimer();
  }
}







// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   connect() {
//     const form = this.element.querySelector("#resend_otp_form");
//     this.element.addEventListener("turbo:submit-end", this.startTimer.bind(form));
//     this.startTimer();
//   }
  
//   startTimer() {    
//     this.resendButton = document.getElementById("resend_otp_button");
//     this.resendTimer = document.getElementById("resend_timer");

//     this.resendButton.disabled = true;
//     let countdown = 15;

//     const timer = setInterval(() => {
//       countdown--;
//       if (countdown < 0) {
//         clearInterval(timer);
//         this.resendButton.disabled = false;
//         this.resendTimer.innerHTML = "";
//       } else {
//         this.resendTimer.innerHTML = `Resend in ${countdown} seconds`;
//       }
//     }, 1000);
//   }
// }

