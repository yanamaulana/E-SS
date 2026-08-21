<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-header">
                <h3 class="card-title">Export Report Pemakaian Cuti</h3>
            </div>
            <div class="card-body">
                <form method="get" action="<?= base_url('ReportPemakaianCuti/export_excel') ?>" class="row align-items-end g-5">
                    <div class="form-text">Data ANL dihitung dari 1 Januari sampai 31 Desember pada tahun yang dipilih.</div>
                    <div class="col-md-5">
                        <label for="annual_year" class="form-label required">Tahun Report</label>
                        <select id="annual_year" name="year" class="form-select" required>
                            <?php for ($year = (int) date('Y'); $year >= 2014; $year--) : ?>
                                <option value="<?= $year ?>" <?= $year === (int) date('Y') ? 'selected' : '' ?>><?= $year ?></option>
                            <?php endfor; ?>
                        </select>
                    </div>
                    <div class="col-md-5">
                        <button type="submit" class="btn btn-success"><i class="far fa-file-excel"></i> Export Excel</button>
                    </div>
                </form>
            </div>
            <div class="card-footer">
                <a href="<?= base_url() ?>" class="btn btn-danger float-end"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
            </div>
        </div>
    </div>
</div>
