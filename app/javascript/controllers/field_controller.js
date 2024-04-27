import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';

// Connects to data-controller="field"
export default class extends Controller {
  static targets = ["regis", "sel"];
  connect() {
  }

  update() {
    if (this.selTarget.value == "user") {
      this.regisTarget.style.display = "none";
    }
    else {
      this.regisTarget.style.display = "block";
    }
  }
}
