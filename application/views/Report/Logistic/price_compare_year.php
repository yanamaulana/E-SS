<div class="row gx-5 gx-xl-10">

    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <form action="" target="popup" id="FormReport" action="<?= base_url() ?>Report/Sales/Rpt_OstSO_v_Bom_v_StokMtrl" method="post">
                <div class="card-body pt-0">
                    <div class="py-5">
                        <div class="row g-5 mt-5">
                            <div class="row mb-6">
                                <label for="Account" class="col-sm-2 col-form-label-sm col-form-label">Price Comparison :</label>
                                <div class="col-sm-5">
                                    <div class="input-group input-group-sm">
                                        <input type="text" name="from" id="from" class="form-control text-center date-picker" placeholder="Start..." value="<?= date('Y-m-01') ?>">

                                        <span class="input-group-text btn-primary text-white">S/d</span>

                                        <input type="text" name="until" id="until" class="form-control text-center date-picker" placeholder="End..." value="<?= date('Y-m-t') ?>">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
            <div class="card-footer" style="border-top:solid #EFF2F5 2px;">
                <button type="button" class="btn btn-sm btn-light-danger float-start" id="Generate"><i class="fas fa-file"></i> Display Price Comparison</button>
                <a href="<?= base_url() ?>" class="btn btn-danger btn-sm float-end"><i class="far fa-arrow-alt-circle-left"></i> Cancel</a>
            </div>
        </div>
    </div>
</div>
<div id="location"></div>