<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-header">
                <h3 class="card-title">RND Guitar Report - BOM Detail</h3>
            </div>
            <div class="card-body pt-5">
                <div class="row">
                    <div class="col-md-6">
                        <div class="card card-bordered shadow-sm">
                            <div class="card-body text-center">
                                <h4 class="card-title mb-5">BOM Detail AG (Category: 8)</h4>
                                <p class="card-text text-muted">Download report for Acoustic Guitars.</p>
                                <a href="<?= base_url('Report/RND/download_xlsx?type=AG') ?>" class="btn btn-success btn-lg me-3">
                                    <i class="fas fa-file-excel"></i> Download XLSX
                                </a>
                                <a href="<?= base_url('Report/RND/download_csv?type=AG') ?>" class="btn btn-info btn-lg">
                                    <i class="fas fa-file-csv"></i> Download CSV
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card card-bordered shadow-sm">
                            <div class="card-body text-center">
                                <h4 class="card-title mb-5">BOM Detail EG (Category: 5)</h4>
                                <p class="card-text text-muted">Download report for Electric Guitars. <br><small>Note: This report contains approximately 257,827 rows.</small></p>
                                <a href="<?= base_url('Report/RND/download_xlsx?type=EG') ?>" class="btn btn-success btn-lg me-3">
                                    <i class="fas fa-file-excel"></i> Download XLSX
                                </a>
                                <a href="<?= base_url('Report/RND/download_csv?type=EG') ?>" class="btn btn-info btn-lg">
                                    <i class="fas fa-file-csv"></i> Download CSV
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer mt-5">
                    <a href="<?= base_url('Report') ?>" class="btn btn-danger">
                        <i class="far fa-arrow-alt-circle-left"></i> Back to Report Navigation
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>