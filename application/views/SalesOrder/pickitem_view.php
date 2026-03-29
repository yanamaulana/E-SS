<?php

/**
 * APPLICATION : SAI ERP - Migration to CI3
 * FILENAME    : pickitem_view.php
 * DESCRIPTION : Pick Item for Sales Order (FG) with Pagination
 * AUTHOR      : Gemini AI (Collab with Mas Yana)
 */

// 1. TANGKAP PARAMETER DARI FORM/URL
$cboCustomer = $this->input->get_post('cboCustomer') ?? '';
$selType     = $this->input->get_post('selType') ?? 'ItemCode';
$ExtraQuery  = $this->input->get_post('ExtraQuery') ?? '';
$selPage     = (int)($this->input->get_post('selPage') ?? 1);
$limit       = 15; // Batasi 50 baris agar RAM tidak jebol
$offset      = ($selPage - 1) * $limit;
$companyID   = 2;  // Sesuai log debugger CF10

// 2. QUERY LIST CUSTOMER (Filter Data Group 20, 86)
$sqlCust = "
    SELECT Account_ID, AccountTitle_Code, Account_Code, Account_Name
    FROM TAccount
    WHERE $companyID IN (TAccount.company_id)
    AND TAccount.Cust_FG = 1
    AND TAccount.Category_ID IN (
        SELECT DISTINCT CATEGORY_ID FROM TDATAGROUPACCOUNT WHERE DATAGROUP_ID IN (20, 86)
    )
    AND Status = '1' AND isnull(TAccount.Flag, 0) = 0
    ORDER BY Account_Name ASC
";
$qCustomer = $this->db->query($sqlCust)->result();

// 3. LOGIC PENCARIAN ITEM
$sqlSearch = "";
if (!empty($ExtraQuery)) {
    if ($selType == 'ItemCode') {
        $sqlSearch = " AND TITEM.item_code LIKE '%$ExtraQuery%' ";
    } elseif ($selType == 'ItemName') {
        $sqlSearch = " AND TITEM.Item_name LIKE '%$ExtraQuery%' ";
    }
}

// 4. HITUNG TOTAL DATA (COUNT) - Untuk Pagination
$sqlCount = "
    SELECT COUNT(TITEM.item_code) as total
    FROM TITEM
    INNER JOIN TItemCompany ON TItemCompany.item_code = TItem.item_code 
    INNER JOIN TitemCategory ON TitemCategory.ItemCategory_ID = TItemCompany.ItemCategory_ID
    WHERE (TItem.InActive is NULL Or TItem.InActive = 0)
    AND TItemCompany.Company_ID = $companyID
    AND TitemCategory.ItemCategoryType = 'FG'
    AND TITEM.itemclass = 0
    AND TITEM.item_code IN (
        SELECT DISTINCT ITEM_CODE FROM TDATAGROUPITEM WHERE DATAGROUP_ID IN (20, 86)
    )
    $sqlSearch
";
$totalRows = $this->db->query($sqlCount)->row()->total;
$totalPages = ceil($totalRows / $limit);

// 5. QUERY DATA ITEM (Lengkap 7 Kolom + Pagination SQL Server)
$sqlItem = "
    SELECT 
        TITEM.item_code, 
        TITEM.Item_name, 
        tgscolor.Color_Name as Color,
        TITEM.Item_Size as Brand, 
        CAST(ISNULL(TITEM.Item_Length,0) AS VARCHAR) + ' x ' + 
        CAST(ISNULL(TITEM.Item_Width,0) AS VARCHAR) + ' x ' + 
        CAST(ISNULL(TITEM.Item_Height,0) AS VARCHAR) + ' mm' as Size,
        TITEM.customfield1 AS Type
    FROM TITEM
    INNER JOIN TItemCompany ON TItemCompany.item_code = TItem.item_code 
    INNER JOIN TitemCategory ON TitemCategory.ItemCategory_ID = TItemCompany.ItemCategory_ID
    INNER JOIN TItemDimension ON TItemDimension.Dimension_ID = TItemCompany.Dimension_ID 
    LEFT JOIN tgscolor ON tgscolor.color_code = TITEM.item_color
    WHERE (TItem.InActive is NULL Or TItem.InActive = 0)
    AND TItemCompany.Company_ID = $companyID
    AND TitemCategory.ItemCategoryType = 'FG'
    AND TITEM.itemclass = 0
    AND TITEM.item_code IN (
        SELECT DISTINCT ITEM_CODE FROM TDATAGROUPITEM WHERE DATAGROUP_ID IN (20, 86)
    )
    $sqlSearch
    ORDER BY TITEM.item_code ASC
    OFFSET $offset ROWS FETCH NEXT $limit ROWS ONLY
