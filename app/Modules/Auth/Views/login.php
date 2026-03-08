<div class="row g-4">
    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-white"><strong>Ingreso Estudiante</strong></div>
            <div class="card-body">
                <form id="studentLoginForm">
                    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken) ?>">
                    <div class="mb-3">
                        <label class="form-label">Documento de identidad</label>
                        <input type="text" class="form-control" name="documento" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Captcha: <?= htmlspecialchars($captchaQuestion) ?></label>
                        <input type="number" class="form-control" name="captcha" required>
                    </div>
                    <button class="btn btn-primary w-100" type="submit">Ingresar</button>
                </form>
                <div id="studentLoginAlert" class="mt-3"></div>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-white"><strong>Ingreso Docente / Administrador</strong></div>
            <div class="card-body">
                <form id="staffLoginForm">
                    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken) ?>">
                    <div class="mb-3">
                        <label class="form-label">Correo</label>
                        <input type="email" class="form-control" name="email" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Contraseña</label>
                        <input type="password" class="form-control" name="password" required>
                    </div>
                    <button class="btn btn-dark w-100" type="submit">Ingresar</button>
                </form>
                <div id="staffLoginAlert" class="mt-3"></div>
            </div>
        </div>
    </div>
</div>
