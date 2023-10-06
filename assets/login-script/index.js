$(function () {
	$.validator.setDefaults({
		submitHandler: function () {
			Fn_store_login($('#username').val(), $('#password').val());
		}
	});

	$('#form-login').validate({
		rules: {
			username: {
				required: true,
			},
			password: {
				required: true,
				minlength: 4
			}
		},
		messages: {
			username: {
				required: "Username is required !",
			},
			password: {
				required: "Password is required !",
				minlength: "Password minimum is 5 character !"
			}
		},
		errorElement: 'span',
		errorPlacement: function (error, element) {
			error.addClass('invalid-feedback');
			element.closest('.fv-row').append(error);
		},
		highlight: function (element, errorClass, validClass) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function (element, errorClass, validClass) {
			$(element).removeClass('is-invalid');
		}
	});

	function Fn_store_login(u, p) {
		$.ajax({
			dataType: "json",
			type: "POST",
			url: "Auth/post_login",
			data: {
				u: u,
				p: p
			},
			beforeSend: function () {
				$("#btn--login").prop("disabled", true);
				$("#btn--login").html(
					`<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...`
				)
			},
			success: function (response) {
				if (response.code == 200) {
					let timerInterval
					Swal.fire({
						icon: 'success',
						title: 'Success...',
						timer: 1500,
						timerProgressBar: true,
						text: response.msg,
						didOpen: () => {
							Swal.showLoading()
							const b = Swal.getHtmlContainer().querySelector('b')
							timerInterval = setInterval(() => {
								b.textContent = Swal.getTimerLeft()
							}, 100)
						},
						willClose: () => {
							clearInterval(timerInterval)
						},
						footer: '<a href="javascript:void(0)" class="text-info">Notification System</a>'
					}).then((result) => {
						if (result.dismiss === Swal.DismissReason.timer) {
							window.location.href = "Dashboard";
						}
					})
				} else {
					Swal.fire({
						icon: 'warning',
						title: 'Warning!',
						text: response.msg,
						footer: '<a href="javascript:void(0)" class="text-danger">Notification System</a>'
					});
					$("#btn--login").prop("disabled", false);
					$('#btn--login').html(`<i class="fas fa-sign-in-alt"></i> Sign-In`);
				}
			},
			error: function (xhr, status, error) {
				var statusCode = xhr.status;
				var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "Terjadi kesalahan: " + error;
				Swal.fire({
					icon: "error",
					title: "Error!",
					html: `Kode HTTP: ${statusCode}<br\>Pesan: ${errorMessage}`,
				});
				$("#btn--login").prop("disabled", false);
				$('#btn--login').html(`<i class="fas fa-sign-in-alt"></i> Sign-In`);
			}
		});
	}
	$('#username').focus();
});
