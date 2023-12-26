<!DOCTYPE html>
<html lang="en">

<head>
    <title><?= $page_title ?></title>
    <meta name="base_url" content="<?= base_url() ?>">
    <meta name="description" content="E Samick Support System" />
    <meta name="keywords" content="E Samick Support System" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta charset="utf-8" />
    <meta property="og:locale" content="en_US" />
    <meta property="og:type" content="article" />
    <meta property="og:title" content="E-Samick Support System" />
    <meta property="og:url" content="<?= base_url() ?>" />
    <meta property="og:site_name" content="E-Samick Support System" />
    <link rel="canonical" href="<?= base_url() ?>" />
    <link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
    <link rel="stylesheet" href="<?= base_url() ?>assets/E-SBA_assets/font/main-font.css">
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/plugins/global/plugins.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/css/style.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/datatables/datatables.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/css/custom.css" rel="stylesheet" type="text/css" />
    <script src="<?= base_url() ?>assets/global-assets/jquery/jquery.min.js"></script>
</head>
<style>
    div.dt-buttons {
        float: right;
    }
</style>

<body>
    <div class="alert alert-primary" id="loader">
        <span class="svg-icon svg-icon-2hx svg-icon-primary me-3">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
        </span>
        <div class="d-flex flex-column">
            <h4 class="mb-1 text-dark">Loading.....</h4>
            <span>Harap tunggu, Memproses pengambilan Qty Onhand & memasukan ke Qty Opname.....</span>
        </div>
    </div>
    <div class="container">
        <div class="row mt-10">
            <div class="card shadow-sm card-outline card-info">
                <div class="card-header">
                    <h3 class="modal-title mt-5">Generate Qty Stock Opname : </h3>
                    <div class="row py-1">
                        <div class="card-toolbar">
                            <div class="btn-group btn-group-sm">
                                <a href="#" class="btn btn-info">Location :</a>
                                <a href="#" class="btn btn-info active" aria-current="page"><?= $RowLocation->wh_name ?></a>
                            </div>
                            &nbsp;
                            <div class="btn-group btn-group-sm">
                                <a href="#" class="btn btn-info">Item Category Type :</a>
                                <a href="#" class="btn btn-info active" aria-current="page"><?= $ItemCategoryTypeTxt ?></a>
                            </div>
                            &nbsp;
                            <div class="btn-group btn-group-sm">
                                <a href="#" class="btn btn-info">Category :</a>
                                <a href="#" class="btn btn-info active" aria-current="page"><?= $TxtCategory ?></a>
                            </div>
                            &nbsp;
                            <div class="btn-group btn-group-sm">
                                <a href="#" class="btn btn-info">Gudang :</a>
                                <a href="#" class="btn btn-info active" aria-current="page"><?= $RowGudang->Bin_Name ?></a>
                            </div>
                            &nbsp;
                            <div class="btn-group btn-group-sm">
                                <a href="#" class="btn btn-info">Date :</a>
                                <a href="#" class="btn btn-info active" aria-current="page"><?= $DateOpname ?></a>
                            </div>
                            <?php if (!empty($item_code)) : ?>
                                <div class="btn-group btn-group-sm mt-2">
                                    <a href="#" class="btn btn-info">Item Code :</a>
                                    <a href="#" class="btn btn-info active" aria-current="page"><?= $item_code ?></a>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="pb-5 table-responsive">
                        <table id="TableData" class="table-sm align-middle display compact table-rounded table-striped table-bordered border dataTable no-footer dt-inline">
                            <thead style="background-color: #3B6D8C;">
                                <tr class="text-white fw-bolder text-uppercase">
                                    <th class="text-center text-white">No.</th>
                                    <th class="text-center text-white">Item Code</th>
                                    <th class="text-center text-white">Item Name</th>
                                    <th class="text-center text-white">Dimension</th>
                                    <th class="text-center text-white">Qty On Hand</th>
                                    <th class="text-center text-white">Stock Opname</th>
                                    <th class="text-center text-white">Balance Opname</th>
                                    <th class="text-center text-white">Unit Cost</th>
                                    <?php if ($qValidateOpname->num_rows() != $qOpname->num_rows()) : ?>
                                        <th class="text-center text-white">Insert Status</i></th>
                                    <?php endif; ?>
                                </tr>
                            </thead>
                            <tbody class="text-gray-600 fw-bold">
                                <?php $i = 1; ?>
                                <?php if ($qValidateOpname->num_rows() != $qOpname->num_rows()) : ?>
                                    <input type="hidden" id="pesan" value="Proses copy Qty berhasil...">
                                    <?php $this->db->query($qDeleteOpname); ?>
                                    <?php foreach ($qOpname->result() as $li) : ?>
                                        <tr>
                                            <td class="text-center"><?= $i ?></td>
                                            <td class="text-center"><?= $li->Item_Code ?></td>
                                            <td class="text-center"><?= $li->Item_Name; ?></td>
                                            <td class="text-center"><?= $li->Dimension_Name; ?></td>
                                            <td class="text-center"><?= number_format($li->Item_Qty, 2, ".", ",") ?></td>
                                            <?php $insert = $this->db->insert(
                                                'TCOUNTITEM',
                                                [
                                                    'COUNTITEM_CATEGORY_TYPE' => $selCatType,
                                                    'ITEM_CODE' => $li->Item_Code,
                                                    'QTY_ONHAND' => $li->Item_Qty,
                                                    'STOCK_OPNAME' => $li->Item_Qty,
                                                    'BALANCE_OPNAME' => 0,
                                                    'COMPANY_ID' => 2,
                                                    'WH_ID' => $SelLocation,
                                                    'BIN_ID' => $Gudang,
                                                    'LAST_UPDATE' => $DateOpname,
                                                    'UPDATED_BY' => $this->session->userdata('sys_sba_userid'),
                                                    'DIMENSION_ID' => $li->Dimension_ID,
                                                ]
                                            ); ?>
                                            <td class="text-center"> <?php if ($insert) : ?>
                                                    <?= number_format($li->Item_Qty, 2, ".", ",") ?>
                                                <?php else : ?>
                                                    0.00
                                                <?php endif; ?></td>
                                            <td class="text-center">0.00</td>
                                            <td class="text-center"><?= $li->Unit_Name ?></td>
                                            <td class="text-center">
                                                <?php if ($insert) : ?>
                                                    <i class="fas fa-check text-success"></i>
                                                <?php else : ?>
                                                    <i class="fas fa-times text-danger"></i>
                                                <?php endif; ?>
                                            </td>
                                        </tr>
                                        <?php $i++; ?>
                                    <?php endforeach; ?>

                                <?php else : ?>
                                    <input type="hidden" id="pesan" value="Proses copy sudah pernah di lakukan, system menampilkan list item...">
                                    <?php foreach ($qValidateOpname->result() as $li) : ?>
                                        <tr>
                                            <td class="text-center"><?= $i ?></td>
                                            <td class="text-center"><?= $li->ITEM_CODE ?></td>
                                            <td class="text-center"><?= $li->Item_Name; ?></td>
                                            <td class="text-center"><?= $li->Dimension_Name; ?></td>
                                            <td class="text-center"><?= number_format($li->QTY_ONHAND, 2, ".", ",") ?></td>
                                            <td class="text-center"><?= number_format($li->STOCK_OPNAME, 2, ".", ",") ?></td>
                                            <td class="text-center"><?= number_format($li->BALANCE_OPNAME, 2, ".", ",") ?></td>
                                            <td class="text-center"><?= $li->Unit_Name ?></td>
                                        </tr>
                                        <?php $i++; ?>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- <div class="card-footer">
                    Footer
                </div> -->
            </div>
        </div>
    </div>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/plugins/global/plugins.bundle.js"></script>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/js/scripts.bundle.js"></script>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/datatables/datatables.bundle.js"></script>
