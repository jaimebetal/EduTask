function renderAlert(target, ok, message) {
    const cls = ok ? 'alert-success' : 'alert-danger';
    $(target).html(`<div class="alert ${cls}">${message}</div>`);
}

function submitAjaxForm(formSelector, endpoint, alertSelector) {
    $(formSelector).on('submit', function (e) {
        e.preventDefault();
        const data = $(this).serialize();

        $.ajax({
            url: endpoint,
            method: 'POST',
            data,
            dataType: 'json'
        }).done(function (res) {
            renderAlert(alertSelector, res.ok, res.message);
            if (res.ok && res.redirect) {
                window.location.href = res.redirect;
            }
        }).fail(function (xhr) {
            const msg = xhr.responseJSON?.message || 'Error inesperado.';
            renderAlert(alertSelector, false, msg);
        });
    });
}

$(function () {
    submitAjaxForm('#studentLoginForm', '/auth/student-login', '#studentLoginAlert');
    submitAjaxForm('#staffLoginForm', '/auth/staff-login', '#staffLoginAlert');
});
