<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-body pt-0">
                <div class="py-5">
                    <div class="row g-5">
                        <form action="">
                            <div class="row mb-5">
                                <label for="Account" class="col-sm-2 col-form-label-sm col-form-label">Customer :</label>
                                <div class="col-sm-5">
                                    <select class="form-select form-select-sm" data-control="select2" data-placeholder="Select an option" name="customer" id="customer">
                                        <option value="ALL">-- ALL --</option>
                                        <?php foreach ($qAccount->result() as $qa) : ?>
                                            <option value="<?= $qa->Account_Id ?>"><?= $qa->Account_Name ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <label for="Account" class="col-sm-2 col-form-label-sm col-form-label">Sales Type :</label>
                                <div class="col-sm-10">
                                    <div class="form-check form-check-inline form-check-sm">
                                        <input type="radio" class="form-check-input form-check-input-sm" name="sales_type" value="All" id="all" checked="">
                                        <label class="form-check-label form-check-label-sm" for="inlineRadio1">All</label>
                                    </div>
                                    <div class="form-check form-check-inline form-check-sm">
                                        <input class="form-check-input form-check-input-sm" type="radio" name="sales_type" id="local" value="0">
                                        <label class="form-check-label form-check-label-sm" for="inlineRadio2">Local</label>
                                    </div>
                                    <div class="form-check form-check-inline form-check-sm">
                                        <input class="form-check-input form-check-input-sm" type="radio" name="sales_type" id="export" value="1">
                                        <label class="form-check-label form-check-label-sm" for="inlineRadio3">Export</label>
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <label for="Account" class="col-sm-2 col-form-label-sm col-form-label">SO Date :</label>
                                <div class="col-sm-6">
                                    <div class="input-group input-group-sm">
                                        <input type="text" name="from" id="from" class="form-control  date-picker text-center readonly" value="<?= date('Y-m-01') ?>">
                                        <span class="input-group-text btn btn-primary" title="Date Range" data-toggle="tooltip"><i class="fas fa-calendar"></i> UNTIL</span>
                                        <input type="text" name="until" id="until" class="form-control  date-picker text-center readonly" value="<?= date('Y-m-t') ?>">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <a href="<?= base_url() ?>" class="btn btn-danger btn-sm float-end"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
            </div>
        </div>
    </div>
</div>
<div id="location"></div>