";
$qItem = $this->db->query($sqlItem)->result();
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Pick Item - FG Sales</title>
    <link rel="canonical" href="<?= base_url() ?>" />
    <link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
    <link rel="stylesheet" href="<?= base_url() ?>assets/E-SBA_assets/font/main-font.css">
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/fullcalendar/fullcalendar.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/plugins/global/plugins.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/css/style.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/datatables/datatables.bundle.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/Metronic/dist/assets/css/custom.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url() ?>assets/global-assets/custom-table.css" rel="stylesheet" type="text/css" />
    <script src="<?= base_url() ?>assets/global-assets/jquery/jquery.min.js"></script>
    <script src="<?= base_url() ?>assets/global-assets/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css"></script>
    <style>
        body {
            font-size: 11px;
            font-family: 'Tahoma', sans-serif;
            overflow: hidden;
        }

        .header-blue {
            background: #000066;
            color: #fff;
            padding: 6px 10px;
            font-weight: bold;
            border-bottom: 2px solid #cc0000;
        }

        .filter-section {
            background: #f8f9fa;
            border-bottom: 1px solid #ccc;
            padding: 10px;
        }

        .table-area {
            height: 320px;
            overflow-y: auto;
            border: 1px solid #ccc;
            background: #fff;
        }

        thead th {
            position: sticky;
            top: 0;
            background: #eee;
            z-index: 10;
            border-bottom: 2px solid #ddd !important;
        }

        .footer-action {
            background: #eee;
            padding: 10px;
            border-top: 1px solid #ccc;
        }

        .required {
            color: red;
            font-weight: bold;
        }

        .input-group-text {
            font-size: 11px;
        }
    </style>
</head>

