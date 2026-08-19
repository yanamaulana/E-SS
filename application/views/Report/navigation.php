<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-body pt-0">
                <div class="py-5">
                    <div class="row g-5">
                        <div class="col-lg-4 col-md-4">
                            <div class="card card-bordered shadow-sm">
                                <div class="card-body p-0">
                                    <div class="dropdown text-center">
                                        <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenu1" data-bs-toggle="dropdown" aria-expanded="false">
                                            <strong>Sales & Marketing</strong>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu1">
                                            <li><a href="<?= base_url('Report/Sales/sales_order_report?SelCurr=IDR') ?>" class="dropdown-item">Sales Order Report</a></li>
                                            <li><a href="<?= base_url('Report/Sales/ostpo_rawmaterial') ?>" class="dropdown-item">Raw Material Outstanding PO</a></li>
                                            <li><a href="<?= base_url('Report/Sales/index_hpp') ?>" class="dropdown-item">Sales HPP Report</a></li>
                                        </ul>
                                    </div>
                                    <div class="text-center px-4">
                                        <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/undraw_Marketing_re_7f1g.png">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-4">
                            <div class="card card-bordered shadow-sm">
                                <div class="card-body p-0">
                                    <div class="dropdown text-center">
                                        <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenu2" data-bs-toggle="dropdown" aria-expanded="false">
                                            <strong>Stock Opname</strong>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu2">
                                            <li><a class="dropdown-item" href="<?= base_url('Opname/index') ?>">Tool Generating Qty Opname</a></li>
                                        </ul>
                                    </div>
                                    <div class="text-center px-4">
                                        <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/undraw_conference_call_b0w6.png">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-4">
                            <div class="card card-bordered shadow-sm">
                                <div class="card-body p-0">
                                    <div class="dropdown text-center">
                                        <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenu3" data-bs-toggle="dropdown" aria-expanded="false">
                                            <strong>Logistic & Purchasing</strong>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu3">
                                            <li><a href="<?= base_url('Report/Logistic/eta_purchase_order') ?>" class="dropdown-item"><i class="fas fa-truck-loading me-2"></i>ETA Purchase Order</a></li>
                                            <li><a href="<?= base_url('Report/Logistic/index_price_comparison_last_v_this_year') ?>" class="dropdown-item"><i class="fas fa-balance-scale me-2"></i>Item Price Comparison </a></li>
                                            <li>
                                                <hr class="dropdown-divider">
                                            </li>
                                            <li><a href="<?= base_url('Report/Logistic/upload_tax_invoice') ?>" class="dropdown-item"><i class="fas fa-file-invoice-dollar me-2"></i>Upload Faktur Pajak</a></li>
                                            <li>
                                                <hr class="dropdown-divider">
                                            </li>
                                            <li><a href="<?= base_url('ScriptTool/update_costcenter') ?>" class="dropdown-item"><i class="fas fa-cogs me-2"></i>Repair VIN Cost Center</a></li>
                                        </ul>
                                    </div>
                                    <div class="text-center px-4">
                                        <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/undraw_heavy_box_agqi.png">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-4">
                            <div class="card card-bordered shadow-sm">
                                <div class="card-body p-0">
                                    <div class="dropdown text-center">
                                        <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenuRnd" data-bs-toggle="dropdown" aria-expanded="false">
                                            <strong>RND Guitar</strong>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenuRnd">
                                            <li><a href="<?= base_url('Report/RND/guitar_report') ?>" class="dropdown-item">BOM Detail Report</a></li>
                                        </ul>
                                    </div>
                                    <div class="text-center px-4">
                                        <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/undraw_researching_49yy.png">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <?php if ($this->session->userdata('sys_sba_isAdm') == true || $this->session->userdata('sys_sba_NIK') == '09466' || $this->session->userdata('sys_sba_NIK') == '09460'): ?>
                            <div class="col-lg-4 col-md-4 mt-4">
                                <div class="card card-bordered shadow-sm">
                                    <div class="card-body p-0">
                                        <div class="dropdown text-center">
                                            <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenu3" data-bs-toggle="dropdown" aria-expanded="false">
                                                <strong>HR Report</strong>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu3">
                                                <li><a href="<?= base_url('ReportPemakaianCuti') ?>" class="dropdown-item">Pemakaian Cuti Terkini</a></li>
                                                <li><a href="<?= base_url('InformasiKaryawan') ?>" class="dropdown-item">Master Data Karyawan & Photo</a></li>
                                            </ul>
                                        </div>
                                        <div class="text-center px-4">
                                            <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/undraw_team-page_q5am.png">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <?php endif; ?>
                        <?php if ($this->session->userdata('sys_sba_isAdm') == true): ?>
                            <div class="col-lg-4 col-md-4">
                                <div class="card card-bordered shadow-sm">
                                    <div class="card-body p-0">
                                        <div class="dropdown text-center">
                                            <button class="btn btn-lg dropdown-toggle text-dark" type="button" id="dropdownMenuRnd" data-bs-toggle="dropdown" aria-expanded="false">
                                                <strong>MIS Panel</strong>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenuRnd">
                                                <li><a href="<?= base_url('Report/MIS/ERP_AccessPermission') ?>" id="mis-panel-link" class="dropdown-item">ERP Access Permission</a></li>
                                            </ul>
                                        </div>
                                        <div class="text-center px-4">
                                            <img class="mw-100 mh-300px card-rounded-bottom" alt="Image Illustration" src="<?= base_url() ?>assets/media/illustrations/Mis.png">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <a href="<?= base_url() ?>" class="btn btn-danger float-end"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
        </div>
    </div>
</div>
</div>
<div id="location"></div>