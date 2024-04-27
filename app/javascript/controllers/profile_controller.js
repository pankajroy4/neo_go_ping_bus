import { Controller } from "@hotwired/stimulus";
import Swal from 'sweetalert2';

// Connects to data-controller="profile"
export default class extends Controller {
  static targets = ["img", "file", "edit", "upload", "delete", "cancel", "cancel2", "confirm", "fileData"];
  static values = { attached: Boolean, id: Number }

  connect() {
    document.body.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.body.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  handleClickOutside(event) {
    const isClickInsideButtons = this.element.contains(event.target);
    if (!isClickInsideButtons) {
      const buttonsVisible = ["file", "cancel2", "delete"].some(target => this[target + "Target"].style.display === "block");
      if (buttonsVisible) {
        this.hideElements(["file", "cancel2", "delete"]);
        this.showElements(["edit"]);
      }
    }
  }

  edit() {
    const attachedValue = this.editTarget.dataset.profileAttachedValue === "true";

    this.oldImg = document.getElementById('img_tag');
    this.flash = document.getElementById("flash")
    this.oldImgSrc = this.oldImg.src;
    this.hideElements(["edit"]);
    this.showElements(["file", "cancel2"]);
    if (attachedValue)
      this.showElements(["delete"]);
  }

  fileChange() {
    const fileField = this.fileDataTarget.files[0];
    if (!fileField || !fileField.type.startsWith('image/') || fileField.size > 7 * 1024 * 1024) {
      this.handleError("File size too large, Maximum size is 7 MB.");
      this.fileDataTarget.value = '';
      this.hideElements(["file", "cancel2", "delete"]);
      return;
    }
    this.imgTarget.src = URL.createObjectURL(fileField);
    this.showElements(["cancel", "confirm"]);
    this.hideElements(["file", "cancel2", "delete"]);
  }

  cancel() {
    this.imgTarget.src = this.oldImgSrc;
    this.hideElements(["cancel", "cancel2", "confirm"]);
    this.showElements(["edit"]);
    this.fileDataTarget.value = '';
  }

  cancel2() {
    this.hideElements(["file", "cancel2", "delete"]);
    this.showElements(["edit"]);
  }

  async delete() {
    const confirmed = await this.confirmAction();
    if (confirmed) {
      this.hideElements(["delete", "cancel2", "file"]);

      this.insertLoader();
      await this.destroyImg();
    }
  }

  async confirm() {
    const fileField = this.fileDataTarget.files[0];
    const idValue = this.confirmTarget.dataset.profileIdValue
    this.fileDataTarget.value = '';
    if (fileField) {
      const formData = new FormData();
      formData.append("profile_pic", fileField);
      formData.append("id", idValue);
      this.insertLoader();
      await this.upload(formData);
      this.hideElements(["cancel", "confirm", "delete"]);
    }
  }

  async upload(formData) {
    try {
      const csrfToken = this.getCSRFToken();
      const response = await fetch("/upload_profile.turbo_stream", {
        method: "PATCH",
        headers: {
          'X-CSRF-Token': csrfToken,
        },
        body: formData,
      });

      const result = await response.json();
      if (!response.ok) {
        throw new Error(result.error || response.statusText);
      }
      this.editTarget.dataset.profileAttachedValue = "true"
      this.imgTarget.classList.add('profile-pic')
      this.imgTarget.style.cursor = "pointer";
      this.imgTarget.setAttribute('data-action', 'click->profile#edit');
      this.handleSuccess(result.profile_pic_url, result.message);
    } catch (error) {
      this.handleError(error);
    }
  }

  async destroyImg() {
    try {
      const csrfToken = this.getCSRFToken();
      const idValue = this.confirmTarget.dataset.profileIdValue
      const response = await fetch(`/delete_profile/${idValue}.turbo_stream`, {
        method: "DELETE",
        headers: {
          'X-CSRF-Token': csrfToken,
        },
        body: "",
      });
      
      const result = await response.json();
      if(!response.ok){
        throw new Error(result.error || response.statusText);
      }
      this.editTarget.dataset.profileAttachedValue = "false"
      this.imgTarget.classList.remove('profile-pic')
      this.imgTarget.style.cursor = "default";
      this.imgTarget.removeAttribute('data-action', 'click->profile#edit');
      this.showElements(["edit"]);
      this.handleSuccess(result.profile_pic_url, result.message);
    } catch (error) {
      this.handleError(error);
    }
  }

  insertLoader() {
    this.flash.innerHTML = '<div id="loader"><i class="fas fa-spinner fa-spin"></i></div>';
  }

  handleSuccess(picUrl, message) {
    this.imgTarget.src = picUrl;
    this.flash.innerHTML = `<div class="flash__message bg-success" data-controller="removals" data-action="animationend->removals#remove">${message}</div>`;
    this.showElements(["edit"]);
  }

  handleError(errorMessage) {
    this.flash.innerHTML = `<div class="flash__message bg-danger" data-controller="removals" data-action="animationend->removals#remove"> ${errorMessage}</div>`;
    this.imgTarget.src = this.oldImgSrc;
    this.showElements(["edit"]);
  }

  async confirmAction() {
    const swalWithBootstrapButtons = Swal.mixin({
      customClass: {
        confirmButton: 'btn btn-success m-2',
        cancelButton: 'btn btn-danger'
      }, buttonsStyling: false,
      width: '350px',
      reverseButtons: true,
    });

    const result = await swalWithBootstrapButtons.fire({
      title: "Are you sure?",
      text: "You are about to delete the profile picture.",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, proceed',
      cancelButtonText: 'No, cancel',
      padding: "0em",
    });

    return result.isConfirmed;
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  }

  hideElements(targets) {
    targets.forEach(target => this[target + "Target"].style.display = "none");
  }

  showElements(targets) {
    targets.forEach(target => this[target + "Target"].style.display = "block");
  }
}