</body>
<script>
    $(document).ready(function() {
        const pesan = $('#pesan').val();

        $("#TableData").DataTable({
            lengthMenu: [
                [15, 30, 50, -1],
                [15, 30, 50, 'All']
            ],
            dom: '<"row"<"col"l><"col"B>>frtip',
            // select: true,
            "buttons": [{
                text: `Export to :`,
                className: "btn btn-sm disabled btn-light font-weight-bold",
            }, {
                text: `<i class="far fa-copy fs-2"></i>`,
                extend: 'copy',
                className: "btn btn-sm btn-warning",
            }, {
                text: `<i class="far fa-file-excel fs-2"></i>`,
                extend: 'excelHtml5',
                title: 'Opname <?= $RowLocation->wh_name ?>-<?= $ItemCategoryTypeTxt ?>-<?= $TxtCategory ?>-<?= $RowGudang->Bin_Name ?>-<?= $DateOpname ?>',
                className: "btn btn-sm btn-success",
            }],
            "initComplete": function(settings, json) {
                $('#loader').hide()
                Swal.fire({
                    icon: 'info',
                    title: 'Notificatiobn',
                    text: pesan,
                    footer: '<a href="javascript:void(0)">Notifikasi System</a>'
                });
            }
        }).buttons().container().appendTo('TableData_wrapper .col-md-6:eq(0)');
    });
</script>

</html>