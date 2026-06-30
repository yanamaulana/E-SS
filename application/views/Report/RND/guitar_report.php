<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-header pt-7">
                <h3 class="card-title align-items-start flex-column">
                    <span class="card-label fw-bold text-dark">RND Guitar BOM Report</span>
                    <span class="text-gray-400 mt-1 fw-semibold fs-6">Download Bill of Materials data for Acoustic and Electric Guitars.</span>
                </h3>
            </div>
            <div class="card-body pt-4">
                <div class="alert alert-primary">
                    <div class="d-flex flex-column">
                        <h4 class="mb-1 text-primary">Informasi</h4>
                        <span>Karena jumlah data yang sangat besar, laporan akan diunduh dalam format <strong>CSV</strong> untuk memastikan performa dan mencegah masalah memori pada server.</span>
                    </div>
                </div>
                <div class="d-flex justify-content-center flex-wrap gap-4 mt-10">
                    <a href="<?= base_url('Report/RND/download_report/ag') ?>" class="btn btn-lg btn-primary" target="_blank">
                        <i class="fas fa-file-csv fs-3 me-2"></i> Download Laporan AG (Acoustic Guitar)
                    </a>
                    <a href="<?= base_url('Report/RND/download_report/eg') ?>" class="btn btn-lg btn-success" target="_blank">
                        <i class="fas fa-file-csv fs-3 me-2"></i> Download Laporan EG (Electric Guitar)
                    </a>
                    <a href="<?= base_url('Report/RND/download_report/all') ?>" class="btn btn-lg btn-info">
                        <i class="fas fa-file-archive fs-3 me-2"></i> Download Laporan Gabungan (AG & EG)
                    </a>
                </div>
            </div>
            <div class="card-footer d-flex justify-content-end py-6 px-9">
                <a href="<?= base_url('Report/Navigation') ?>" class="btn btn-light-danger"><i class="far fa-arrow-alt-circle-left"></i> Kembali ke Navigasi</a>
            </div>
        </div>
    </div>
</div>