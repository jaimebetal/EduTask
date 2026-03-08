<div class="row g-3 mb-3">
    <div class="col-md-8">
        <h4 class="mb-1">Panel de Estudiante</h4>
        <p class="text-muted mb-0">Bienvenido, <?= htmlspecialchars($user['nombre'] ?? '') ?> · Grupo <?= htmlspecialchars($user['grado_grupo'] ?? 'N/D') ?></p>
    </div>
    <div class="col-md-4 text-md-end">
        <form action="/auth/logout" method="post">
            <button class="btn btn-outline-danger" type="submit">Cerrar sesión</button>
        </form>
    </div>
</div>

<div class="card shadow-sm mb-3">
    <div class="card-body row g-3 align-items-end">
        <div class="col-md-4">
            <label class="form-label">Año lectivo activo</label>
            <input type="text" class="form-control" value="<?= htmlspecialchars((string) ($activeYear['anio'] ?? 'Sin configurar')) ?>" disabled>
        </div>
        <div class="col-md-6">
            <label class="form-label">Periodo académico</label>
            <select id="periodoSelect" class="form-select">
                <option value="">Seleccione un periodo</option>
                <?php foreach ($periods as $period): ?>
                    <option value="<?= (int) $period['id'] ?>">
                        <?= htmlspecialchars('P' . $period['numero'] . ' - ' . $period['nombre']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="col-md-2 d-grid">
            <button class="btn btn-primary" id="btnConsultarActividades" type="button">Consultar</button>
        </div>
    </div>
</div>

<div id="studentPanelAlert" class="mb-3"></div>

<div class="card shadow-sm">
    <div class="card-header bg-white"><strong>Actividades del periodo</strong></div>
    <div class="table-responsive">
        <table class="table table-striped table-hover mb-0" id="tablaActividadesEstudiante">
            <thead>
            <tr>
                <th>Actividad</th>
                <th>Guía</th>
                <th>Fecha límite</th>
                <th>Entrega</th>
                <th>Tiempo</th>
                <th>Nota</th>
                <th>Retroalimentación</th>
            </tr>
            </thead>
            <tbody>
            <tr><td colspan="7" class="text-center text-muted">Selecciona un periodo para consultar actividades.</td></tr>
            </tbody>
        </table>
    </div>
</div>