<body class="p-0" onload="self.focus();">

    <div class="header-blue">List of Item (Finished Goods)</div>

    <form name="frmSearch" id="frmSearch" method="post" action="">
        <div class="filter-section">
            <div class="row mb-2">
                <div class="col-3 text-right">Customer <span class="required">*</span> :</div>
                <div class="col-9">
                    <select name="cboCustomer" id="cboCustomer" class="form-control form-control-sm" data-control="select2">
                        <option value="">-- Select Customer --</option>
                        <?php foreach ($qCustomer as $c): ?>
                            <option value="<?= $c->Account_ID ?>" <?= ($cboCustomer == $c->Account_ID) ? 'selected' : '' ?>>
                                <?php
                                $title = trim($c->AccountTitle_Code ?? '');
                                echo (!empty($title) ? $title . '. ' : '') . $c->Account_Name . ' [' . trim($c->Account_Code ?? '') . ']';
                                ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <div class="row mb-2">
                <div class="col-3 text-right">Search Text <span class="required">*</span> :</div>
                <div class="col-9">
                    <div class="input-group input-group-sm">
                        <select name="selType" class="form-control col-3">
                            <option value="ItemCode" <?= ($selType == 'ItemCode') ? 'selected' : '' ?>>Item Code</option>
                            <option value="ItemName" <?= ($selType == 'ItemName') ? 'selected' : '' ?>>Item Name</option>
                        </select>
                        <input type="text" name="ExtraQuery" class="form-control" value="<?= $ExtraQuery ?>" placeholder="Keyword...">
                        <div class="input-group-append">
                            <button type="submit" class="btn btn-primary btn-sm" onclick="resetPage();">Search</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-3 text-right">Page List :</div>
                <div class="col-9">
                    <select name="selPage" class="form-control form-control-sm col-2 d-inline" onchange="this.form.submit();">
                        <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                            <option value="<?= $i ?>" <?= ($selPage == $i) ? 'selected' : '' ?>><?= $i ?></option>
                        <?php endfor; ?>
                    </select>
                    <span class="ml-2 text-muted">of <?= $totalPages ?> pages (Total Items: <?= $totalRows ?>)</span>
                </div>
            </div>
        </div>

        <div class="px-2 mt-2">
            <div class="table-area">
                <table class="table table-sm table-bordered mb-0 text-nowrap">
                    <thead class="text-center">
                        <tr>
                            <th width="30"><input type="checkbox" id="chkAll"></th>
                            <th width="40">No.</th>
                            <th>Item Code</th>
                            <th>Item Name</th>
                            <th>Color</th>
                            <th>Brand</th>
                            <th>Size</th>
                            <th>Type</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($qItem)): ?>
                            <tr>
                                <td colspan="8" class="text-center py-4">-- No Record Found --</td>
                            </tr>
                            <?php else:
                            $no = $offset + 1;
                            foreach ($qItem as $row): ?>
                                <tr>
                                    <td class="text-center">
                                        <input type="checkbox" name="chkItem" value="<?= $row->item_code ?>">
                                    </td>
                                    <td class="text-center"><?= $no++ ?></td>
                                    <td><?= $row->item_code ?></td>
                                    <td><?= $row->Item_name ?></td>
                                    <td class="text-center"><?= $row->Color ?? '-' ?></td>
                                    <td class="text-center"><?= $row->Brand ?? '-' ?></td>
                                    <td class="text-center"><?= $row->Size ?></td>
                                    <td><?= $row->Type ?></td>
                                </tr>
                        <?php endforeach;
                        endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="footer-action">
            <button type="button" class="btn btn-sm btn-primary px-4" onclick="selectalot('C')">Select Item</button>
            <button type="button" class="btn btn-sm btn-secondary" onclick="window.close()">Close Window</button>
        </div>
    </form>

    <script src="<?= base_url() ?>assets/Metronic/dist/assets/plugins/global/plugins.bundle.js"></script>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/js/scripts.bundle.js"></script>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/fullcalendar/fullcalendar.bundle.js"></script>
    <script src="<?= base_url() ?>assets/Metronic/dist/assets/plugins/custom/datatables/datatables.bundle.js"></script>
    <script src="<?= base_url() ?>assets/global-assets/jquery-validation/jquery.validate.js"></script>
    <script src="<?= base_url() ?>assets/global-assets/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"></script>
    <script>
        // Reset page to 1 on filter change
        function resetPage() {
            $('select[name="selPage"]').val(1);
            $('#frmSearch').submit();
        }

        // Check All logic
        $('#chkAll').click(function() {
            $('input[name="chkItem"]').prop('checked', this.checked);
        });

        // Parent window integration (getItem function)
        function selectalot(meth) {
            if ($('#cboCustomer').val() == "") {
                alert("Please Select Customer!");
                return false;
            }

            var checkedItems = $('input[name="chkItem"]:checked').length;
            if (checkedItems == 0) {
                alert("Please Pick at least one Item!");
                return false;
            }

            // Cek apakah opener (halaman utama) ada dan fungsinya tersedia
            if (window.opener && !window.opener.closed) {
                if (typeof window.opener.getItem === 'function') {
                    // Simpan referensi window ini ke parent agar parent bisa baca isinya
                    window.opener.pickItemWindow = window;
                    window.opener.getItem(meth);
                    window.close();
                } else {
                    alert("Error: Fungsi getItem tidak ditemukan di halaman utama!");
                }
            }
        }
    </script>

</body>

</html>