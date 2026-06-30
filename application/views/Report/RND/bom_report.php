<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-header">
                <h3 class="card-title">RND Report - BOM Detail <?= $report_type ?></h3>
            </div>
            <div class="card-body pt-5">
                <div class="alert alert-info" role="alert">
                    <i class="fas fa-info-circle"></i>
                    <span id="row-count"></span> rows available for download
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="card card-bordered shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-file-excel fs-3x text-success mb-3"></i>
                                <h5 class="card-title">Download as XLSX</h5>
                                <p class="card-text text-muted">Download report in Excel format</p>
                                <a href="<?= base_url('Report/RND/download_xlsx?type=' . $report_type) ?>" class="btn btn-success btn-lg">
                                    <i class="fas fa-download"></i> Download XLSX
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card card-bordered shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-file-csv fs-3x text-info mb-3"></i>
                                <h5 class="card-title">Download as CSV</h5>
                                <p class="card-text text-muted">Download report in CSV format</p>
                                <a href="<?= base_url('Report/RND/download_csv?type=' . $report_type) ?>" class="btn btn-info btn-lg">
                                    <i class="fas fa-download"></i> Download CSV
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-5">
                    <div class="alert alert-warning" role="alert">
                        <strong>Report Type:</strong> <?= ($report_type == 'AG') ? 'BOM Detail AG (Category: 8)' : 'BOM Detail EG (Category: 5)' ?>
                        <?php if ($report_type == 'EG'): ?>
                            <br><small>Note: This report contains approximately 257,827 rows</small>
                        <?php endif; ?>
                    </div>
                </div>

                <div class="modal-footer mt-5">
                    <a href="<?= base_url('Report') ?>" class="btn btn-danger">
                        <i class="far fa-arrow-alt-circle-left"></i> Back
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>