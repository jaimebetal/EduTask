<div class="card shadow-sm">
    <div class="card-body">
        <h4>Bienvenido, <?= htmlspecialchars($user['nombre'] ?? 'Usuario') ?></h4>
        <p class="mb-1"><strong>Rol:</strong> <?= htmlspecialchars($user['role'] ?? 'N/D') ?></p>
        <?php if (!empty($user['grado_grupo'])): ?>
            <p class="mb-1"><strong>Grado-Grupo:</strong> <?= htmlspecialchars($user['grado_grupo']) ?></p>
        <?php endif; ?>
        <?php if (($user['role'] ?? '') === 'estudiante'): ?>
            <a class="btn btn-primary mt-2" href="/estudiante">Ir al panel de estudiante</a>
        <?php endif; ?>
        <form action="/auth/logout" method="post" class="mt-3">
            <button class="btn btn-outline-danger" type="submit">Cerrar sesión</button>
        </form>
    </div>
</div>
