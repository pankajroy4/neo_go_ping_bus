// app/javascript/controllers/toggle_password_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["password", "icon"];

  toggle() {
    const isHidden = this.passwordTarget.type === "password";
    this.passwordTarget.type = isHidden ? "text" : "password";

    this.iconTarget.classList.toggle("fa-eye", !isHidden);
    this.iconTarget.classList.toggle("fa-eye-slash", isHidden);
  }
}