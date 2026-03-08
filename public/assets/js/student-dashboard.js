function renderStudentAlert(ok, message) {
    const cls = ok ? 'alert-success' : 'alert-danger';
    $('#studentPanelAlert').html(`<div class="alert ${cls}">${message}</div>`);
}

function rowActividad(item) {
    const nota = item.nota_publicada ? (item.nota_final ?? '-') : 'Pendiente publicación';
    const retro = item.retro_publicada ? (item.comentario ?? '-') : 'Pendiente publicación';

    return `
    <tr>
        <td>${item.titulo ?? '-'}</td>
        <td>${item.guia_titulo ?? 'Sin guía'}</td>
        <td>${item.fecha_limite ?? '-'}</td>
        <td>${item.estado_entrega ?? 'pendiente'}</td>
        <td>${item.estado_tiempo ?? '-'}</td>
        <td>${nota}</td>
        <td>${retro}</td>
    </tr>`;
}

$(function () {
    $('#btnConsultarActividades').on('click', function () {
        const periodoId = $('#periodoSelect').val();
        if (!periodoId) {
            renderStudentAlert(false, 'Debes seleccionar un periodo.');
            return;
        }

        $.ajax({
            url: `/estudiante/actividades?periodo_id=${encodeURIComponent(periodoId)}`,
            method: 'GET',
            dataType: 'json'
        }).done(function (res) {
            if (!res.ok) {
                renderStudentAlert(false, res.message || 'No fue posible consultar.');
                return;
            }

            const data = res.data || [];
            const tbody = $('#tablaActividadesEstudiante tbody');
            tbody.empty();

            if (data.length === 0) {
                tbody.append('<tr><td colspan="7" class="text-center text-muted">No hay actividades para el periodo seleccionado.</td></tr>');
                renderStudentAlert(true, 'Consulta realizada sin registros.');
                return;
            }

            data.forEach((item) => tbody.append(rowActividad(item)));
            renderStudentAlert(true, `Se cargaron ${data.length} actividades.`);
        }).fail(function (xhr) {
            const msg = xhr.responseJSON?.message || 'Error inesperado consultando actividades.';
            renderStudentAlert(false, msg);
        });
    });
});
