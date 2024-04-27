import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="focus-on-error"
export default class extends Controller {
  connect() {
    const firstInputWithError = this.element.querySelector('.field_with_errors input');

    setTimeout(() => {
      if (firstInputWithError) {
        firstInputWithError.focus();
      }
    }, 0);
  }
}

