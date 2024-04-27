// window.onload = function () {
//   let oldImgSrc;

//   $("#edit").click(function(){
//     $('#edit').css('display', 'none')
//     $('#upload').css('display', 'block');
//     $('#delete').css('display', 'block');
//     $('#cancel2').css('display', 'block');
//   })

//   $('#fileImg').change(function () {
//     oldImgSrc = $('#img_tag').attr('src');
//     const fileField = this.files[0];
//     $('#img_tag').attr('src', URL.createObjectURL(fileField));
//     $('#cancel').css('display', 'block');
//     $('#confirm').css('display', 'block');
//     $('#upload').css('display', 'none');
//     $('#cancel2').css('display', 'none');
//     $('#delete').css('display', 'none');
//   });

//   $('#cancel').click(function () {
//     $('#img_tag').attr('src', oldImgSrc);
//     $('#cancel').css('display', 'none');
//     $('#cancel2').css('display', 'none');
//     $('#delete').css('display', 'none');
//     $('#confirm').css('display', 'none');
//     $('#upload').css('display', 'none');
//     $('#edit').css('display', 'block');
//     $('#fileImg').val('');
//   });

//   $('#cancel2').click(function () {
//     $('#cancel2').css('display', 'none');
//     $('#upload').css('display', 'none');
//     $('#delete').css('display', 'none');
//     $('#edit').css('display', 'block');
//   });

//   $('#delete').click(function () {
//     $('#delete').css('display', 'none');
//     $('#cancel2').css('display', 'none');
//     $('#upload').css('display', 'none');
//     insertLoader();
//     destroyImg();
//   });

//   $('#confirm').click(function () {
//     const fileField = $('#fileImg')[0].files[0];
//     $('#fileImg').val('');
//     if (fileField) {
//       const formData = new FormData();
//       formData.append("profile_pic", fileField);
//       insertLoader();
//       upload(formData);

//       $('#cancel').css('display', 'none');
//       $('#confirm').css('display', 'none');
//       $('#delete').css('display', 'none');
//       $('#upload').css('display', 'none');
//     }
//   });

//   async function upload(formData) {
//     try {
//       const csrfToken = $('meta[name="csrf-token"]').attr('content');
//       const response = await fetch("/upload_profile", {
//         method: "PATCH",
//         headers: {
//           'X-CSRF-Token': csrfToken,
//         },
//         body: formData,
//       });
//       $('#edit').css('display', 'block');
      
//       if (response.ok) {
//         const result = await response.json();
//         $('#img_tag').attr('src', result.profile_pic_url);
//         $('#flash').html($('<div>', { class: 'flash__message bg-success', text: result.message }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));

//       } else {
//         const errorData = await response.json();
//         if (errorData.error) {
//           console.error("Error:", errorData.error);
//           $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: errorData.error }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));

//         } else {
//           $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: `An error occurred while uploading the profile picture: ${response.statusText}` }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));
//         }
//         $('#img_tag').attr('src', oldImgSrc);
//       }
//     } catch (error) {
//       $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: `An error occurred while uploading the profile picture: ${error}` }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));
//       $('#img_tag').attr('src', oldImgSrc);
//     }
//   }

//   function insertLoader() {
//     $('#flash').html('<div id="loader"><i class="fas fa-spinner fa-spin"></i></div>');
//   }

//   async function destroyImg() {
//     try {
//       const csrfToken = $('meta[name="csrf-token"]').attr('content');
//       const response = await fetch("/delete_profile", {
//         method: "DELETE",
//         headers: {
//           'X-CSRF-Token': csrfToken,
//         },
//         body: "",
//       });
//       $('#edit').css('display', 'block');

//       if (response.ok) {
//         const result = await response.json();
//         $('#img_tag').attr('src', "");
//         $('#flash').html($('<div>', { class: 'flash__message bg-success', text: result.message }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));

//       } else {
//         const errorData = await response.json();
//         if (errorData.error) {
//           $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: errorData.error }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));
//         } else {
//           $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: `An error occurred while deleting the profile picture: ${response.statusText}` }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));
//         }
//         $('#img_tag').attr('src', oldImgSrc);
//       }
//     } catch (error) {
//       $('#flash').html($('<div>', { class: 'flash__message bg-danger', text: `An error occurred while deleting the profile picture: ${error}` }).attr({ 'data-controller': 'removals', 'data-action': 'animationend->removals#remove'}));
//       $('#img_tag').attr('src', oldImgSrc);
//     }
//   }

// };

// // <%= image_tag url_for(user.profile_pic), class: "img-fluid my-5 profile-pic rounded-circle", style: "width:200px; height: 200px; border: 9px solid rgb(22 25 30);  object-fit: cover; cursor: pointer;", id: "img_c", data: { controller: "profile-pic", action: "click->profile-pic#talk", profile_pic_target: "image", "profile-pic-val-value": admin_show_path(current_user.id) } %>


// NOTE:
// Add this line in _show.html.erb
// <%= javascript_include_tag("profile_picture_upload.js") %>
// And in _header.html.erb make data: {turbo: false} to user name link