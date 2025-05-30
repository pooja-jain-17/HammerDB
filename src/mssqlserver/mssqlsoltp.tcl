proc build_mssqlstpcc {} {
    global maxvuser suppo ntimes threadscreated _ED
    upvar #0 dbdict dbdict
    if {[dict exists $dbdict mssqlserver library ]} {
        set library [ dict get $dbdict mssqlserver library ]
    } else { set library "tdbc::odbc 1.0.6" }
    if { [ llength $library ] > 1 } { 
        set version [ lindex $library 1 ]
        set library [ lindex $library 0 ]
    }
    upvar #0 configmssqlserver configmssqlserver
    #set variables to values in dict
    setlocaltpccvars $configmssqlserver
    if {![string match windows $::tcl_platform(platform)]} {
        set mssqls_server $mssqls_linux_server 
        set mssqls_odbc_driver $mssqls_linux_odbc
        set mssqls_authentication $mssqls_linux_authent 
    }
    if {[ tk_messageBox -title "Create Schema" -icon question -message "Ready to create a $mssqls_count_ware Warehouse MS SQL Server TPROC-C schema\nin host [string toupper $mssqls_server ] in database [ string toupper $mssqls_dbase ]?" -type yesno ] == yes} { 
        if { $mssqls_num_vu eq 1 || $mssqls_count_ware eq 1 } {
            set maxvuser 1
        } else {
            set maxvuser [ expr $mssqls_num_vu + 1 ]
        }
        set suppo 1
        set ntimes 1
        ed_edit_clear
        set _ED(packagekeyname) "TPROC-C creation"
        if { [catch {load_virtual} message]} {
            puts "Failed to created thread for schema creation: $message"
            return
        }
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#LOAD LIBRARIES AND MODULES
set library $library
set version $version
"
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }
proc CreateStoredProcs { odbc imdb } {
    puts "CREATING TPCC STORED PROCEDURES"
    if { $imdb } {
        set sql(1) {CREATE PROCEDURE [dbo].[neword]
            @no_w_id int,
            @no_max_w_id int,
            @no_d_id int,
            @no_c_id int,
            @no_o_ol_cnt int,
            @TIMESTAMP datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @no_c_discount smallmoney,
            @no_c_last char(16),
            @no_c_credit char(2),
            @no_d_tax smallmoney,
            @no_w_tax smallmoney,
            @no_d_next_o_id int,
            @no_ol_supply_w_id int,
            @no_ol_i_id int,
            @no_ol_quantity int,
            @no_o_all_local int,
            @o_id int,
            @no_i_name char(24),
            @no_i_price smallmoney,
            @no_i_data char(50),
            @no_s_quantity int,
            @no_ol_amount int,
            @no_s_dist_01 char(24),
            @no_s_dist_02 char(24),
            @no_s_dist_03 char(24),
            @no_s_dist_04 char(24),
            @no_s_dist_05 char(24),
            @no_s_dist_06 char(24),
            @no_s_dist_07 char(24),
            @no_s_dist_08 char(24),
            @no_s_dist_09 char(24),
            @no_s_dist_10 char(24),
            @no_ol_dist_info char(24),
            @no_s_data char(50),
            @x int,
            @rbk int
            BEGIN TRANSACTION
            BEGIN TRY
            SET @no_o_all_local = 1
            SELECT
            @no_c_discount = c_discount,
            @no_c_last = c_last,
            @no_c_credit = c_credit
            FROM dbo.customer
            WHERE
            c_w_id = @no_w_id AND
            c_d_id = @no_d_id AND
            c_id = @no_c_id
            UPDATE dbo.district
            SET
            @no_d_tax = d_tax,
            @o_id = d_next_o_id,
            @no_d_next_o_id = d_next_o_id = district.d_next_o_id + 1
            WHERE district.d_id = @no_d_id
            AND district.d_w_id = @no_w_id
            SET @rbk = CAST(100 * RAND() + 1 AS INT)
            DECLARE
            @loop_counter int
            SET @loop_counter = 1
            DECLARE
            @loop$bound int
            SET @loop$bound = @no_o_ol_cnt
            WHILE @loop_counter <= @loop$bound
            BEGIN
            IF ((@loop_counter = @no_o_ol_cnt) AND (@rbk = 1))
            SET @no_ol_i_id = 100001
            ELSE
            SET @no_ol_i_id = CAST(100000 * RAND() + 1 AS INT)
            SET @x = CAST(100 * RAND() + 1 AS INT)
            IF (@x > 1)
            SET @no_ol_supply_w_id = @no_w_id
            ELSE
            BEGIN
            SET @no_ol_supply_w_id = @no_w_id
            SET @no_o_all_local = 0
            WHILE ((@no_ol_supply_w_id = @no_w_id) AND (@no_max_w_id != 1))
            BEGIN
            SET @no_ol_supply_w_id = CAST(@no_max_w_id * RAND() + 1 AS INT)
            DECLARE
            @db_null_statement$2 int
            END
            END
            SET @no_ol_quantity = CAST(10 * RAND() + 1 AS INT)
            SELECT @no_i_price = item.i_price
            , @no_i_name = item.i_name
            , @no_i_data = item.i_data
            FROM dbo.item
            WHERE item.i_id = @no_ol_i_id
            UPDATE dbo.stock
            SET
            s_quantity = s_quantity - @no_ol_quantity + CASE WHEN (s_quantity > @no_ol_quantity)
            THEN 0 ELSE 91 END,
            @no_s_data = s_data,
            @no_ol_dist_info =
            CASE @no_d_id
            WHEN 1 THEN s_dist_01
            WHEN 2 THEN s_dist_02
            WHEN 3 THEN s_dist_03
            WHEN 4 THEN s_dist_04
            WHEN 5 THEN s_dist_05
            WHEN 6 THEN s_dist_06
            WHEN 7 THEN s_dist_07
            WHEN 8 THEN s_dist_08
            WHEN 9 THEN s_dist_09
            WHEN 10 THEN s_dist_10
            END
            OUTPUT
            @o_id,
            @no_d_id,
            @no_w_id,
            @loop_counter,
            @no_ol_i_id,
            NULL,
            (@no_ol_quantity * @no_i_price),
            @no_ol_supply_w_id,
            @no_ol_quantity,
            CASE @no_d_id
            WHEN 1 THEN inserted.s_dist_01
            WHEN 2 THEN inserted.s_dist_02
            WHEN 3 THEN inserted.s_dist_03
            WHEN 4 THEN inserted.s_dist_04
            WHEN 5 THEN inserted.s_dist_05
            WHEN 6 THEN inserted.s_dist_06
            WHEN 7 THEN inserted.s_dist_07
            WHEN 8 THEN inserted.s_dist_08
            WHEN 9 THEN inserted.s_dist_09
            WHEN 10 THEN inserted.s_dist_10
            END
            INTO dbo.order_line
            WHERE
            stock.s_i_id = @no_ol_i_id AND
            stock.s_w_id = @no_ol_supply_w_id
            SET @loop_counter = @loop_counter + 1
            END
            INSERT dbo.orders( o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local)
            VALUES ( @o_id, @no_d_id, @no_w_id, @no_c_id, @TIMESTAMP, @no_o_ol_cnt, @no_o_all_local)
            INSERT dbo.new_order(no_o_id, no_d_id, no_w_id)
            VALUES (@o_id, @no_d_id, @no_w_id)
            IF (@rbk = 1)
            ROLLBACK TRANSACTION
            SELECT @no_w_tax = warehouse.w_tax
            FROM dbo.warehouse
            WHERE warehouse.w_id = @no_w_id
            SELECT convert(char(8), @no_c_discount) as N'@no_c_discount', @no_c_last as N'@no_c_last', @no_c_credit 
	    as N'@no_c_credit', convert(char(8),@no_d_tax) as N'@no_d_tax', convert(char(8),@no_w_tax)
            as N'@no_w_tax', @no_d_next_o_id as N'@no_d_next_o_id'
            END TRY
            BEGIN CATCH
	    IF (error_number() in (701, 41839, 41823, 41302, 41305, 41325, 41301))
            SELECT 'IMOLTPERROR',ERROR_NUMBER() AS ErrorNumber
            ELSE
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(2) {CREATE PROCEDURE [dbo].[delivery]
            @d_w_id int,
            @d_o_carrier_id int,
            @timestamp datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @d_no_o_id int,
            @d_d_id int,
            @d_c_id int,
            @d_ol_total int
            BEGIN TRANSACTION
            BEGIN TRY
            DECLARE
            @loop_counter int
            SET @loop_counter = 1
            WHILE @loop_counter <= 10
            BEGIN
            SET @d_d_id = @loop_counter
            SELECT TOP 1
            @d_no_o_id = no_o_id
            FROM dbo.new_order
            WHERE no_w_id = @d_w_id AND
            no_d_id = @d_d_id
            ORDER BY no_o_id ASC
            IF (@@rowcount <> 0)
            BEGIN
            -- claim the order for this district
            DELETE dbo.new_order
            WHERE no_w_id = @d_w_id AND
            no_d_id = @d_d_id AND
            no_o_id = @d_no_o_id
            UPDATE dbo.orders
            SET o_carrier_id = @d_o_carrier_id
            , @d_c_id = orders.o_c_id
            WHERE orders.o_id = @d_no_o_id
            AND orders.o_d_id = @d_d_id
            AND orders.o_w_id = @d_w_id
            SET @d_ol_total = 0
            UPDATE dbo.order_line
            SET ol_delivery_d = @timestamp
            , @d_ol_total = @d_ol_total + ol_amount
            WHERE order_line.ol_o_id = @d_no_o_id
            AND order_line.ol_d_id = @d_d_id
            AND order_line.ol_w_id = @d_w_id
            END
            UPDATE dbo.customer SET c_balance = customer.c_balance + @d_ol_total
            WHERE customer.c_id = @d_c_id
            AND customer.c_d_id = @d_d_id
            AND customer.c_w_id = @d_w_id
      
            PRINT
            'D: '
            +
            ISNULL(CAST(@d_d_id AS nvarchar(4000)), '')
            +
            'O: '
            +
            ISNULL(CAST(@d_no_o_id AS nvarchar(4000)), '')
            +
            'time '
            +
            ISNULL(CAST(@timestamp AS nvarchar(4000)), '')
            SET @loop_counter = @loop_counter + 1
            END
            SELECT @d_w_id as N'@d_w_id', @d_o_carrier_id as N'@d_o_carrier_id', @timestamp as N'@TIMESTAMP'
            END TRY
            BEGIN CATCH
	    IF (error_number() in (701, 41839, 41823, 41302, 41305, 41325, 41301))
            SELECT 'IMOLTPERROR',ERROR_NUMBER() AS ErrorNumber
            ELSE
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(3) {CREATE PROCEDURE [dbo].[payment]
            @p_w_id int,
            @p_d_id int,
            @p_c_w_id int,
            @p_c_d_id int,
            @p_c_id int,
            @byname int,
            @p_h_amount numeric(6,2),
            @p_c_last char(16),
            @TIMESTAMP datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @p_w_street_1 char(20),
            @p_w_street_2 char(20),
            @p_w_city char(20),
            @p_w_state char(2),
            @p_w_zip char(10),
            @p_d_street_1 char(20),
            @p_d_street_2 char(20),
            @p_d_city char(20),
            @p_d_state char(20),
            @p_d_zip char(10),
            @p_c_first char(16),
            @p_c_middle char(2),
            @p_c_street_1 char(20),
            @p_c_street_2 char(20),
            @p_c_city char(20),
            @p_c_state char(20),
            @p_c_zip char(9),
            @p_c_phone char(16),
            @p_c_since datetime2(0),
            @p_c_credit char(32),
            @p_c_credit_lim numeric(12,2),
            @p_c_discount numeric(4,4),
            @p_c_balance money,
            --numeric(12,2),
            @p_c_data varchar(500),
            @namecnt int,
            @p_d_name char(11),
            @p_w_name char(11),
            @p_c_new_data varchar(500),
            @h_data varchar(30)
            BEGIN TRY
            IF (@byname = 1)
            BEGIN
            SELECT TOP 1
            @p_c_id = c_id
            FROM (
            SELECT TOP 50 PERCENT c_id, c_first
            FROM dbo.customer 
            WHERE
            c_last = @p_c_last AND
            c_w_id = @p_c_w_id AND
            c_d_id = @p_c_d_id
            ORDER BY c_first) X
            ORDER BY c_first desc
            END
            BEGIN TRANSACTION
            -- get customer info and update balances
            UPDATE dbo.customer
            SET
            @p_c_balance = c_balance = c_balance - @p_h_amount,
            c_data =
            CASE
            WHEN c_credit <> 'BC' THEN c_credit
            ELSE LEFT(
            ISNULL(CAST(@p_c_id AS char), '') + ' ' +
            ISNULL(CAST(@p_c_d_id AS char), '') + ' ' +
            ISNULL(CAST(@p_c_w_id AS char), '') + ' ' +
            ISNULL(CAST(@p_d_id AS char), '') + ' ' +
            ISNULL(CAST(@p_w_id AS char), '') + ' ' +
            ISNULL(CAST(@p_h_amount AS CHAR(8)), '') + ' ' +
            ISNULL(CAST(@TIMESTAMP AS char), '') + ' ' +
            ISNULL(@p_w_name, '') + ' ' +
            ISNULL(@p_d_name, '') + ' ' +
            c_data,
            500)
            END,
            @p_c_first = c_first,
            @p_c_middle = c_middle,
            @p_c_last = c_last,
            @p_c_street_1 = c_street_1,
            @p_c_street_2 = c_street_2,
            @p_c_city = c_city,
            @p_c_state = c_state,
            @p_c_zip = c_zip,
            @p_c_phone = c_phone,
            @p_c_credit = c_credit,
            @p_c_credit_lim = c_credit_lim,
            @p_c_discount = c_discount,
            @p_c_since = c_since
            WHERE
            c_id = @p_c_id AND
            c_w_id = @p_c_w_id AND
            c_d_id = @p_c_d_id
            SET @h_data = (ISNULL(@p_w_name, '') + ' ' + ISNULL(@p_d_name, ''))
            INSERT dbo.history( h_c_d_id, h_c_w_id, h_c_id, h_d_id, h_w_id, h_date, h_amount, h_data)
            VALUES ( @p_c_d_id, @p_c_w_id, @p_c_id, @p_d_id, @p_w_id, @TIMESTAMP, @p_h_amount, @h_data)
            -- get district data and update year-to-date
            UPDATE dbo.district
            SET
            d_ytd = d_ytd + @p_h_amount,
            @p_d_street_1 = d_street_1,
            @p_d_street_2 = d_street_2,
            @p_d_city = d_city,
            @p_d_state = d_state,
            @p_d_zip = d_zip,
            @p_d_name = d_name
            WHERE
            d_w_id = @p_w_id AND
            d_id = @p_d_id
            -- get warehouse data and update year-to-date
            UPDATE dbo.warehouse
            SET
            w_ytd = w_ytd + @p_h_amount,
            @p_w_street_1 = w_street_1,
            @p_w_street_2 = w_street_2,
            @p_w_city = w_city,
            @p_w_state = w_state,
            @p_w_zip = w_zip,
            @p_w_name = w_name
            WHERE
            w_id = @p_w_id
            SELECT @p_c_id as N'@p_c_id', @p_c_last as N'@p_c_last', @p_w_street_1 as N'@p_w_street_1'
            , @p_w_street_2 as N'@p_w_street_2', @p_w_city as N'@p_w_city'
            , @p_w_state as N'@p_w_state', @p_w_zip as N'@p_w_zip'
            , @p_d_street_1 as N'@p_d_street_1', @p_d_street_2 as N'@p_d_street_2'
            , @p_d_city as N'@p_d_city', @p_d_state as N'@p_d_state'
            , @p_d_zip as N'@p_d_zip', @p_c_first as N'@p_c_first'
            , @p_c_middle as N'@p_c_middle', @p_c_street_1 as N'@p_c_street_1'
            , @p_c_street_2 as N'@p_c_street_2'
            , @p_c_city as N'@p_c_city', @p_c_state as N'@p_c_state', @p_c_zip as N'@p_c_zip'
            , @p_c_phone as N'@p_c_phone', @p_c_since as N'@p_c_since', @p_c_credit as N'@p_c_credit'
            , @p_c_credit_lim as N'@p_c_credit_lim', @p_c_discount as N'@p_c_discount', @p_c_balance as
            N'@p_c_balance'
            , @p_c_data as N'@p_c_data'
            END TRY
            BEGIN CATCH
	    IF (error_number() in (701, 41839, 41823, 41302, 41305, 41325, 41301))
            SELECT 'IMOLTPERROR',ERROR_NUMBER() AS ErrorNumber
            ELSE
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(4) {CREATE PROCEDURE [dbo].[ostat]
            @os_w_id int,
            @os_d_id int,
            @os_c_id int,
            @byname int,
            @os_c_last char(20)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @os_c_first char(16),
            @os_c_middle char(2),
            @os_c_balance money,
            @os_o_id int,
            @os_entdate datetime2(0),
            @os_o_carrier_id int,
            @os_ol_i_id
            INT,
            @os_ol_supply_w_id INT,
            @os_ol_quantity INT,
            @os_ol_amount
            INT,
            @os_ol_delivery_d DATE,
            @namecnt int,
            @i int
            BEGIN TRANSACTION
            BEGIN TRY
            IF (@byname = 1)
            BEGIN
            SELECT TOP 1
            @os_c_id = c_id,
            @os_c_balance = c_balance,
            @os_c_first = c_first,
            @os_c_middle = c_middle,
            @os_c_last = c_last
            FROM (
            SELECT TOP 50 PERCENT c_id, c_balance, c_first, c_middle, c_last
            FROM dbo.customer 
            WHERE
            c_last = @os_c_last AND
            c_w_id = @os_w_id AND
            c_d_id = @os_d_id
            ORDER BY c_first) X
            ORDER BY c_first desc
            END
            ELSE
            BEGIN
            SELECT @os_c_balance = customer.c_balance, @os_c_first = customer.c_first
            , @os_c_middle = customer.c_middle, @os_c_last = customer.c_last
            FROM dbo.customer 
            WHERE customer.c_id = @os_c_id AND customer.c_d_id = @os_d_id AND customer.c_w_id = @os_w_id
            END
            BEGIN
            SELECT TOP (1) @os_o_id = o_id, @os_o_carrier_id = o_carrier_id, @os_entdate = o_entry_d
            FROM dbo.orders 
            WHERE orders.o_d_id = @os_d_id
            AND orders.o_w_id = @os_w_id
            AND orders.o_c_id = @os_c_id
            ORDER BY orders.o_id DESC
            IF @@ROWCOUNT = 0
            PRINT 'No orders for customer';
            END
            SELECT order_line.ol_i_id
            , order_line.ol_supply_w_id
            , order_line.ol_quantity
            , order_line.ol_amount
            , order_line.ol_delivery_d
            FROM dbo.order_line 
            WHERE order_line.ol_o_id = @os_o_id
            AND order_line.ol_d_id = @os_d_id
            AND order_line.ol_w_id = @os_w_id
            SELECT @os_c_id as N'@os_c_id', @os_c_last as N'@os_c_last', @os_c_first as N'@os_c_first', @os_c_middle
            as N'@os_c_middle', @os_c_balance as N'@os_c_balance', @os_o_id as N'@os_o_id', @os_entdate as
            N'@os_entdate', @os_o_carrier_id as N'@os_o_carrier_id'
            END TRY
            BEGIN CATCH
	    IF (error_number() in (701, 41839, 41823, 41302, 41305, 41325, 41301))
            SELECT 'IMOLTPERROR',ERROR_NUMBER() AS ErrorNumber
            ELSE
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(5) {CREATE PROCEDURE [dbo].[slev]
            @st_w_id int,
            @st_d_id int,
            @threshold int
            AS
            BEGIN
            DECLARE
            @st_o_id_low int,
            @st_o_id_high int
            BEGIN TRANSACTION
            BEGIN TRY
            SELECT
            @st_o_id_low = district.d_next_o_id - 20,
            @st_o_id_high = district.d_next_o_id - 1
            FROM dbo.district
            WHERE district.d_w_id = @st_w_id AND district.d_id = @st_d_id
            SELECT
            COUNT(DISTINCT stock.s_i_id)
            FROM dbo.order_line
            , dbo.stock
            WHERE order_line.ol_w_id = @st_w_id
            AND order_line.ol_d_id = @st_d_id
            AND order_line.ol_o_id BETWEEN @st_o_id_low AND @st_o_id_high
            AND stock.s_w_id = order_line.ol_w_id
            AND stock.s_i_id = order_line.ol_i_id
            AND stock.s_quantity < @threshold
	    OPTION (ORDER GROUP, LOOP JOIN, MAXDOP 1);
            END TRY
            BEGIN CATCH
	    IF (error_number() in (701, 41839, 41823, 41302, 41305, 41325, 41301))
            SELECT 'IMOLTPERROR',ERROR_NUMBER() AS ErrorNumber
            ELSE
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
    } else {
        set sql(1) {CREATE PROCEDURE [dbo].[neword]
            @no_w_id int,
            @no_max_w_id int,
            @no_d_id int,
            @no_c_id int,
            @no_o_ol_cnt int,
            @TIMESTAMP datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @no_c_discount smallmoney,
            @no_c_last char(16),
            @no_c_credit char(2),
            @no_d_tax smallmoney,
            @no_w_tax smallmoney,
            @no_d_next_o_id int,
            @no_ol_supply_w_id int,
            @no_ol_i_id int,
            @no_ol_quantity int,
            @no_o_all_local int,
            @o_id int,
            @no_i_name char(24),
            @no_i_price smallmoney,
            @no_i_data char(50),
            @no_s_quantity int,
            @no_ol_amount int,
            @no_s_dist_01 char(24),
            @no_s_dist_02 char(24),
            @no_s_dist_03 char(24),
            @no_s_dist_04 char(24),
            @no_s_dist_05 char(24),
            @no_s_dist_06 char(24),
            @no_s_dist_07 char(24),
            @no_s_dist_08 char(24),
            @no_s_dist_09 char(24),
            @no_s_dist_10 char(24),
            @no_ol_dist_info char(24),
            @no_s_data char(50),
            @x int,
            @rbk int
            BEGIN TRANSACTION
            BEGIN TRY
            SET @no_o_all_local = 1
            SELECT
            @no_c_discount = c_discount,
            @no_c_last = c_last,
            @no_c_credit = c_credit
            FROM dbo.customer
            WHERE
            c_w_id = @no_w_id AND
            c_d_id = @no_d_id AND
            c_id = @no_c_id
            UPDATE dbo.district
            SET
            @no_d_tax = d_tax,
            @o_id = d_next_o_id,
            @no_d_next_o_id = d_next_o_id = district.d_next_o_id + 1
            WHERE district.d_id = @no_d_id
            AND district.d_w_id = @no_w_id
            SET @rbk = CAST(100 * RAND() + 1 AS INT)
            DECLARE
            @loop_counter int
            SET @loop_counter = 1
            DECLARE
            @loop$bound int
            SET @loop$bound = @no_o_ol_cnt
            WHILE @loop_counter <= @loop$bound
            BEGIN
            IF ((@loop_counter = @no_o_ol_cnt) AND (@rbk = 1))
            SET @no_ol_i_id = 100001
            ELSE
            SET @no_ol_i_id = CAST(100000 * RAND() + 1 AS INT)
            SET @x = CAST(100 * RAND() + 1 AS INT)
            IF (@x > 1)
            SET @no_ol_supply_w_id = @no_w_id
            ELSE
            BEGIN
            SET @no_ol_supply_w_id = @no_w_id
            SET @no_o_all_local = 0
            WHILE ((@no_ol_supply_w_id = @no_w_id) AND (@no_max_w_id != 1))
            BEGIN
            SET @no_ol_supply_w_id = CAST(@no_max_w_id * RAND() + 1 AS INT)
            DECLARE
            @db_null_statement$2 int
            END
            END
            SET @no_ol_quantity = CAST(10 * RAND() + 1 AS INT)
            SELECT @no_i_price = item.i_price
            , @no_i_name = item.i_name
            , @no_i_data = item.i_data
            FROM dbo.item
            WHERE item.i_id = @no_ol_i_id
            UPDATE dbo.stock
            SET
            s_quantity = s_quantity - @no_ol_quantity + CASE WHEN (s_quantity > @no_ol_quantity)
            THEN 0 ELSE 91 END,
            @no_s_data = s_data,
            @no_ol_dist_info =
            CASE @no_d_id
            WHEN 1 THEN s_dist_01
            WHEN 2 THEN s_dist_02
            WHEN 3 THEN s_dist_03
            WHEN 4 THEN s_dist_04
            WHEN 5 THEN s_dist_05
            WHEN 6 THEN s_dist_06
            WHEN 7 THEN s_dist_07
            WHEN 8 THEN s_dist_08
            WHEN 9 THEN s_dist_09
            WHEN 10 THEN s_dist_10
            END
            OUTPUT
            @o_id,
            @no_d_id,
            @no_w_id,
            @loop_counter,
            @no_ol_i_id,
            NULL,
            (@no_ol_quantity * @no_i_price),
            @no_ol_supply_w_id,
            @no_ol_quantity,
            CASE @no_d_id
            WHEN 1 THEN inserted.s_dist_01
            WHEN 2 THEN inserted.s_dist_02
            WHEN 3 THEN inserted.s_dist_03
            WHEN 4 THEN inserted.s_dist_04
            WHEN 5 THEN inserted.s_dist_05
            WHEN 6 THEN inserted.s_dist_06
            WHEN 7 THEN inserted.s_dist_07
            WHEN 8 THEN inserted.s_dist_08
            WHEN 9 THEN inserted.s_dist_09
            WHEN 10 THEN inserted.s_dist_10
            END
            INTO dbo.order_line
            WHERE
            stock.s_i_id = @no_ol_i_id AND
            stock.s_w_id = @no_ol_supply_w_id
            SET @loop_counter = @loop_counter + 1
            END
            INSERT dbo.orders( o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local)
            VALUES ( @o_id, @no_d_id, @no_w_id, @no_c_id, @TIMESTAMP, @no_o_ol_cnt, @no_o_all_local)
            INSERT dbo.new_order(no_o_id, no_d_id, no_w_id)
            VALUES (@o_id, @no_d_id, @no_w_id)
            IF (@rbk = 1)
            ROLLBACK TRANSACTION
            SELECT @no_w_tax = warehouse.w_tax
            FROM dbo.warehouse
            WHERE warehouse.w_id = @no_w_id
            SELECT convert(char(8), @no_c_discount) as N'@no_c_discount', @no_c_last as N'@no_c_last', @no_c_credit 
	    as N'@no_c_credit', convert(char(8),@no_d_tax) as N'@no_d_tax', convert(char(8),@no_w_tax)
            as N'@no_w_tax', @no_d_next_o_id as N'@no_d_next_o_id'
            END TRY
            BEGIN CATCH
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(2) {CREATE PROCEDURE [dbo].[delivery]
            @d_w_id int,
            @d_o_carrier_id int,
            @timestamp datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @d_no_o_id int,
            @d_d_id int,
            @d_c_id int,
            @d_ol_total int
            BEGIN TRANSACTION
            BEGIN TRY
            DECLARE
            @loop_counter int
            SET @loop_counter = 1
            WHILE @loop_counter <= 10
            BEGIN
            SET @d_d_id = @loop_counter
            SELECT TOP 1
            @d_no_o_id = no_o_id
            FROM dbo.new_order WITH (serializable updlock)
            WHERE no_w_id = @d_w_id AND
            no_d_id = @d_d_id
            ORDER BY no_o_id ASC
            IF (@@rowcount <> 0)
            BEGIN
            -- claim the order for this district
            DELETE dbo.new_order
            WHERE no_w_id = @d_w_id AND
            no_d_id = @d_d_id AND
            no_o_id = @d_no_o_id
            UPDATE dbo.orders
            SET o_carrier_id = @d_o_carrier_id
            , @d_c_id = orders.o_c_id
            WHERE orders.o_id = @d_no_o_id
            AND orders.o_d_id = @d_d_id
            AND orders.o_w_id = @d_w_id
            SET @d_ol_total = 0
            UPDATE dbo.order_line
            SET ol_delivery_d = @timestamp
            , @d_ol_total = @d_ol_total + ol_amount
            WHERE order_line.ol_o_id = @d_no_o_id
            AND order_line.ol_d_id = @d_d_id
            AND order_line.ol_w_id = @d_w_id
            END
            UPDATE dbo.customer SET c_balance = customer.c_balance + @d_ol_total
            WHERE customer.c_id = @d_c_id
            AND customer.c_d_id = @d_d_id
            AND customer.c_w_id = @d_w_id
      
            PRINT
            'D: '
            +
            ISNULL(CAST(@d_d_id AS nvarchar(4000)), '')
            +
            'O: '
            +
            ISNULL(CAST(@d_no_o_id AS nvarchar(4000)), '')
            +
            'time '
            +
            ISNULL(CAST(@timestamp AS nvarchar(4000)), '')
            SET @loop_counter = @loop_counter + 1
            END
            SELECT @d_w_id as N'@d_w_id', @d_o_carrier_id as N'@d_o_carrier_id', @timestamp as N'@TIMESTAMP'
            END TRY
            BEGIN CATCH
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(3) {CREATE PROCEDURE [dbo].[payment]
            @p_w_id int,
            @p_d_id int,
            @p_c_w_id int,
            @p_c_d_id int,
            @p_c_id int,
            @byname int,
            @p_h_amount numeric(6,2),
            @p_c_last char(16),
            @TIMESTAMP datetime2(0)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @p_w_street_1 char(20),
            @p_w_street_2 char(20),
            @p_w_city char(20),
            @p_w_state char(2),
            @p_w_zip char(10),
            @p_d_street_1 char(20),
            @p_d_street_2 char(20),
            @p_d_city char(20),
            @p_d_state char(20),
            @p_d_zip char(10),
            @p_c_first char(16),
            @p_c_middle char(2),
            @p_c_street_1 char(20),
            @p_c_street_2 char(20),
            @p_c_city char(20),
            @p_c_state char(20),
            @p_c_zip char(9),
            @p_c_phone char(16),
            @p_c_since datetime2(0),
            @p_c_credit char(32),
            @p_c_credit_lim numeric(12,2),
            @p_c_discount numeric(4,4),
            @p_c_balance money,
            --numeric(12,2),
            @p_c_data varchar(500),
            @namecnt int,
            @p_d_name char(11),
            @p_w_name char(11),
            @p_c_new_data varchar(500),
            @h_data varchar(30)
            BEGIN TRY
            IF (@byname = 1)
            BEGIN
            SELECT TOP 1
            @p_c_id = c_id
            FROM (
            SELECT TOP 50 PERCENT c_id, c_first
            FROM dbo.customer WITH (repeatableread)
            WHERE
            c_last = @p_c_last AND
            c_w_id = @p_c_w_id AND
            c_d_id = @p_c_d_id
            ORDER BY c_first) X
            ORDER BY c_first desc
            END
            BEGIN TRANSACTION
            -- get customer info and update balances
            UPDATE dbo.customer
            SET
            @p_c_balance = c_balance = c_balance - @p_h_amount,
            c_data =
            CASE
            WHEN c_credit <> 'BC' THEN c_credit
            ELSE LEFT(
            ISNULL(CAST(@p_c_id AS char), '') + ' ' +
            ISNULL(CAST(@p_c_d_id AS char), '') + ' ' +
            ISNULL(CAST(@p_c_w_id AS char), '') + ' ' +
            ISNULL(CAST(@p_d_id AS char), '') + ' ' +
            ISNULL(CAST(@p_w_id AS char), '') + ' ' +
            ISNULL(CAST(@p_h_amount AS CHAR(8)), '') + ' ' +
            ISNULL(CAST(@TIMESTAMP AS char), '') + ' ' +
            ISNULL(@p_w_name, '') + ' ' +
            ISNULL(@p_d_name, '') + ' ' +
            c_data,
            500)
            END,
            @p_c_first = c_first,
            @p_c_middle = c_middle,
            @p_c_last = c_last,
            @p_c_street_1 = c_street_1,
            @p_c_street_2 = c_street_2,
            @p_c_city = c_city,
            @p_c_state = c_state,
            @p_c_zip = c_zip,
            @p_c_phone = c_phone,
            @p_c_credit = c_credit,
            @p_c_credit_lim = c_credit_lim,
            @p_c_discount = c_discount,
            @p_c_since = c_since
            WHERE
            c_id = @p_c_id AND
            c_w_id = @p_c_w_id AND
            c_d_id = @p_c_d_id
            SET @h_data = (ISNULL(@p_w_name, '') + ' ' + ISNULL(@p_d_name, ''))
            INSERT dbo.history( h_c_d_id, h_c_w_id, h_c_id, h_d_id, h_w_id, h_date, h_amount, h_data)
            VALUES ( @p_c_d_id, @p_c_w_id, @p_c_id, @p_d_id, @p_w_id, @TIMESTAMP, @p_h_amount, @h_data)
            -- get district data and update year-to-date
            UPDATE dbo.district
            SET
            d_ytd = d_ytd + @p_h_amount,
            @p_d_street_1 = d_street_1,
            @p_d_street_2 = d_street_2,
            @p_d_city = d_city,
            @p_d_state = d_state,
            @p_d_zip = d_zip,
            @p_d_name = d_name
            WHERE
            d_w_id = @p_w_id AND
            d_id = @p_d_id
            -- get warehouse data and update year-to-date
            UPDATE dbo.warehouse
            SET
            w_ytd = w_ytd + @p_h_amount,
            @p_w_street_1 = w_street_1,
            @p_w_street_2 = w_street_2,
            @p_w_city = w_city,
            @p_w_state = w_state,
            @p_w_zip = w_zip,
            @p_w_name = w_name
            WHERE
            w_id = @p_w_id
            SELECT @p_c_id as N'@p_c_id', @p_c_last as N'@p_c_last', @p_w_street_1 as N'@p_w_street_1'
            , @p_w_street_2 as N'@p_w_street_2', @p_w_city as N'@p_w_city'
            , @p_w_state as N'@p_w_state', @p_w_zip as N'@p_w_zip'
            , @p_d_street_1 as N'@p_d_street_1', @p_d_street_2 as N'@p_d_street_2'
            , @p_d_city as N'@p_d_city', @p_d_state as N'@p_d_state'
            , @p_d_zip as N'@p_d_zip', @p_c_first as N'@p_c_first'
            , @p_c_middle as N'@p_c_middle', @p_c_street_1 as N'@p_c_street_1'
            , @p_c_street_2 as N'@p_c_street_2'
            , @p_c_city as N'@p_c_city', @p_c_state as N'@p_c_state', @p_c_zip as N'@p_c_zip'
            , @p_c_phone as N'@p_c_phone', @p_c_since as N'@p_c_since', @p_c_credit as N'@p_c_credit'
            , @p_c_credit_lim as N'@p_c_credit_lim', @p_c_discount as N'@p_c_discount', @p_c_balance as
            N'@p_c_balance'
            , @p_c_data as N'@p_c_data'
            END TRY
            BEGIN CATCH
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(4) {CREATE PROCEDURE [dbo].[ostat]
            @os_w_id int,
            @os_d_id int,
            @os_c_id int,
            @byname int,
            @os_c_last char(20)
            AS
            BEGIN
            SET ANSI_WARNINGS OFF
            DECLARE
            @os_c_first char(16),
            @os_c_middle char(2),
            @os_c_balance money,
            @os_o_id int,
            @os_entdate datetime2(0),
            @os_o_carrier_id int,
            @os_ol_i_id
            INT,
            @os_ol_supply_w_id INT,
            @os_ol_quantity INT,
            @os_ol_amount
            INT,
            @os_ol_delivery_d DATE,
            @namecnt int,
            @i int
            BEGIN TRANSACTION
            BEGIN TRY
            IF (@byname = 1)
            BEGIN
            SELECT TOP 1
            @os_c_id = c_id,
            @os_c_balance = c_balance,
            @os_c_first = c_first,
            @os_c_middle = c_middle,
            @os_c_last = c_last
            FROM (
            SELECT TOP 50 PERCENT c_id, c_balance, c_first, c_middle, c_last
            FROM dbo.customer WITH (repeatableread)
            WHERE
            c_last = @os_c_last AND
            c_w_id = @os_w_id AND
            c_d_id = @os_d_id
            ORDER BY c_first) X
            ORDER BY c_first desc
            END
            ELSE
            BEGIN
            SELECT @os_c_balance = customer.c_balance, @os_c_first = customer.c_first
            , @os_c_middle = customer.c_middle, @os_c_last = customer.c_last
            FROM dbo.customer WITH (repeatableread)
            WHERE customer.c_id = @os_c_id AND customer.c_d_id = @os_d_id AND customer.c_w_id = @os_w_id
            END
            BEGIN
            SELECT TOP (1) @os_o_id = o_id, @os_o_carrier_id = o_carrier_id, @os_entdate = o_entry_d
            FROM dbo.orders WITH (serializable)
            WHERE orders.o_d_id = @os_d_id
            AND orders.o_w_id = @os_w_id
            AND orders.o_c_id = @os_c_id
            ORDER BY orders.o_id DESC
            IF @@ROWCOUNT = 0
            PRINT 'No orders for customer';
            END
            SELECT order_line.ol_i_id
            , order_line.ol_supply_w_id
            , order_line.ol_quantity
            , order_line.ol_amount
            , order_line.ol_delivery_d
            FROM dbo.order_line WITH (repeatableread)
            WHERE order_line.ol_o_id = @os_o_id
            AND order_line.ol_d_id = @os_d_id
            AND order_line.ol_w_id = @os_w_id
            SELECT @os_c_id as N'@os_c_id', @os_c_last as N'@os_c_last', @os_c_first as N'@os_c_first', @os_c_middle
            as N'@os_c_middle', @os_c_balance as N'@os_c_balance', @os_o_id as N'@os_o_id', @os_entdate as
            N'@os_entdate', @os_o_carrier_id as N'@os_o_carrier_id'
            END TRY
            BEGIN CATCH
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
        set sql(5) {CREATE PROCEDURE [dbo].[slev]
            @st_w_id int,
            @st_d_id int,
            @threshold int
            AS
            BEGIN
            DECLARE
            @st_o_id_low int,
            @st_o_id_high int
            BEGIN TRANSACTION
            BEGIN TRY
            SELECT
            @st_o_id_low = district.d_next_o_id - 20,
            @st_o_id_high = district.d_next_o_id - 1
            FROM dbo.district
            WHERE district.d_w_id = @st_w_id AND district.d_id = @st_d_id
            SELECT
            COUNT(DISTINCT stock.s_i_id)
            FROM dbo.order_line
            , dbo.stock
            WHERE order_line.ol_w_id = @st_w_id
            AND order_line.ol_d_id = @st_d_id
            AND order_line.ol_o_id BETWEEN @st_o_id_low AND @st_o_id_high
            AND stock.s_w_id = order_line.ol_w_id
            AND stock.s_i_id = order_line.ol_i_id
            AND stock.s_quantity < @threshold
	    OPTION (ORDER GROUP, LOOP JOIN, MAXDOP 1);
            END TRY
            BEGIN CATCH
            SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        END}
    }
    for { set i 1 } { $i <= 5 } { incr i } {
        $odbc evaldirect $sql($i)
    }
    return
}

proc UpdateStatistics { odbc db azure } {
    puts "UPDATING SCHEMA STATISTICS"
    if {!$azure} {
        $odbc evaldirect "CREATE OR ALTER PROCEDURE dbo.sp_updstats
with execute as 'dbo'
as
exec sp_updatestats
"
        $odbc evaldirect "EXEC dbo.sp_updstats"
    } else {
        set sql(1) "USE $db"
        set sql(2) "EXEC sp_updatestats"
        for { set i 1 } { $i <= 2 } { incr i } {
            $odbc evaldirect $sql($i)
        }
    }
    return
}

proc location { odbc } {
set location "remote"
if ![catch {set rows [ $odbc allrows "select case when cast(serverproperty('machinename') as varchar(100)) = cast(host_name() as varchar(100)) then 'local' else 'remote' end"  ]}] {
set location [ lindex {*}$rows 1 ]
	}
return $location
}

proc CreateDatabase { odbc db imdb azure } {
    set table_count 0
    puts "CHECKING IF DATABASE $db EXISTS"
    set rows [ $odbc allrows "IF DB_ID('$db') is not null SELECT 1 AS res ELSE SELECT 0 AS res" ]
    set db_exists [ lindex {*}$rows 1 ]
    if { $db_exists } {
        if {!$azure} {$odbc evaldirect "use $db"}
        set rows [ $odbc allrows "select COUNT(*) from sys.tables" ]
        set table_count [ lindex {*}$rows 1 ]
        if { $table_count == 0 } {
            puts "Empty database $db exists"
            if { $imdb } {
                $odbc evaldirect "ALTER DATABASE $db SET AUTO_CREATE_STATISTICS OFF"
                $odbc evaldirect "ALTER DATABASE $db SET AUTO_UPDATE_STATISTICS OFF"
                set rows [ $odbc allrows {SELECT TOP 1 1 FROM sys.filegroups FG JOIN sys.database_files F ON FG.data_space_id = F.data_space_id WHERE FG.type = 'FX' AND F.type = 2} ]
                set imdb_fg [ lindex {*}$rows 1 ] 
                if { $imdb_fg eq "1" } { 
                    set rows [ $odbc allrows "SELECT is_memory_optimized_elevate_to_snapshot_on FROM sys.databases WHERE name = '$db'" ]
                    set elevatetosnap [ lindex {*}$rows 1 ]
                    if { $elevatetosnap eq "1" } {
                        puts "Using existing Memory Optimized Database $db with ELEVATE_TO_SNAPSHOT for Schema build"
                    } else {
                        puts "Existing Memory Optimized Database $db exists, setting ELEVATE_TO_SNAPSHOT"
                        unset -nocomplain rows
                        unset -nocomplain elevatetosnap
                        $odbc evaldirect "ALTER DATABASE $db SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON"
                        set rows [ $odbc allrows "SELECT is_memory_optimized_elevate_to_snapshot_on FROM sys.databases WHERE name = '$db'" ]
                        set elevatetosnap [ lindex {*}$rows 1 ]
                        if { $elevatetosnap eq "1" } {
                            puts "Success: Set ELEVATE_TO_SNAPSHOT for Database $db"
                        } else {
                            puts "Failed to set ELEVATE_TO_SNAPSHOT for Database $db"
                            error "Set ELEVATE_TO_SNAPSHOT for Database $db and retry build"
                        }
                    }
                } else {
                    puts "Database $db must be in a MEMORY_OPTIMIZED_DATA filegroup"
                    error "Database $db exists but is not in a MEMORY_OPTIMIZED_DATA filegroup"
                }
            } else {
                puts "Using existing empty Database $db for Schema build"
            }
        } else {
            puts "Database with tables $db exists"
            error "Database $db exists but is not empty, specify a new or empty database name"
        }
    } else {
        if { $imdb } {
            puts "In Memory Database chosen but $db does not exist"
            error "Database $db must be pre-created in a MEMORY_OPTIMIZED_DATA filegroup and empty, to specify an In-Memory build"
        } else {
            puts "CREATING DATABASE $db"
            $odbc evaldirect "create database $db"
        }
    }
}

proc CreateTables { odbc imdb count_ware bucket_factor durability } {
    puts "CREATING TPCC TABLES"
    if { $imdb } {
        set stmnt_cnt 9 
        set ware_bc  [ expr $count_ware * 1 ]
        set dist_bc  [ expr $count_ware * 10 ]
        set item_bc 131072
        set cust_bc [ expr $count_ware * 30000 ]
        set stock_bc  [ expr $count_ware * 100000 ]
        set orderl_bc  [ expr $count_ware * (400000 * $bucket_factor) ]
        set order_bc  [ expr $count_ware * (40000 * $bucket_factor) ]
        set sql(1) [ subst -nocommands {CREATE TABLE [dbo].[customer] ( [c_id] [int] NOT NULL, [c_d_id] [tinyint] NOT NULL, [c_w_id] [int] NOT NULL, [c_discount] [smallmoney] NULL, [c_credit_lim] [money] NULL, [c_last] [char](16) COLLATE Latin1_General_CI_AS NULL, [c_first] [char](16) COLLATE Latin1_General_CI_AS NULL, [c_credit] [char](2) COLLATE Latin1_General_CI_AS NULL, [c_balance] [money] NULL, [c_ytd_payment] [money] NULL, [c_payment_cnt] [smallint] NULL, [c_delivery_cnt] [smallint] NULL, [c_street_1] [char](20) COLLATE Latin1_General_CI_AS NULL, [c_street_2] [char](20) COLLATE Latin1_General_CI_AS NULL, [c_city] [char](20) COLLATE Latin1_General_CI_AS NULL, [c_state] [char](2) COLLATE Latin1_General_CI_AS NULL, [c_zip] [char](9) COLLATE Latin1_General_CI_AS NULL, [c_phone] [char](16) COLLATE Latin1_General_CI_AS NULL, [c_since] [datetime] NULL, [c_middle] [char](2) COLLATE Latin1_General_CI_AS NULL, [c_data] [char](500) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [customer_i1] PRIMARY KEY NONCLUSTERED HASH ([c_id], [c_d_id], [c_w_id]) WITH (BUCKET_COUNT = $cust_bc), INDEX [customer_i2] NONCLUSTERED ([c_last], [c_w_id], [c_d_id], [c_first], [c_id])) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}]
        set sql(2) [ subst -nocommands {CREATE TABLE [dbo].[district] ( [d_id] [tinyint] NOT NULL, [d_w_id] [int] NOT NULL, [d_ytd] [money] NOT NULL, [d_next_o_id] [int] NULL, [d_tax] [smallmoney] NULL, [d_name] [char](10) COLLATE Latin1_General_CI_AS NULL, [d_street_1] [char](20) COLLATE Latin1_General_CI_AS NULL, [d_street_2] [char](20) COLLATE Latin1_General_CI_AS NULL, [d_city] [char](20) COLLATE Latin1_General_CI_AS NULL, [d_state] [char](2) COLLATE Latin1_General_CI_AS NULL, [d_zip] [char](9) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [district_i1] PRIMARY KEY NONCLUSTERED HASH ([d_id], [d_w_id]) WITH (BUCKET_COUNT = $dist_bc)) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}]
        set sql(3) [ subst -nocommands {CREATE TABLE [dbo].[history] ( [h_id] [int] IDENTITY(1,1) NOT NULL, [h_c_id] [int] NOT NULL, [h_c_d_id] [tinyint] NULL, [h_c_w_id] [int] NULL, [h_d_id] [tinyint] NULL, [h_w_id] [int] NULL, [h_date] [datetime] NOT NULL, [h_amount] [smallmoney] NULL, [h_data] [char](24) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [history_i1] PRIMARY KEY NONCLUSTERED ([h_id])) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}]
        set sql(4) [ subst -nocommands {CREATE TABLE [dbo].[item] ( [i_id] [int] NOT NULL, [i_name] [char](24) COLLATE Latin1_General_CI_AS NULL, [i_price] [smallmoney] NULL, [i_data] [char](50) COLLATE Latin1_General_CI_AS NULL, [i_im_id] [int] NULL, CONSTRAINT [item_i1]  PRIMARY KEY NONCLUSTERED HASH ([i_id]) WITH (BUCKET_COUNT = $item_bc)) WITH (MEMORY_OPTIMIZED = ON , DURABILITY = $durability)}]
        set sql(5) [ subst -nocommands {CREATE TABLE [dbo].[new_order] ( [no_o_id] [int] NOT NULL, [no_d_id] [tinyint] NOT NULL, [no_w_id] [int] NOT NULL, CONSTRAINT [new_order_i1]  PRIMARY KEY NONCLUSTERED ([no_w_id], [no_d_id], [no_o_id])) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}] 
        set sql(6) [ subst -nocommands {CREATE TABLE [dbo].[order_line] ([ol_o_id] [int] NOT NULL, [ol_d_id] [tinyint] NOT NULL, [ol_w_id] [int] NOT NULL, [ol_number] [tinyint] NOT NULL, [ol_i_id] [int] NULL, [ol_delivery_d] [datetime] NULL, [ol_amount] [smallmoney] NULL, [ol_supply_w_id] [int] NULL, [ol_quantity] [smallint] NULL, [ol_dist_info] [char](24) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [order_line_i1] PRIMARY KEY NONCLUSTERED HASH ([ol_o_id], [ol_d_id], [ol_w_id], [ol_number]) WITH (BUCKET_COUNT = $orderl_bc), INDEX [orderline_i2] NONCLUSTERED ([ol_d_id], [ol_w_id], [ol_o_id])) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability )}]
        set sql(7) [ subst -nocommands {CREATE TABLE [dbo].[orders] ( [o_id] [int] NOT NULL, [o_d_id] [tinyint] NOT NULL, [o_w_id] [int] NOT NULL, [o_c_id] [int] NOT NULL, [o_carrier_id] [tinyint] NULL, [o_ol_cnt] [tinyint] NULL, [o_all_local] [tinyint] NULL, [o_entry_d] [datetime] NULL, CONSTRAINT [orders_i1]  PRIMARY KEY NONCLUSTERED HASH ([o_w_id], [o_d_id], [o_id]) WITH (BUCKET_COUNT = $order_bc), INDEX [orders_i2] NONCLUSTERED ([o_c_id], [o_d_id], [o_w_id], [o_id])) WITH (MEMORY_OPTIMIZED = ON , DURABILITY = $durability)}]
        set sql(8) [ subst -nocommands {CREATE TABLE [dbo].[stock] ( [s_i_id] [int] NOT NULL, [s_w_id] [int] NOT NULL, [s_quantity] [smallint] NOT NULL, [s_ytd] [int] NOT NULL, [s_order_cnt] [smallint] NULL, [s_remote_cnt] [smallint] NULL, [s_data] [char](50) COLLATE Latin1_General_CI_AS NULL, [s_dist_01] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_02] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_03] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_04] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_05] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_06] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_07] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_08] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_09] [char](24) COLLATE Latin1_General_CI_AS NULL, [s_dist_10] [char](24) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [stock_i1]  PRIMARY KEY NONCLUSTERED HASH ( [s_i_id], [s_w_id]) WITH (BUCKET_COUNT = $stock_bc)) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}]
        set sql(9) [ subst -nocommands {CREATE TABLE [dbo].[warehouse] ([w_id] [int] NOT NULL, [w_ytd] [money] NOT NULL, [w_tax] [smallmoney] NOT NULL, [w_name] [char](10) COLLATE Latin1_General_CI_AS NULL, [w_street_1] [char](20) COLLATE Latin1_General_CI_AS NULL, [w_street_2] [char](20) COLLATE Latin1_General_CI_AS NULL, [w_city] [char](20) COLLATE Latin1_General_CI_AS NULL, [w_state] [char](2) COLLATE Latin1_General_CI_AS NULL, [w_zip] [char](9) COLLATE Latin1_General_CI_AS NULL, CONSTRAINT [warehouse_i1]  PRIMARY KEY NONCLUSTERED HASH ([w_id]) WITH (BUCKET_COUNT = $ware_bc)) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = $durability)}]
    } else {
        set stmnt_cnt 20 
        set sql(1) {CREATE TABLE [dbo].[customer]( [c_id] [int] NOT NULL, [c_d_id] [tinyint] NOT NULL, [c_w_id] [int] NOT NULL, [c_discount] [smallmoney] NULL, [c_credit_lim] [money] NULL, [c_last] [char](16) NULL, [c_first] [char](16) NULL, [c_credit] [char](2) NULL, [c_balance] [money] NULL, [c_ytd_payment] [money] NULL, [c_payment_cnt] [smallint] NULL, [c_delivery_cnt] [smallint] NULL, [c_street_1] [char](20) NULL, [c_street_2] [char](20) NULL, [c_city] [char](20) NULL, [c_state] [char](2) NULL, [c_zip] [char](9) NULL, [c_phone] [char](16) NULL, [c_since] [datetime] NULL, [c_middle] [char](2) NULL, [c_data] [char](500) NULL)}
        set sql(2) {CREATE TABLE [dbo].[district]( [d_id] [tinyint] NOT NULL, [d_w_id] [int] NOT NULL, [d_ytd] [money] NOT NULL, [d_next_o_id] [int] NULL, [d_tax] [smallmoney] NULL, [d_name] [char](10) NULL, [d_street_1] [char](20) NULL, [d_street_2] [char](20) NULL, [d_city] [char](20) NULL, [d_state] [char](2) NULL, [d_zip] [char](9) NULL, [padding] [char](6000) NOT NULL, CONSTRAINT [PK_DISTRICT] PRIMARY KEY CLUSTERED ( [d_w_id] ASC, [d_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF))}
        set sql(3) {CREATE TABLE [dbo].[history]( [h_c_id] [int] NULL, [h_c_d_id] [tinyint] NULL, [h_c_w_id] [int] NULL, [h_d_id] [tinyint] NULL, [h_w_id] [int] NULL, [h_date] [datetime] NULL, [h_amount] [smallmoney] NULL, [h_data] [char](24) NULL)} 
        set sql(4) {CREATE TABLE [dbo].[item]( [i_id] [int] NOT NULL, [i_name] [char](24) NULL, [i_price] [smallmoney] NULL, [i_data] [char](50) NULL, [i_im_id] [int] NULL, CONSTRAINT [PK_ITEM] PRIMARY KEY CLUSTERED ( [i_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF))} 
        set sql(5) {CREATE TABLE [dbo].[new_order]( [no_o_id] [int] NOT NULL, [no_d_id] [tinyint] NOT NULL, [no_w_id] [int] NOT NULL)} 
        set sql(6) {CREATE TABLE [dbo].[orders]( [o_id] [int] NOT NULL, [o_d_id] [tinyint] NOT NULL, [o_w_id] [int] NOT NULL, [o_c_id] [int] NOT NULL, [o_carrier_id] [tinyint] NULL, [o_ol_cnt] [tinyint] NULL, [o_all_local] [tinyint] NULL, [o_entry_d] [datetime] NULL)} 
        set sql(7) {CREATE TABLE [dbo].[order_line]( [ol_o_id] [int] NOT NULL, [ol_d_id] [tinyint] NOT NULL, [ol_w_id] [int] NOT NULL, [ol_number] [tinyint] NOT NULL, [ol_i_id] [int] NULL, [ol_delivery_d] [datetime] NULL, [ol_amount] [smallmoney] NULL, [ol_supply_w_id] [int] NULL, [ol_quantity] [smallint] NULL, [ol_dist_info] [char](24) NULL)} 
        set sql(8) {CREATE TABLE [dbo].[stock]( [s_i_id] [int] NOT NULL, [s_w_id] [int] NOT NULL, [s_quantity] [smallint] NOT NULL, [s_ytd] [int] NOT NULL, [s_order_cnt] [smallint] NULL, [s_remote_cnt] [smallint] NULL, [s_data] [char](50) NULL, [s_dist_01] [char](24) NULL, [s_dist_02] [char](24) NULL, [s_dist_03] [char](24) NULL, [s_dist_04] [char](24) NULL, [s_dist_05] [char](24) NULL, [s_dist_06] [char](24) NULL, [s_dist_07] [char](24) NULL, [s_dist_08] [char](24) NULL, [s_dist_09] [char](24) NULL, [s_dist_10] [char](24) NULL, CONSTRAINT [PK_STOCK] PRIMARY KEY CLUSTERED ( [s_w_id] ASC, [s_i_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF))}
        set sql(9) {CREATE TABLE [dbo].[warehouse]( [w_id] [int] NOT NULL, [w_ytd] [money] NOT NULL, [w_tax] [smallmoney] NOT NULL, [w_name] [char](10) NULL, [w_street_1] [char](20) NULL, [w_street_2] [char](20) NULL, [w_city] [char](20) NULL, [w_state] [char](2) NULL, [w_zip] [char](9) NULL, [padding] [char](4000) NOT NULL, CONSTRAINT [PK_WAREHOUSE] PRIMARY KEY CLUSTERED ( [w_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF))} 
        set sql(10) {ALTER TABLE [dbo].[customer] SET (LOCK_ESCALATION = DISABLE)}
        set sql(11) {ALTER TABLE [dbo].[district] SET (LOCK_ESCALATION = DISABLE)}
        set sql(12) {ALTER TABLE [dbo].[history] SET (LOCK_ESCALATION = DISABLE)}
        set sql(13) {ALTER TABLE [dbo].[item] SET (LOCK_ESCALATION = DISABLE)}
        set sql(14) {ALTER TABLE [dbo].[new_order] SET (LOCK_ESCALATION = DISABLE)}
        set sql(15) {ALTER TABLE [dbo].[orders] SET (LOCK_ESCALATION = DISABLE)}
        set sql(16) {ALTER TABLE [dbo].[order_line] SET (LOCK_ESCALATION = DISABLE)}
        set sql(17) {ALTER TABLE [dbo].[stock] SET (LOCK_ESCALATION = DISABLE)}
        set sql(18) {ALTER TABLE [dbo].[warehouse] SET (LOCK_ESCALATION = DISABLE)}
        set sql(19) {ALTER TABLE [dbo].[district] ADD  CONSTRAINT [DF__DISTRICT__paddin__282DF8C2]  DEFAULT (replicate('X',(6000))) FOR [padding]}
        set sql(20) {ALTER TABLE [dbo].[warehouse] ADD  CONSTRAINT [DF__WAREHOUSE__paddi__14270015]  DEFAULT (replicate('x',(4000))) FOR [padding]}
    }
    for { set i 1 } { $i <= $stmnt_cnt } { incr i } {
        $odbc evaldirect $sql($i)
    }
    return
}

proc CreateIndexes { odbc imdb } {
    puts "CREATING TPCC INDEXES"
    if { $imdb } {
        #In-memory Indexes created with tables
    } else {
        set sql(1) {CREATE UNIQUE CLUSTERED INDEX [customer_i1] ON [dbo].[customer] ( [c_w_id] ASC, [c_d_id] ASC, [c_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF)}
        set sql(2) {CREATE UNIQUE CLUSTERED INDEX [new_order_i1] ON [dbo].[new_order] ( [no_w_id] ASC, [no_d_id] ASC, [no_o_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON)}
        set sql(3) {CREATE UNIQUE CLUSTERED INDEX [orders_i1] ON [dbo].[orders] ( [o_w_id] ASC, [o_d_id] ASC, [o_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON)}
        set sql(4) {CREATE UNIQUE CLUSTERED INDEX [order_line_i1] ON [dbo].[order_line] ( [ol_w_id] ASC, [ol_d_id] ASC, [ol_o_id] ASC, [ol_number] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON)} 
        set sql(5) {CREATE NONCLUSTERED INDEX [customer_c_last] ON [dbo].[customer]([c_w_id] ASC, [c_d_id] ASC, [c_last] ASC, [c_first] ASC, [c_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF)}
        set sql(6) {CREATE NONCLUSTERED INDEX [district_d_id] ON [dbo].[district]([d_id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF)}
        set sql(7) {CREATE NONCLUSTERED INDEX [orders_i2] ON [dbo].[orders] ( [o_w_id] ASC, [o_d_id] ASC, [o_c_id] ASC, [o_id] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON)}
        set sql(8) {CREATE CLUSTERED INDEX [history_i1] ON [dbo].[history]([h_c_w_id] ASC, [h_date] ASC, [h_c_d_id] ASC, [h_c_id] ASC, [h_amount] ASC)}
        for { set i 1 } { $i <= 8 } { incr i } {
            $odbc evaldirect $sql($i)
        }
    }
    return
}

proc gettimestamp { } {
    set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
    return $tstamp
}

# bcp command to copy from file to specified tables
# -b flag specifies batch size of 500000, -a flag specifies network packet size of 16000
# network packet size depends on server configuration, default of 4096 is used if 16000 is not allowed
proc bcpComm {odbc tableName filePath uid pwd server} {
    upvar 3 location location
    upvar 3 authentication authentication
    if { $location eq "local" && [ string toupper $authentication ] != "SQL" } {
    if [catch {$odbc evaldirect [ subst {bulk insert $tableName from "$filePath" with (DATAFILETYPE = 'char', FIELDTERMINATOR = ',',ROWS_PER_BATCH=500000)}]} message ] {
           error "Bulk Insert error : $message"
    }
    } else {
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        exec bcp $tableName IN $filePath -b 500000 -a 16000 -T -S $server -c  -t ","
    } else {
    upvar #0 tcl_platform tcl_platform
   if {$tcl_platform(platform) == "windows"} {
#bcp on Windows uses ODBC driver 17 that does not support the -u option and may need updating when bcp driver changes
   if {[ string toupper $authentication ] eq "ENTRA" } {
        exec bcp $tableName IN $filePath -b 500000 -a 16000 -G -S $server -c  -t ","
        } else {
        exec bcp $tableName IN $filePath -b 500000 -a 16000 -U $uid -P $pwd -S $server -c  -t ","
	}
	} else {
#bcp on Linux can use ODBC driver 18 and trust the server certificate with -u option
    upvar 3 trust_cert trust_cert
    upvar 3 odbc_driver odbc_driver
    regexp {ODBC\ Driver\ ([0-9]+)\ for\ SQL\ Server} $odbc_driver all odbc_version 
    if { $trust_cert && $odbc_version >= 18 } {
        exec bcp $tableName IN $filePath -b 500000 -a 16000 -U $uid -P $pwd -S $server -u -c  -t ","
		} else {
        exec bcp $tableName IN $filePath -b 500000 -a 16000 -U $uid -P $pwd -S $server -c  -t ","
           }
         }
      }
   }
}

proc Customer { odbc d_id w_id CUST_PER_DIST } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set namearr [list BAR OUGHT ABLE PRI PRES ESE ANTI CALLY ATION EING]
    set chalen [ llength $globArray ]
    set bld_cnt 1
    set c_d_id $d_id
    set c_w_id $w_id
    set c_middle "OE"
    set c_balance -10.0
    set c_credit_lim 50000
    set h_amount 10.0
    puts "Loading Customer for DID=$d_id WID=$w_id"
    for {set c_id 1} {$c_id <= $CUST_PER_DIST } {incr c_id } {
        set c_first [ MakeAlphaString 8 16 $globArray $chalen ]
        if { $c_id <= 1000 } {
            set c_last [ Lastname [ expr {$c_id - 1} ] $namearr ]
        } else {
            set nrnd [ NURand 255 0 999 123 ]
            set c_last [ Lastname $nrnd $namearr ]
        }
        set c_add [ MakeAddress $globArray $chalen ]
        set c_phone [ MakeNumberString ]
        if { [RandomNumber 0 1] eq 1 } {
            set c_credit "GC"
        } else {
            set c_credit "BC"
        }
        set disc_ran [ RandomNumber 0 50 ]
        set c_discount [ expr {$disc_ran / 100.0} ]
        set c_data [ MakeAlphaString 300 500 $globArray $chalen ]
        append c_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_first', '$c_middle', '$c_last', '[ lindex $c_add 0 ]', '[ lindex $c_add 1 ]', '[ lindex $$c_add 2 ]', '[ lindex $c_add 3 ]', '[ lindex $c_add 4 ]', '$c_phone', getdate(), '$c_credit', '$c_credit_lim', '$c_discount', '$c_balance', '$c_data', '10.0', '1', '0')
        set h_data [ MakeAlphaString 12 24 $globArray $chalen ]
        append h_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_w_id', '$c_d_id', getdate(), '$h_amount', '$h_data')
        if { $bld_cnt<= 1 } { 
            append c_val_list ,
            append h_val_list ,
        }
        incr bld_cnt
        if { ![ expr {$c_id % 2} ] } {
            $odbc evaldirect "insert into customer (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_since, c_credit, c_credit_lim, c_discount, c_balance, c_data, c_ytd_payment, c_payment_cnt, c_delivery_cnt) values $c_val_list"
            $odbc evaldirect "insert into history (h_c_id, h_c_d_id, h_c_w_id, h_w_id, h_d_id, h_date, h_amount, h_data) values $h_val_list"
            set bld_cnt 1
            unset c_val_list
            unset h_val_list
        }
    }
    puts "Customer Done"
    return
}

# customer table loading procedure that implements the exec bcp command
proc Customer_use_bcp { odbc w_id CUST_PER_DIST DIST_PER_WARE} {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set namearr [list BAR OUGHT ABLE PRI PRES ESE ANTI CALLY ATION EING]
    set chalen [ llength $globArray ]
    set c_w_id $w_id
    set c_middle "OE"
    set c_balance -10.0
    set c_credit_lim 50000
    set h_amount 10.0

    # pass in values for secure connection to server and database name for bcp
    upvar 2 uid userid
    upvar 2 pwd pass
    upvar 2 server serv
    upvar 2 db db

    # create files for customer and history tables
    set tmp_env $::env(TMP)
    set CustomerFilePath "$tmp_env/CustomerTable$w_id.csv"
    set HistoryFilePath "$tmp_env/HistoryTable$w_id.csv"

    set cust_list ""
    set hist_list ""

    file delete $CustomerFilePath
    file delete $HistoryFilePath

    for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
      set c_d_id $d_id
      for {set c_id 1} {$c_id <= $CUST_PER_DIST } {incr c_id } {
        set c_first [ MakeAlphaString 8 16 $globArray $chalen ]
        if { $c_id <= 1000 } {
            set c_last [ Lastname [ expr {$c_id - 1} ] $namearr ]
        } else {
            set nrnd [ NURand 255 0 999 123 ]
            set c_last [ Lastname $nrnd $namearr ]
        }
        set c_add [ MakeAddress $globArray $chalen ]
        set c_phone [ MakeNumberString ]
        if { [RandomNumber 0 1] eq 1 } {
            set c_credit "GC"
        } else {
            set c_credit "BC"
        }
        set disc_ran [ RandomNumber 0 50 ]
        set c_discount [ expr {$disc_ran / 100.0} ]
        set c_data [ MakeAlphaString 300 500 $globArray $chalen ]
        set h_data [ MakeAlphaString 12 24 $globArray $chalen ]
        set h_date [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
        set c_street_1 [ lindex $c_add 0 ]
        set c_street_2 [ lindex $c_add 1 ]
        set c_city [ lindex $c_add 2 ]
        set c_state [ lindex $c_add 3 ]
        set c_zip [ lindex $c_add 4 ]
        append hist_list "$c_id,$c_d_id,$c_w_id,$c_d_id,$c_w_id,$h_date,$h_amount,$h_data\n"
        append cust_list "$c_id,$c_d_id,$c_w_id,$c_discount,$c_credit_lim,$c_last,$c_first,$c_credit,$c_balance,10,1,0,$c_street_1,$c_street_2,$c_city,$c_state,$c_zip,$c_phone,$h_date,$c_middle,$c_data\n"

      }
    }
    if {$hist_list ne ""} {
        set fileHandle [open $HistoryFilePath "a"]
        puts -nonewline $fileHandle $hist_list
        close $fileHandle
        unset hist_list
    }
    if {$cust_list ne ""} {
        set fileHandle [open $CustomerFilePath "a"]
        puts -nonewline $fileHandle $cust_list
        close $fileHandle
        unset cust_list
    }
    # bcp command to copy to history table
    set tableName $db.dbo.history
    bcpComm $odbc $tableName $HistoryFilePath $userid $pass $serv

    # bcp command to copy to customer table
    set tableName $db.dbo.customer
    bcpComm $odbc $tableName $CustomerFilePath $userid $pass $serv

    # delete files when copy is complete
    file delete $HistoryFilePath
    file delete $CustomerFilePath
    return
}

proc Orders { odbc d_id w_id MAXITEMS ORD_PER_DIST } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    set bld_cnt 1
    puts "Loading Orders for D=$d_id W=$w_id"
    set o_d_id $d_id
    set o_w_id $w_id
    for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
        set cust($i) $i
    }
    for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
        set r [ RandomNumber $i $ORD_PER_DIST ]
        set t $cust($i)
        set cust($i) $cust($r)
        set $cust($r) $t
    }
    set e ""
    for {set o_id 1} {$o_id <= $ORD_PER_DIST } {incr o_id } {
        set o_c_id $cust($o_id)
        set o_carrier_id [ RandomNumber 1 10 ]
        set o_ol_cnt [ RandomNumber 5 15 ]
        if { $o_id > 2100 } {
            set e "o1"
            append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', getdate(), null, '$o_ol_cnt', '1')
            set e "no1"
            append no_val_list ('$o_id', '$o_d_id', '$o_w_id')
        } else {
            set e "o3"
            append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', getdate(), '$o_carrier_id', '$o_ol_cnt', '1')
        }
        for {set ol 1} {$ol <= $o_ol_cnt } {incr ol } {
            set ol_i_id [ RandomNumber 1 $MAXITEMS ]
            set ol_supply_w_id $o_w_id
            set ol_quantity 5
            set ol_amount 0.0
            set ol_dist_info [ MakeAlphaString 24 24 $globArray $chalen ]
            if { $o_id > 2100 } {
                set e "ol1"
                append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', null)
                if { $bld_cnt<= 1 } { append ol_val_list , } else {
                    if { $ol != $o_ol_cnt } { append ol_val_list , }
                }
            } else {
                set amt_ran [ RandomNumber 10 10000 ]
                set ol_amount [ expr {$amt_ran / 100.0} ]
                set e "ol2"
                append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', getdate())
                if { $bld_cnt<= 1 } { append ol_val_list , } else {
                    if { $ol != $o_ol_cnt } { append ol_val_list , }
                }
            }
        }
        if { $bld_cnt<= 1 } {
            append o_val_list ,
            if { $o_id > 2100 } {
                append no_val_list ,
            }
        }
        incr bld_cnt
        if { ![ expr {$o_id % 2} ] } {
            if { ![ expr {$o_id % 1000} ] } {
                puts "...$o_id"
            }
            $odbc evaldirect "insert into orders (o_id, o_c_id, o_d_id, o_w_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local) values $o_val_list"
            if { $o_id > 2100 } {
                $odbc evaldirect "insert into new_order (no_o_id, no_d_id, no_w_id) values $no_val_list"
            }
            $odbc evaldirect "insert into order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info, ol_delivery_d) values $ol_val_list"
            set bld_cnt 1
            unset o_val_list
            unset -nocomplain no_val_list
            unset ol_val_list
        }
    }
    puts "Orders Done"
    return
}

# orders table loading procedure that implements the exec bcp command
proc Orders_use_bcp { odbc w_id MAXITEMS ORD_PER_DIST DIST_PER_WARE} {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    # create files for orders, order line and new order tables
    set tmp_env $::env(TMP)
    set ordersFilePath "$tmp_env/Orders$w_id.csv"
    set orderLineFilePath "$tmp_env/OrderLine$w_id.csv"
    set newOrderFilePath "$tmp_env/NewOrder$w_id.csv"

    set orders_list ""
    set order_line_list ""
    set new_order_list ""

    file delete $ordersFilePath
    file delete $newOrderFilePath
    file delete $orderLineFilePath

    # pass in values for secure connection to server and database name for bcp
    upvar 2 uid userid
    upvar 2 pwd pass
    upvar 2 server serv
    upvar 2 db db

    set o_w_id $w_id
  for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
     set o_d_id $d_id
    for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
        set cust($i) $i
    }
    for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
        set r [ RandomNumber $i $ORD_PER_DIST ]
        set t $cust($i)
        set cust($i) $cust($r)
        set $cust($r) $t
    }
    set e ""
    # populate lists for inserting into tables for order line, new order and orders
    for {set o_id 1} {$o_id <= $ORD_PER_DIST } {incr o_id } {
        set o_c_id $cust($o_id)
        set o_carrier_id [ RandomNumber 1 10 ]
        set o_ol_cnt [ RandomNumber 5 15 ]
        if { $o_id > 2100 } {
            set e "o1"
            set o_entry_d ""
            append orders_list "$o_id,$o_d_id,$o_w_id,$o_c_id,$o_carrier_id,$o_ol_cnt,1,$o_entry_d\n"
            set e "no1"
            append new_order_list "$o_id,$o_d_id,$o_w_id\n"
        } else {
            set e "o3"
            set o_entry_d [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
            append orders_list "$o_id,$o_d_id,$o_w_id,$o_c_id,$o_carrier_id,$o_ol_cnt,1,$o_entry_d\n"
        }
        for {set ol 1} {$ol <= $o_ol_cnt } {incr ol } {
            set ol_i_id [ RandomNumber 1 $MAXITEMS ]
            set ol_supply_w_id $o_w_id
            set ol_quantity 5
            set ol_amount 0.0
            set ol_dist_info [ MakeAlphaString 24 24 $globArray $chalen ]
            if { $o_id > 2100 } {
                set e "ol1"
                set o_entry_d ""
                append order_line_list "$o_id,$o_d_id,$o_w_id,$ol,$ol_i_id,$o_entry_d,$ol_amount,$ol_supply_w_id,$ol_quantity,$ol_dist_info\n"
            } else {
                set amt_ran [ RandomNumber 10 10000 ]
                set ol_amount [ expr {$amt_ran / 100.0} ]
                set e "ol2"
                set o_entry_d [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
                append order_line_list "$o_id,$o_d_id,$o_w_id,$ol,$ol_i_id,$o_entry_d,$ol_amount,$ol_supply_w_id,$ol_quantity,$ol_dist_info\n"
            }
        }
    }
  }
    if {$orders_list ne ""} {
         set fileHandle [open $ordersFilePath "a"]
         puts -nonewline $fileHandle $orders_list
         close $fileHandle
         unset orders_list
    }

    if {$order_line_list ne ""} {
         set fileHandle [open $orderLineFilePath "a"]
         puts -nonewline $fileHandle $order_line_list
         close $fileHandle
         unset order_line_list
    }

    if {$new_order_list ne ""} {
        set fileHandle [open $newOrderFilePath "a"]
        puts -nonewline $fileHandle $new_order_list
        close $fileHandle
        unset -nocomplain new_order_list
    }

    # bcp command to copy to orders table
    set tableName $db.dbo.orders
    bcpComm $odbc $tableName $ordersFilePath $userid $pass $serv
    # delete file when copy is complete
    file delete $ordersFilePath


    # only bcp copy to new order table when o_id is greater than 2100
    if {$o_id > 2100} {
        set tableName $db.dbo.new_order
        bcpComm $odbc $tableName $newOrderFilePath $userid $pass $serv
        # delete file when copy is complete
        file delete $newOrderFilePath
    }

    # bcp command to copy to order line table
    set tableName $db.dbo.order_line
    bcpComm $odbc $tableName $orderLineFilePath $userid $pass $serv
    # delete file when copy is complete
    file delete $orderLineFilePath

    return
}

proc LoadItems { odbc MAXITEMS } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    puts "Loading Item"
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set orig($i) 0
    }
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set pos [ RandomNumber 0 $MAXITEMS ] 
        set orig($pos) 1
    }
    for {set i_id 1} {$i_id <= $MAXITEMS } {incr i_id } {
        set i_im_id [ RandomNumber 1 10000 ] 
        set i_name [ MakeAlphaString 14 24 $globArray $chalen ]
        set i_price_ran [ RandomNumber 100 10000 ]
        set i_price [ format "%4.2f" [ expr {$i_price_ran / 100.0} ] ]
        set i_data [ MakeAlphaString 26 50 $globArray $chalen ]
        if { [ info exists orig($i_id) ] } {
            if { $orig($i_id) eq 1 } {
                set first [ RandomNumber 0 [ expr {[ string length $i_data] - 8}] ]
                set last [ expr {$first + 8} ]
                set i_data [ string replace $i_data $first $last "original" ]
            }
        }
        $odbc evaldirect "insert into item (i_id, i_im_id, i_name, i_price, i_data) VALUES ('$i_id', '$i_im_id', '$i_name', '$i_price', '$i_data')"
        if { ![ expr {$i_id % 50000} ] } {
            puts "Loading Items - $i_id [ clock format [ clock seconds ] ]"
        }
    }
    puts "Item done"
    return
}

proc Stock { odbc w_id MAXITEMS } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    set bld_cnt 1
    puts "Loading Stock Wid=$w_id"
    set s_w_id $w_id
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set orig($i) 0
    }
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set pos [ RandomNumber 0 $MAXITEMS ] 
        set orig($pos) 1
    }
    for {set s_i_id 1} {$s_i_id <= $MAXITEMS } {incr s_i_id } {
        set s_quantity [ RandomNumber 10 100 ]
        set s_dist_01 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_02 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_03 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_04 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_05 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_06 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_07 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_08 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_09 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_10 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_data [ MakeAlphaString 26 50 $globArray $chalen ]
        if { [ info exists orig($s_i_id) ] } {
            if { $orig($s_i_id) eq 1 } {
                set first [ RandomNumber 0 [ expr {[ string length $s_data]} - 8 ] ]
                set last [ expr {$first + 8} ]
                set s_data [ string replace $s_data $first $last "original" ]
            }
        }
        append val_list ('$s_i_id', '$s_w_id', '$s_quantity', '$s_dist_01', '$s_dist_02', '$s_dist_03', '$s_dist_04', '$s_dist_05', '$s_dist_06', '$s_dist_07', '$s_dist_08', '$s_dist_09', '$s_dist_10', '$s_data', '0', '0', '0')
        if { $bld_cnt<= 1 } { 
            append val_list ,
        }
        incr bld_cnt
        if { ![ expr {$s_i_id % 2} ] } {
            $odbc evaldirect "insert into stock (s_i_id, s_w_id, s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10, s_data, s_ytd, s_order_cnt, s_remote_cnt) values $val_list"
            set bld_cnt 1
            unset val_list
        }
        if { ![ expr {$s_i_id % 20000} ] } {
            puts "Loading Stock - $s_i_id"
        }
    }
    puts "Stock done"
    return
}

# stock table loading procedure that implements the exec bcp command
proc Stock_use_bcp { odbc w_id MAXITEMS } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    puts "Loading Stock Wid=$w_id [ clock format [ clock seconds ] ]"
    set s_w_id $w_id
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set orig($i) 0
    }
    for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
        set pos [ RandomNumber 0 $MAXITEMS ]
        set orig($pos) 1
    }

    # pass in values for secure connection to server and database name for bcp
    upvar 2 uid userid
    upvar 2 pwd pass
    upvar 2 server serv
    upvar 2 db db

    # create file for the stock table
    set tmp_env $::env(TMP)
    set StockFilePath "$tmp_env/StockTable$s_w_id.csv"
    set stock_list ""
    file delete $StockFilePath

    set value_list ""
    for {set s_i_id 1} {$s_i_id <= $MAXITEMS } {incr s_i_id } {
        set s_quantity [ RandomNumber 10 100 ]
        set s_dist_01 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_02 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_03 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_04 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_05 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_06 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_07 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_08 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_09 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_dist_10 [ MakeAlphaString 24 24 $globArray $chalen ]
        set s_data [ MakeAlphaString 26 50 $globArray $chalen ]
        if { [ info exists orig($s_i_id) ] } {
            if { $orig($s_i_id) eq 1 } {
                set first [ RandomNumber 0 [ expr {[ string length $s_data]} - 8 ] ]
                set last [ expr {$first + 8} ]
                set s_data [ string replace $s_data $first $last "original" ]
            }
        }
        # populate lists with appropriate row information
        append stock_list "$s_i_id,$s_w_id,$s_quantity,0,0,0,$s_data,$s_dist_01,$s_dist_02,$s_dist_03,$s_dist_04,$s_dist_05,$s_dist_06,$s_dist_07,$s_dist_08,$s_dist_09,$s_dist_10\n"
        if {![ expr {$s_i_id % 20000}]} {
            puts "Loading Stock - $s_i_id"
        }
    }
    # add any remaining data to stock table
    if {$stock_list ne ""} {
        set fileHandle [open $StockFilePath "a"]
        puts -nonewline $fileHandle $stock_list
        close $fileHandle
        unset stock_list
    }

    # bcp command to copy from file to stock table
    set tableName $db.dbo.stock
    bcpComm $odbc $tableName $StockFilePath $userid $pass $serv

    # delete file when copy is complete
    file delete $StockFilePath
    return
}

proc District { odbc w_id DIST_PER_WARE } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    puts "Loading District"
    set d_w_id $w_id
    set d_ytd 30000.0
    set d_next_o_id 3001
    for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
        set d_name [ MakeAlphaString 6 10 $globArray $chalen ]
        set d_add [ MakeAddress $globArray $chalen ]
        set d_tax_ran [ RandomNumber 10 20 ]
        set d_tax [ string replace [ format "%.2f" [ expr {$d_tax_ran / 100.0} ] ] 0 0 "" ]
        $odbc evaldirect "insert into district (d_id, d_w_id, d_name, d_street_1, d_street_2, d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id) values ('$d_id', '$d_w_id', '$d_name', '[ lindex $d_add 0 ]', '[ lindex $d_add 1 ]', '[ lindex $d_add 2 ]', '[ lindex $d_add 3 ]', '[ lindex $d_add 4 ]', '$d_tax', '$d_ytd', '$d_next_o_id')"
    }
    puts "District done"
    return
}

proc LoadWare { odbc ware_start count_ware MAXITEMS DIST_PER_WARE use_bcp } {
    set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
    set chalen [ llength $globArray ]
    puts "Loading Warehouse"
    set w_ytd 300000.00
    for {set w_id $ware_start } {$w_id <= $count_ware } {incr w_id } {
        set w_name [ MakeAlphaString 6 10 $globArray $chalen ]
        set add [ MakeAddress $globArray $chalen ]
        set w_tax_ran [ RandomNumber 10 20 ]
        set w_tax [ string replace [ format "%.2f" [ expr {$w_tax_ran / 100.0} ] ] 0 0 "" ]
        $odbc evaldirect "insert into warehouse (w_id, w_name, w_street_1, w_street_2, w_city, w_state, w_zip, w_tax, w_ytd) values ('$w_id', '$w_name', '[ lindex $add 0 ]', '[ lindex $add 1 ]', '[ lindex $add 2 ]' , '[ lindex $add 3 ]', '[ lindex $add 4 ]', '$w_tax', '$w_ytd')"
        if { $use_bcp eq "true"} {
            Stock_use_bcp $odbc $w_id $MAXITEMS
        } else {
            Stock $odbc $w_id $MAXITEMS
        }
        District $odbc $w_id $DIST_PER_WARE
    }
}

proc LoadCust { odbc ware_start count_ware CUST_PER_DIST DIST_PER_WARE use_bcp } {
    for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
        puts "Loading Customer for WID=$w_id [ clock format [ clock seconds ] ]"
        if { $use_bcp eq "true"}  {
          Customer_use_bcp $odbc $w_id $CUST_PER_DIST $DIST_PER_WARE
        } else {
          for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
            Customer $odbc $d_id $w_id $CUST_PER_DIST
          }
        }
    }
    return
}

proc LoadOrd { odbc ware_start count_ware MAXITEMS ORD_PER_DIST DIST_PER_WARE use_bcp } {
    for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
        puts "Loading Orders for W=$w_id [ clock format [ clock seconds ] ]"
        if { $use_bcp eq "true"} {
           Orders_use_bcp $odbc $w_id $MAXITEMS $ORD_PER_DIST $DIST_PER_WARE
        } else {
          for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
             Orders $odbc $d_id $w_id $MAXITEMS $ORD_PER_DIST
          }
       }
    }
    return
}

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

proc do_tpcc { server port odbc_driver authentication uid pwd tcp azure count_ware db imdb bucket_factor durability num_vu encrypt trust_cert use_bcp msi_object_id} {
    set MAXITEMS 100000
    set CUST_PER_DIST 3000
    set DIST_PER_WARE 10
    set ORD_PER_DIST 3000
    set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $db $encrypt $trust_cert $msi_object_id ]
    if { $num_vu > $count_ware } { set num_vu $count_ware }
    if { $num_vu > 1 && [ chk_thread ] eq "TRUE" } {
        set threaded "MULTI-THREADED"
        set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
        switch $myposition {
            1 {
                puts "Monitor Thread"
                if { $threaded eq "MULTI-THREADED" } {
                    tsv::lappend common thrdlst monitor
                    for { set th 1 } { $th <= $totalvirtualusers } { incr th } {
                        tsv::lappend common thrdlst idle
                    }
                    tsv::set application load "WAIT"
                }
            }
            default {
                puts "Worker Thread"
                if { [ expr $myposition - 1 ] > $count_ware } { puts "No Warehouses to Create"; return }
            }
        }
    } else {
        set threaded "SINGLE-THREADED"
        set num_vu 1
    }
    if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
        puts "CREATING [ string toupper $db ] SCHEMA"
        if [catch {tdbc::odbc::connection create odbc $connection} message ] {
            error "Connection to $connection could not be established : $message"
        } else {
            CreateDatabase odbc $db $imdb $azure 
            if {!$azure} {odbc evaldirect "use $db"}
            CreateTables odbc $imdb $count_ware $bucket_factor $durability
        }
        if { $threaded eq "MULTI-THREADED" } {
            tsv::set application load "READY"
            LoadItems odbc $MAXITEMS
            puts "Monitoring Workers..."
            set prevactive 0
            while 1 {
                set idlcnt 0; set lvcnt 0; set dncnt 0;
                for {set th 2} {$th <= $totalvirtualusers } {incr th} {
                    switch [tsv::lindex common thrdlst $th] {
                        idle { incr idlcnt }
                        active { incr lvcnt }
                        done { incr dncnt }
                    }
                }
                if { $lvcnt != $prevactive } {
                    puts "Workers: $lvcnt Active $dncnt Done"
                }
                set prevactive $lvcnt
                if { $dncnt eq [expr  $totalvirtualusers - 1] } { break }
                after 10000
            }} else {
            LoadItems odbc $MAXITEMS
    }}
    if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition != 1 } {
        if { $threaded eq "MULTI-THREADED" } {
            puts "Waiting for Monitor Thread..."
            set mtcnt 0
            while 1 {
                if { [ tsv::exists application load ] } {
                    incr mtcnt
                    if {  [ tsv::get application load ] eq "READY" } { break }
                    if { $mtcnt eq 48 } {
                        puts "Monitor failed to notify ready state"
                        return
                    }
                }
                after 5000
            }
            if [catch {tdbc::odbc::connection create odbc $connection} message ] {
                error "Connection to $connection could not be established : $message"
            } else {
                if {!$azure} {odbc evaldirect "use $db"}
                odbc evaldirect "set implicit_transactions OFF"
            } 
            set remb [ lassign [ findchunk $num_vu $count_ware $myposition ] chunk mystart myend ]
            puts "Loading $chunk Warehouses start:$mystart end:$myend"
            tsv::lreplace common thrdlst $myposition $myposition active
        } else {
            set mystart 1
            set myend $count_ware
        }
	set location [ location odbc ]
        puts "Start:[ clock format [ clock seconds ] ]"
        LoadWare odbc $mystart $myend $MAXITEMS $DIST_PER_WARE $use_bcp
        LoadCust odbc $mystart $myend $CUST_PER_DIST $DIST_PER_WARE $use_bcp
        LoadOrd odbc $mystart $myend $MAXITEMS $ORD_PER_DIST $DIST_PER_WARE $use_bcp
        puts "End:[ clock format [ clock seconds ] ]"
        if { $threaded eq "MULTI-THREADED" } {
            tsv::lreplace common thrdlst $myposition $myposition done
        }
    }
    if { $threaded eq "SINGLE-THREADED" || $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
        CreateIndexes odbc $imdb 
        CreateStoredProcs odbc $imdb 
        UpdateStatistics odbc $db $azure
        puts "[ string toupper $db ] SCHEMA COMPLETE"
        odbc close
        return
    }
}
}
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "do_tpcc {$mssqls_server} $mssqls_port {$mssqls_odbc_driver} $mssqls_authentication $mssqls_uid [ quotemeta $mssqls_pass ] $mssqls_tcp $mssqls_azure $mssqls_count_ware $mssqls_dbase $mssqls_imdb $mssqls_bucket $mssqls_durability $mssqls_num_vu $mssqls_encrypt_connection $mssqls_trust_server_cert $mssqls_use_bcp $mssqls_msi_object_id"
    } else { return }
}

proc insert_mssqlsconnectpool_drivescript { testtype timedtype } {
    #When using connect pooling delete the existing portions of the script and replace with new connect pool version
    set syncdrvt(1) {
        #RUN TPC-C
        #Get Connect data as a dict
        set cpool [ get_connect_xml mssqls ]
        #Extract connect data only from dict
        set connectonly [ dict filter [ dict get $cpool connections ] key c? ]
        #Extract the keys, this will be c1, c2 etc and determines number of connections
        set conkeys [ dict keys $connectonly ]
        #Loop through the keys of the connection parameters
        dict for {id conparams} $connectonly {
            #Set the parameters to variables named from the keys, this allows us to build the connect strings according to the database
            dict with conparams {
                #set SQL Server connect string
                if {![string match windows $::tcl_platform(platform)]} {
                    set mssqls_server $mssqls_linux_server 
                    set mssqls_odbc_driver $mssqls_linux_odbc
                    set mssqls_authentication $mssqls_linux_authent 
                }
                set $id [ list $mssqls_server $mssqls_port $mssqls_odbc_driver $mssqls_authentication $mssqls_uid $mssqls_pass $mssqls_tcp $mssqls_azure $mssqls_dbase $mssqls_encrypt_connection $mssqls_trust_server_cert $mssqls_msi_object_id" ]
            }
        }
        #For the connect keys c1, c2 etc make a connection
        foreach id [ split $conkeys ] {
            lassign [ set $id ] 1 2 3 4 5 6 7 8 9 10 11 12
            set connection [ connect_string $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 ]
            if [catch {tdbc::odbc::connection create odbc$id $connection} message ] {
                error "Connection to $connection could not be established : $message"
            } else {
                dict set connlist $id odbc$id
                if {!$azure} { odbc$id evaldirect "use $9" }
                odbc$id evaldirect "set implicit_transactions OFF"
            }
        }
        #Extract which storedprocedures use which connection
        foreach sproc [ dict keys [ dict get $cpool sprocs ] ] { 
            unset -nocomplain clist
            #Extract the policy for the storedprocedures
            set $sproc\_policy [ dict get $cpool sprocs $sproc policy ]
            foreach sp [ dict get $cpool sprocs $sproc connections ] {
                lappend clist [ dict get $connlist $sp ]
            }
            set newname "cs$sproc"
            unset -nocomplain $newname
            lappend $newname $clist
        }
        #Prepare statements multiple times for stored procedure for each connection and add to cursor list
        foreach st {neword_st payment_st ostat_st delivery_st slev_st} cslist {csneworder cspayment csdelivery csstocklevel csorderstatus} cursor_list { neworder_cursors payment_cursors delivery_cursors stocklevel_cursors orderstatus_cursors } len { nolen pylen dllen sllen oslen } cnt { nocnt pycnt dlcnt slcnt oscnt } { 
            unset -nocomplain $cursor_list
            set curcnt 0
            #For all of the connections
            foreach odbc [ join [ set $cslist ] ] {
                #Create a cursor name
                set cursor [ concat $st\_$curcnt ]
                #Prepare a statement under the cursor name
                set $cursor [ prep_statement $odbc $st ] 
                incr curcnt
                #Add it to a list of cursors for that stored procedure
                lappend $cursor_list [ set $cursor ]
            }
            #Record the number of cursors
            set $len [ llength  [ set $cursor_list ] ]
            #Initialise number of executions 
            set $cnt 0
            #puts "sproc_cur:$st connections:[ set $cslist ] cursors:[set $cursor_list] number of cursors:[set $len] execs:[set $cnt]"
        }
        #Open standalone connect to determine highest warehouse id for all connections
    	set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
        if [catch {tdbc::odbc::connection create odbc $connection} message ] {
            error "Connection to $connection could not be established : $message"
        } else {
            if {!$azure} { odbc evaldirect "use $database" }
            odbc evaldirect "set implicit_transactions OFF"
        }
        set rows [ odbc allrows "select max(w_id) from warehouse" ]
        set w_id_input [ lindex {*}$rows 1 ]
        #2.4.1.1 set warehouse_id stays constant for a given terminal
        set w_id  [ RandomNumber 1 $w_id_input ]  
        set rows [ odbc allrows "select max(d_id) from district" ]
        set d_id_input [ lindex {*}$rows 1 ]
        set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
        puts "Processing $total_iterations transactions without output suppressed..."
        set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
        for {set it 0} {$it < $total_iterations} {incr it} {
            if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
            set choice [ RandomNumber 1 23 ]
            if {$choice <= 10} {
                puts "new order"
                if { $KEYANDTHINK } { keytime 18 }
                set neword_st [ pick_cursor $neworder_policy $neworder_cursors $nocnt $nolen ]
                neword $neword_st $w_id $w_id_input $RAISEERROR
                incr nocnt
                if { $KEYANDTHINK } { thinktime 12 }
            } elseif {$choice <= 20} {
                puts "payment"
                if { $KEYANDTHINK } { keytime 3 }
                set payment_st [ pick_cursor $payment_policy $payment_cursors $pycnt $pylen ]
                payment $payment_st $w_id $w_id_input $RAISEERROR
                incr pycnt
                if { $KEYANDTHINK } { thinktime 12 }
            } elseif {$choice <= 21} {
                puts "delivery"
                if { $KEYANDTHINK } { keytime 2 }
                set delivery_st [ pick_cursor $delivery_policy $delivery_cursors $dlcnt $dllen ]
                delivery $delivery_st $w_id $RAISEERROR
                incr dlcnt
                if { $KEYANDTHINK } { thinktime 10 }
            } elseif {$choice <= 22} {
                puts "stock level"
                if { $KEYANDTHINK } { keytime 2 }
                set slev_st [ pick_cursor $stocklevel_policy $stocklevel_cursors $slcnt $sllen ]
                slev $slev_st $w_id $stock_level_d_id $RAISEERROR
                incr slcnt
                if { $KEYANDTHINK } { thinktime 5 }
            } elseif {$choice <= 23} {
                puts "order status"
                if { $KEYANDTHINK } { keytime 2 }
                set ostat_st [ pick_cursor $orderstatus_policy $orderstatus_cursors $oscnt $oslen ]
                ostat $ostat_st $w_id $RAISEERROR
                incr oscnt
                if { $KEYANDTHINK } { thinktime 5 }
            }
        }
foreach cursor $neworder_cursors { $cursor close }
foreach cursor $payment_cursors { $cursor close }
foreach cursor $delivery_cursors { $cursor close }
foreach cursor $stocklevel_cursors { $cursor close }
foreach cursor $orderstatus_cursors { $cursor close }
foreach odbc_con [ dict values $connlist ] { $odbc_con close }
odbc close
    }
    #Find single connection start and end points
    set syncdrvi(1a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "#RUN TPC-C" end ]
    set syncdrvi(1b) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "odbc close" end ]
    if { $timedtype eq "async" } {
        set syncdrvi(1b) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "odbc-\$clientname close" end ]
    }
    #puts "indexes are $syncdrvi(1a) and $syncdrvi(1b)"
    #Delete text from start and end points
    .ed_mainFrame.mainwin.textFrame.left.text fastdelete $syncdrvi(1a) $syncdrvi(1b)+1l
    #Replace with connect pool version
    .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(1a) $syncdrvt(1)
    if { $testtype eq "timed" } {
        #Diff between test and time sync scripts are the "puts stored proc lines", output suppressed, delete stored proc lines and replace output lines
        foreach line { {puts "new order"} {puts "payment"} {puts "delivery"} {puts "stock level"} {puts "order status"} } {
            #find start of line
            set index [.ed_mainFrame.mainwin.textFrame.left.text search -backwards $line end ]
            #delete to end of line including newline
            .ed_mainFrame.mainwin.textFrame.left.text fastdelete $index "$index lineend + 1 char"
        }
        foreach line {{"Processing $total_iterations transactions without output suppressed..."}} timedline {{"Processing $total_iterations transactions with output suppressed..."}} {
            set index [.ed_mainFrame.mainwin.textFrame.left.text search -backwards $line end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastdelete $index "$index lineend + 1 char"
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $index "$timedline \n"
        }
        if { $timedtype eq "async" } {
            set syncdrvt(3) {for {set it 0} {$it < $total_iterations} {incr it} {
                    if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
                    set choice [ RandomNumber 1 23 ]
                    if {$choice <= 10} {
                        if { $async_verbose } { puts "$clientname:w_id:$w_id:neword" }
                        if { $KEYANDTHINK } { async_keytime 18  $clientname neword $async_verbose }
                        set neword_st [ pick_cursor $neworder_policy $neworder_cursors $nocnt $nolen ]
                        neword $neword_st $w_id $w_id_input $RAISEERROR $clientname
                        incr nocnt
                        if { $KEYANDTHINK } { async_thinktime 12 $clientname neword $async_verbose }
                    } elseif {$choice <= 20} {
                        if { $async_verbose } { puts "$clientname:w_id:$w_id:payment" }
                        if { $KEYANDTHINK } { async_keytime 3 $clientname payment $async_verbose }
                        set payment_st [ pick_cursor $payment_policy $payment_cursors $pycnt $pylen ]
                        payment $payment_st $w_id $w_id_input $RAISEERROR $clientname
                        incr pycnt
                        if { $KEYANDTHINK } { async_thinktime 12 $clientname payment $async_verbose }
                    } elseif {$choice <= 21} {
                        if { $async_verbose } { puts "$clientname:w_id:$w_id:delivery" }
                        if { $KEYANDTHINK } { async_keytime 2 $clientname delivery $async_verbose }
                        set delivery_st [ pick_cursor $delivery_policy $delivery_cursors $dlcnt $dllen ]
                        delivery $delivery_st $w_id $RAISEERROR $clientname
                        incr dlcnt
                        if { $KEYANDTHINK } { async_thinktime 10 $clientname delivery $async_verbose }
                    } elseif {$choice <= 22} {
                        if { $async_verbose } { puts "$clientname:w_id:$w_id:slev" }
                        if { $KEYANDTHINK } { async_keytime 2 $clientname slev $async_verbose }
                        set slev_st [ pick_cursor $stocklevel_policy $stocklevel_cursors $slcnt $sllen ]
                        slev $slev_st $w_id $stock_level_d_id $RAISEERROR $clientname
                        incr slcnt
                        if { $KEYANDTHINK } { async_thinktime 5 $clientname slev $async_verbose }
                    } elseif {$choice <= 23} {
                        if { $async_verbose } { puts "$clientname:w_id:$w_id:ostat" }
                        if { $KEYANDTHINK } { async_keytime 2 $clientname ostat $async_verbose }
                        set ostat_st [ pick_cursor $orderstatus_policy $orderstatus_cursors $oscnt $oslen ]
                        ostat $ostat_st $w_id $RAISEERROR $clientname
                        incr oscnt
                        if { $KEYANDTHINK } { async_thinktime 5 $clientname ostat $async_verbose }
                    }
                }
            }
            #Change Run Loop for Asynchronous
            set syncdrvi(3a) [.ed_mainFrame.mainwin.textFrame.left.text search -forwards "for {set it 0}" 1.0 ]
            set syncdrvi(3b) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "foreach cursor \$neworder_cursors { \$cursor close }" end ]
            #End of run loop is previous line
            set syncdrvi(3b) [ expr $syncdrvi(3b) - 1 ]
            #Delete run loop
            .ed_mainFrame.mainwin.textFrame.left.text fastdelete $syncdrvi(3a) $syncdrvi(3b)+1l
            #Replace with asynchronous connect pool version
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(3a) $syncdrvt(3)
            #Remove extra async connection
            set syncdrvi(2a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "#Open standalone connect to determine highest warehouse id for all connections" end ]
            set syncdrvi(2b) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards {set rows [ odbc allrows "select max(w_id) from warehouse" ]} end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastdelete $syncdrvi(2a) $syncdrvi(2b)+1l
            set asynchconline {set rows [ odbc-$clientname allrows "select max(w_id) from warehouse" ]}
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(2a) "$asynchconline \n"
            #Replace individual lines for Asynch
            foreach line {{#puts "sproc_cur:$st connections:[ set $cslist ] cursors:[set $cursor_list] number of cursors:[set $len] execs:[set $cnt]"} {puts "Processing $total_iterations transactions with output suppressed..."} {dict set connlist $id odbc$id} {if {!$azure} { odbc$id evaldirect "use $9" }} {odbc$id evaldirect "set implicit_transactions OFF"} {set rows [ odbc allrows "select max(d_id) from district" ]} {odbc close}} asynchline {{#puts "$clientname:sproc_cur:$st connections:[ set $cslist ] cursors:[set $cursor_list] number of cursors:[set $len] execs:[set $cnt]"} {if { $async_verbose } {puts "Processing $total_iterations transactions with output suppressed..." }} {dict set connlist $id odbc-$clientname-$id} {if {!$azure} { odbc-$clientname-$id evaldirect "use $9" }} {odbc-$clientname-$id evaldirect "set implicit_transactions OFF"} {set rows [ odbc-$clientname allrows "select max(d_id) from district" ]} {odbc-$clientname close}} {
                set index [.ed_mainFrame.mainwin.textFrame.left.text search -backwards $line end ]
                .ed_mainFrame.mainwin.textFrame.left.text fastdelete $index "$index lineend + 1 char"
                .ed_mainFrame.mainwin.textFrame.left.text fastinsert $index "$asynchline \n"
            }
            #Edit line with additional curly bracket needs additional subst command so cannot go in loop
            set index [.ed_mainFrame.mainwin.textFrame.left.text search -backwards [ subst -nocommands -novariables {if [catch {tdbc::odbc::connection create odbc$id $connection} message ] \{} ] end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastdelete $index "$index lineend + 1 char"
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $index "[ subst -nocommands -novariables {if [catch {tdbc::odbc::connection create odbc-$clientname-$id $connection} message ] \{} ] \n"
            #Add client side counters for timed async only this is different from non-async
            set syncdrvt(4) {initializeclientcountasync $totalvirtualusers $async_client
            }
            set syncdrvt(5) {getclienttpmasync $rampup $duration $totalvirtualusers $async_client
            }
            set syncdrvt(6) {printclientcountasync $clientname $nocnt $pycnt $dlcnt $slcnt $oscnt
            }
            set syncdrvi(4a) [.ed_mainFrame.mainwin.textFrame.left.text search -forwards "set ramptime 0" 1.0 ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(4a) $syncdrvt(4)
            set syncdrvi(5a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "tsv::set application abort 1" end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(5a)+1l $syncdrvt(5)
            set syncdrvi(6a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards {foreach cursor $neworder_cursors { $cursor close }} end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(6a) $syncdrvt(6)
        } else {
            #Add client side counters for timed non-async only
            set syncdrvt(4) {initializeclientcountsync $totalvirtualusers
            }
            set syncdrvt(5) {getclienttpmsync $rampup $duration $totalvirtualusers
            }
            set syncdrvt(6) {printclientcountsync $myposition $nocnt $pycnt $dlcnt $slcnt $oscnt
            }
            set syncdrvi(4a) [.ed_mainFrame.mainwin.textFrame.left.text search -forwards "set ramptime 0" 1.0 ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(4a) $syncdrvt(4)
            set syncdrvi(5a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards "tsv::set application abort 1" end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(5a)+1l $syncdrvt(5)
            set syncdrvi(6a) [.ed_mainFrame.mainwin.textFrame.left.text search -backwards {foreach cursor $neworder_cursors { $cursor close }} end ]
            .ed_mainFrame.mainwin.textFrame.left.text fastinsert $syncdrvi(6a) $syncdrvt(6)
        }
    }
}

proc loadmssqlstpcc { } {
    global _ED
    upvar #0 dbdict dbdict
    if {[dict exists $dbdict mssqlserver library ]} {
        set library [ dict get $dbdict mssqlserver library ]
    } else { set library "tdbc::odbc 1.0.6" }
    if { [ llength $library ] > 1 } { 
        set version [ lindex $library 1 ]
        set library [ lindex $library 0 ]
    }
    upvar #0 configmssqlserver configmssqlserver
    #set variables to values in dict
    setlocaltpccvars $configmssqlserver
    if {![string match windows $::tcl_platform(platform)]} {
        set mssqls_server $mssqls_linux_server 
        set mssqls_odbc_driver $mssqls_linux_odbc
        set mssqls_authentication $mssqls_linux_authent 
    }
    ed_edit_clear
    .ed_mainFrame.notebook select .ed_mainFrame.mainwin
    set _ED(packagekeyname) "SQL Server TPROC-C"
    .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#OPTIONS
set library $library ;# SQL Server Library
set version $version ;# SQL Server Library Version
set total_iterations $mssqls_total_iterations;# Number of transactions before logging off
set RAISEERROR \"$mssqls_raiseerror\" ;# Exit script on SQL Server error (true or false)
set KEYANDTHINK \"$mssqls_keyandthink\" ;# Time for user thinking and keying (true or false)
set authentication \"$mssqls_authentication\";# Authentication Mode (WINDOWS or SQL)
set server \{$mssqls_server\};# Microsoft SQL Server Database Server
set port \"$mssqls_port\";# Microsoft SQL Server Port 
set odbc_driver \{$mssqls_odbc_driver\};# ODBC Driver
set uid \"$mssqls_uid\";#User ID for SQL Server Authentication
set pwd \"[ quotemeta $mssqls_pass ]\";#Password for SQL Server Authentication
set tcp \"$mssqls_tcp\";#Specify TCP Protocol
set azure \"$mssqls_azure\";#Azure Type Connection
set database \"$mssqls_dbase\";# Database containing the TPC Schema
set encrypt \"$mssqls_encrypt_connection\";# Encrypt Connection
set trust_cert \"$mssqls_trust_server_cert\";# Trust Server Certificate
set msi_object_id \"$mssqls_msi_object_id\";# MSI Object ID for Entra authentication
#OPTIONS
"
    .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

#TIMESTAMP
proc gettimestamp { } {
    set tstamp [ clock format [ clock seconds ] -format "%Y-%m-%d %H:%M:%S" ]
    return $tstamp
}
#NEW ORDER
proc neword { neword_st no_w_id w_id_input RAISEERROR } {
    #2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
    set no_d_id [ RandomNumber 1 10 ]
    #2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
    set no_c_id [ RandomNumber 1 3000 ]
    #2.4.1.3 Items in the order randomly selected from 5 to 15
    set ol_cnt [ RandomNumber 5 15 ]
    #2.4.1.6 order entry date O_ENTRY_D generated by SUT
    set date [ gettimestamp ]
    if  {[catch {set resultset [ $neword_st execute [ list no_w_id $no_w_id w_id_input $w_id_input no_d_id $no_d_id no_c_id $no_c_id ol_cnt $ol_cnt date $date ]]} message ]} {
        if { $RAISEERROR } {
            error "New Order Bind/Exec : $message"
        } else {
            puts "New Order Bind/Exec : $message"
        }
    } else {
        if {[catch {set norows [ $resultset allrows ]} message ]} {
            catch {$resultset close}
            if { $RAISEERROR } {
                error "New Order Fetch : $message"
            } else {
                puts "New Order Fetch : $message"
            }} else {
            regsub -all {[\s]+} [ join $norows ] {} norowsstr
            puts $norowsstr
            catch {$resultset close}
        }
    }
}

#PAYMENT
proc payment { payment_st p_w_id w_id_input RAISEERROR } {
    #2.5.1.1 The home warehouse id remains the same for each terminal
    #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
    set p_d_id [ RandomNumber 1 10 ]
    #2.5.1.2 customer selected 60% of time by name and 40% of time by number
    set x [ RandomNumber 1 100 ]
    set y [ RandomNumber 1 100 ]
    if { $x <= 85 } {
        set p_c_d_id $p_d_id
        set p_c_w_id $p_w_id
    } else {
        #use a remote warehouse
        set p_c_d_id [ RandomNumber 1 10 ]
        set p_c_w_id [ RandomNumber 1 $w_id_input ]
        while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
            set p_c_w_id [ RandomNumber 1  $w_id_input ]
        }
    }
    set nrnd [ NURand 255 0 999 123 ]
    set name [ randname $nrnd ]
    set p_c_id [ RandomNumber 1 3000 ]
    if { $y <= 60 } {
        #use customer name
        #C_LAST is generated
        set byname 1
    } else {
        #use customer number
        set byname 0
        set name {}
    }
    #2.5.1.3 random amount from 1 to 5000
    set p_h_amount [ RandomNumber 1 5000 ]
    #2.5.1.4 date selected from SUT
    set h_date [ gettimestamp ]
    #2.5.2.1 Payment Transaction
    if  {[catch {set resultset [ $payment_st execute [ list p_w_id $p_w_id p_d_id $p_d_id p_c_w_id $p_c_w_id p_c_d_id $p_c_d_id p_c_id $p_c_id byname $byname p_h_amount $p_h_amount name $name h_date $h_date ] ]} message ]} {
        if { $RAISEERROR } {
            error "Payment Bind/Exec : $message"
        } else {
            puts "Payment Bind/Exec : $message"
        }
    } else {
        if {[catch {set pyrows [ $resultset allrows ]} message ]} {
            catch {$resultset close}
            if { $RAISEERROR } {
                error "Payment Fetch : $message"
            } else {
                puts "Payment Fetch : $message"
            }} else {
            regsub -all {[\s]+} [ join $pyrows ] {} pyrowsstr
            puts $pyrowsstr
            catch {$resultset close}
        }
    }
}

#ORDER_STATUS
proc ostat { ostat_st w_id RAISEERROR } {
    #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
    set d_id [ RandomNumber 1 10 ]
    set nrnd [ NURand 255 0 999 123 ]
    set name [ randname $nrnd ]
    set c_id [ RandomNumber 1 3000 ]
    set y [ RandomNumber 1 100 ]
    if { $y <= 60 } {
        set byname 1
    } else {
        set byname 0
        set name {}
    }
    if  {[catch {set resultset [ $ostat_st execute [ list os_w_id $w_id os_d_id $d_id os_c_id  $c_id byname  $byname os_c_last $name ]]} message ]} {
        if { $RAISEERROR } {
            error "Order Status Bind/Exec : $message"
        } else {
            puts "Order Status Bind/Exec : $message"
        }
    } else {
        if {[catch {set osrows [ $resultset allrows ]} message ]} {
            catch {$resultset close}
            if { $RAISEERROR } {
                error "Order Status Fetch : $message"
            } else {
                puts "Order Status Fetch : $message"
            }} else {
            regsub -all {[\s]+} [ join $osrows ] {} osrowsstr
            puts $osrowsstr
            catch {$resultset close}
        }
    }
}

#DELIVERY
proc delivery { delivery_st w_id RAISEERROR } {
    set carrier_id [ RandomNumber 1 10 ]
    set date [ gettimestamp ]
    if  {[catch {set resultset [ $delivery_st execute [ list d_w_id $w_id d_o_carrier_id $carrier_id timestamp $date ]]} message ]} {
        if { $RAISEERROR } {
            error "Delivery Bind/Exec : $message"
        } else {
            puts "Delivery Bind/Exec : $message"
        }
    } else {
        if {[catch {set dlrows [ $resultset allrows ]} message ]} {
            catch {$resultset close}
            if { $RAISEERROR } {
                error "Delivery Fetch : $message"
            } else {
                puts "Delivery Fetch : $message"
            }} else {
            regsub -all {[\s]+} [ join $dlrows ] {} dlrowsstr
            puts $dlrowsstr
            catch {$resultset close}
        }
    }
}

#STOCK LEVEL
proc slev { slev_st w_id stock_level_d_id RAISEERROR } {
    set threshold [ RandomNumber 10 20 ]
    if  {[catch {set resultset [ $slev_st execute [ list st_w_id $w_id st_d_id $stock_level_d_id threshold $threshold ]]} message ]} {
        if { $RAISEERROR } {
            error "Stock Level : $message"
        } else {
            puts "Stock Level : $message"
        }
    } else {
        if {[catch {set slrows [ $resultset allrows ]} message ]} {
            catch {$resultset close}
            if { $RAISEERROR } {
                error "Stock Level Fetch : $message"
            } else {
                puts "Stock Level Fetch : $message"
            }} else {
            regsub -all {[\s]+} [ join $slrows ] {} slrowsstr
            puts $slrowsstr
            catch {$resultset close}
        }
    }
}

proc prep_statement { odbc statement_st } {
    switch $statement_st {
        slev_st {
            set slev_st [ $odbc prepare "EXEC slev @st_w_id = :st_w_id, @st_d_id = :st_d_id, @threshold =  :threshold" ]
            $slev_st paramtype st_w_id in integer 10 0
            $slev_st paramtype st_d_id in integer 10 0
            $slev_st paramtype threshold in integer 10 0
            return $slev_st
        }

        delivery_st {
            set delivery_st [ $odbc prepare "EXEC delivery @d_w_id = :d_w_id, @d_o_carrier_id = :d_o_carrier_id, @timestamp = :timestamp" ]
            $delivery_st paramtype d_w_id in integer 10 0
            $delivery_st paramtype d_o_carrier_id in integer 10 0
            $delivery_st paramtype timestamp in timestamp 19 0
            return $delivery_st
        }
        ostat_st {
            set ostat_st [ $odbc prepare "EXEC ostat @os_w_id = :os_w_id, @os_d_id = :os_d_id, @os_c_id = :os_c_id, @byname = :byname, @os_c_last = :os_c_last" ]
            $ostat_st paramtype os_w_id in integer 10 0
            $ostat_st paramtype os_d_id in integer 10 0
            $ostat_st paramtype os_c_id in integer 10 0 
            $ostat_st paramtype byname in integer 10 0 
            $ostat_st paramtype os_c_last in char 20 0
            return $ostat_st
        }
        payment_st {
            set payment_st [ $odbc prepare "EXEC payment @p_w_id = :p_w_id, @p_d_id = :p_d_id, @p_c_w_id = :p_c_w_id, @p_c_d_id = :p_c_d_id, @p_c_id = :p_c_id, @byname = :byname, @p_h_amount = :p_h_amount, @p_c_last = :name, @TIMESTAMP =:h_date" ] 
            $payment_st paramtype p_w_id in integer 10 0
            $payment_st paramtype p_d_id in integer 10 0
            $payment_st paramtype p_c_w_id in integer 10 0
            $payment_st paramtype p_c_d_id in integer 10 0
            $payment_st paramtype p_c_id in integer 10 0
            $payment_st paramtype byname in integer 10 0
            $payment_st paramtype p_h_amount in numeric 6 2
            $payment_st paramtype name in char 16 0
            $payment_st paramtype h_date in timestamp 19 0
            return $payment_st
        }
        neword_st {
            set neword_st [ $odbc prepare "EXEC neword @no_w_id = :no_w_id, @no_max_w_id = :w_id_input, @no_d_id = :no_d_id, @no_c_id = :no_c_id, @no_o_ol_cnt = :ol_cnt, @TIMESTAMP = :date" ]
            $neword_st paramtype no_w_id in integer 10 0 
            $neword_st paramtype w_id_input in integer 10 0 
            $neword_st paramtype no_d_id in integer 10 0 
            $neword_st paramtype no_c_id in integer 10 0 
            $neword_st paramtype ol_cnt integer 10 0 
            $neword_st paramtype date in timestamp 19 0
            return $neword_st
        }
    }
}

#RUN TPC-C
set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
if [catch {tdbc::odbc::connection create odbc $connection} message ] {
    error "Connection to $connection could not be established : $message"
} else {
    if {!$azure} { odbc evaldirect "use $database" }
    odbc evaldirect "set implicit_transactions OFF"
}
foreach st {neword_st payment_st ostat_st delivery_st slev_st} { set $st [ prep_statement odbc $st ] }
set rows [ odbc allrows "select max(w_id) from warehouse" ]
set w_id_input [ lindex {*}$rows 1 ]
#2.4.1.1 set warehouse_id stays constant for a given terminal
set w_id  [ RandomNumber 1 $w_id_input ]  
set rows [ odbc allrows "select max(d_id) from district" ]
set d_id_input [ lindex {*}$rows 1 ]
set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
puts "Processing $total_iterations transactions without output suppressed..."
set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
for {set it 0} {$it < $total_iterations} {incr it} {
    if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
    set choice [ RandomNumber 1 23 ]
    if {$choice <= 10} {
        puts "new order"
        if { $KEYANDTHINK } { keytime 18 }
        neword $neword_st $w_id $w_id_input $RAISEERROR
        if { $KEYANDTHINK } { thinktime 12 }
    } elseif {$choice <= 20} {
        puts "payment"
        if { $KEYANDTHINK } { keytime 3 }
        payment $payment_st $w_id $w_id_input $RAISEERROR
        if { $KEYANDTHINK } { thinktime 12 }
    } elseif {$choice <= 21} {
        puts "delivery"
        if { $KEYANDTHINK } { keytime 2 }
        delivery $delivery_st $w_id $RAISEERROR
        if { $KEYANDTHINK } { thinktime 10 }
    } elseif {$choice <= 22} {
        puts "stock level"
        if { $KEYANDTHINK } { keytime 2 }
        slev $slev_st $w_id $stock_level_d_id $RAISEERROR
        if { $KEYANDTHINK } { thinktime 5 }
    } elseif {$choice <= 23} {
        puts "order status"
        if { $KEYANDTHINK } { keytime 2 }
        ostat $ostat_st $w_id $RAISEERROR
        if { $KEYANDTHINK } { thinktime 5 }
    }
}
$neword_st close 
$payment_st close
$delivery_st close
$slev_st close
$ostat_st close
odbc close}
    if { $mssqls_connect_pool } { 
        insert_mssqlsconnectpool_drivescript test sync 
    }
}

proc loadtimedmssqlstpcc { } {
    global opmode _ED
    upvar #0 dbdict dbdict
    if {[dict exists $dbdict mssqlserver library ]} {
        set library [ dict get $dbdict mssqlserver library ]
    } else { set library "tdbc::odbc 1.0.6" }
    if { [ llength $library ] > 1 } { 
        set version [ lindex $library 1 ]
        set library [ lindex $library 0 ]
    }
    upvar #0 configmssqlserver configmssqlserver
    #set variables to values in dict
    setlocaltpccvars $configmssqlserver
    if {![string match windows $::tcl_platform(platform)]} {
        set mssqls_server $mssqls_linux_server 
        set mssqls_odbc_driver $mssqls_linux_odbc
        set mssqls_authentication $mssqls_linux_authent 
    }
    ed_edit_clear
    .ed_mainFrame.notebook select .ed_mainFrame.mainwin
    set _ED(packagekeyname) "SQL Server TPROC-C"
    if { !$mssqls_async_scale } {
        #REGULAR TIMED SCRIPT
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#OPTIONS
set library $library ;# SQL Server Library
set version $version ;# SQL Server Library Version
set total_iterations $mssqls_total_iterations;# Number of transactions before logging off
set RAISEERROR \"$mssqls_raiseerror\" ;# Exit script on SQL Server error (true or false)
set KEYANDTHINK \"$mssqls_keyandthink\" ;# Time for user thinking and keying (true or false)
set CHECKPOINT \"$mssqls_checkpoint\" ;# Perform SQL Server checkpoint when complete (true or false)
set rampup $mssqls_rampup;  # Rampup time in minutes before first Transaction Count is taken
set duration $mssqls_duration;  # Duration in minutes before second Transaction Count is taken
set mode \"$opmode\" ;# HammerDB operational mode
set authentication \"$mssqls_authentication\";# Authentication Mode (WINDOWS or SQL)
set server \{$mssqls_server\};# Microsoft SQL Server Database Server
set port \"$mssqls_port\";# Microsoft SQL Server Port 
set odbc_driver \{$mssqls_odbc_driver\};# ODBC Driver
set uid \"$mssqls_uid\";#User ID for SQL Server Authentication
set pwd \"[ quotemeta $mssqls_pass ]\";#Password for SQL Server Authentication
set tcp \"$mssqls_tcp\";#Specify TCP Protocol
set azure \"$mssqls_azure\";#Azure Type Connection
set database \"$mssqls_dbase\";# Database containing the TPC Schema
set encrypt \"$mssqls_encrypt_connection\";# Encrypt Connection
set trust_cert \"$mssqls_trust_server_cert\";# Trust Server Certificate
set msi_object_id \"$mssqls_msi_object_id\";# MSI Object ID for Entra authentication
#OPTIONS
"
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }

if { [ chk_thread ] eq "FALSE" } {
    error "SQL Server Timed Script must be run in Thread Enabled Interpreter"
}

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

proc CheckDBVersion { odbc } {
	   if {[catch {set rows [ odbc allrows "SELECT SERVERPROPERTY('productversion')" ]} message ]} {
		set dbversion "DBVersion:NULL"
	   } else {
	        set dbversion "DBVersion:[ lindex {*}$rows 1 ]"
	   }
	   return "$dbversion"
	}

set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
switch $myposition {
    1 { 
        if { $mode eq "Local" || $mode eq "Primary" } {
    	    set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
            if [catch {tdbc::odbc::connection create odbc $connection} message ] {
                error "Connection to $connection could not be established : $message"
            } else {
                if {!$azure} { odbc evaldirect "use $database" }
            }
            set ramptime 0
	    puts [ CheckDBVersion odbc ]
            puts "Beginning rampup time of $rampup minutes"
            set rampup [ expr $rampup*60000 ]
            while {$ramptime != $rampup} {
                if { [ tsv::get application abort ] } { break } else { after 6000 }
                set ramptime [ expr $ramptime+6000 ]
                if { ![ expr {$ramptime % 60000} ] } {
                    puts "Rampup [ expr $ramptime / 60000 ] minutes complete ..."
                }
            }
            if { [ tsv::get application abort ] } { break }
            puts "Rampup complete, Taking start Transaction Count."
            if {[catch {set rows [ odbc allrows "select sum(cast(d_next_o_id as bigint)) from district" ]} message ]} {
                error "Failed to query district table : $message"
            } else {
                set start_nopm [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            }
            if {[catch {set rows [ odbc allrows "select cntr_value from sys.dm_os_performance_counters where counter_name = 'Batch Requests/sec'" ]} message ]} {
                error "Failed to query transaction statistics : $message"
            } else {
                set start_trans [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            } 
            puts "Timing test period of $duration in minutes"
            set testtime 0
            set durmin $duration
            set duration [ expr $duration*60000 ]
            while {$testtime != $duration} {
                if { [ tsv::get application abort ] } { break } else { after 6000 }
                set testtime [ expr $testtime+6000 ]
                if { ![ expr {$testtime % 60000} ] } {
                    puts -nonewline  "[ expr $testtime / 60000 ]  ...,"
                }
            }
            if { [ tsv::get application abort ] } { break }
            puts "Test complete, Taking end Transaction Count."
            if {[catch {set rows [ odbc allrows "select sum(cast(d_next_o_id as bigint)) from district" ]} message ]} {
                error "Failed to query district table : $message"
            } else {
                set end_nopm [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            }
            if {[catch {set rows [ odbc allrows "select cntr_value from sys.dm_os_performance_counters where counter_name = 'Batch Requests/sec'" ]} message ]} {
                error "Failed to query transaction statistics : $message"
            } else {
                set end_trans [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            } 
            if { [ string is entier -strict $end_trans ] && [ string is entier -strict $start_trans ] } {
                if { $start_trans < $end_trans }  {
                    set tpm [ expr {($end_trans - $start_trans)/$durmin} ]
                } else {
                    puts "Warning: SQL Server returned end transaction count data greater than start data"
                    set tpm 0
                } 
            } else {
                puts "Warning: SQL Server returned non-numeric transaction count data"
                set tpm 0
            }
            set nopm [ expr {($end_nopm - $start_nopm)/$durmin} ]
            puts "[ expr $totalvirtualusers - 1 ] Active Virtual Users configured"
            puts [ testresult $nopm $tpm "SQL Server" ]
            tsv::set application abort 1
            if { $mode eq "Primary" } { eval [subst {thread::send -async $MASTER { remote_command ed_kill_vusers }}] }
            if { $CHECKPOINT } {
                puts "Checkpoint"
                if  [catch {odbc evaldirect "checkpoint"} message ]  {
                    error "Failed to execute checkpoint : $message"
                } else {
                    puts "Checkpoint Complete"
                }
            }
            odbc close
        } else {
            puts "Operating in Replica Mode, No Snapshots taken..."
        }
    }
    default {
        #TIMESTAMP
        proc gettimestamp { } {
            set tstamp [ clock format [ clock seconds ] -format "%Y-%m-%d %H:%M:%S" ]
            return $tstamp
        }
        #NEW ORDER
        proc neword { neword_st no_w_id w_id_input RAISEERROR } {
            #2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
            set no_d_id [ RandomNumber 1 10 ]
            #2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
            set no_c_id [ RandomNumber 1 3000 ]
            #2.4.1.3 Items in the order randomly selected from 5 to 15
            set ol_cnt [ RandomNumber 5 15 ]
            #2.4.1.6 order entry date O_ENTRY_D generated by SUT
            set date [ gettimestamp ]
            if  {[catch {set resultset [ $neword_st execute [ list no_w_id $no_w_id w_id_input $w_id_input no_d_id $no_d_id no_c_id $no_c_id ol_cnt $ol_cnt date $date ]]} message ]} {
                if { $RAISEERROR } {
                    error "New Order Bind/Exec : $message"
                } else {
                    puts "New Order Bind/Exec : $message"
                }
            } else {
                if {[catch {set norows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "New Order Fetch : $message"
                    } else {
                        puts "New Order Fetch : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #PAYMENT
        proc payment { payment_st p_w_id w_id_input RAISEERROR } {
            #2.5.1.1 The home warehouse id remains the same for each terminal
            #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
            set p_d_id [ RandomNumber 1 10 ]
            #2.5.1.2 customer selected 60% of time by name and 40% of time by number
            set x [ RandomNumber 1 100 ]
            set y [ RandomNumber 1 100 ]
            if { $x <= 85 } {
                set p_c_d_id $p_d_id
                set p_c_w_id $p_w_id
            } else {
                #use a remote warehouse
                set p_c_d_id [ RandomNumber 1 10 ]
                set p_c_w_id [ RandomNumber 1 $w_id_input ]
                while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
                    set p_c_w_id [ RandomNumber 1  $w_id_input ]
                }
            }
            set nrnd [ NURand 255 0 999 123 ]
            set name [ randname $nrnd ]
            set p_c_id [ RandomNumber 1 3000 ]
            if { $y <= 60 } {
                #use customer name
                #C_LAST is generated
                set byname 1
            } else {
                #use customer number
                set byname 0
                set name {}
            }
            #2.5.1.3 random amount from 1 to 5000
            set p_h_amount [ RandomNumber 1 5000 ]
            #2.5.1.4 date selected from SUT
            set h_date [ gettimestamp ]
            #2.5.2.1 Payment Transaction
            if  {[catch {set resultset [ $payment_st execute [ list p_w_id $p_w_id p_d_id $p_d_id p_c_w_id $p_c_w_id p_c_d_id $p_c_d_id p_c_id $p_c_id byname $byname p_h_amount $p_h_amount name $name h_date $h_date ] ]} message ]} {
                if { $RAISEERROR } {
                    error "Payment Bind/Exec : $message"
                } else {
                    puts "Payment Bind/Exec : $message"
                }
            } else {
                if {[catch {set pyrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Payment Fetch : $message"
                    } else {
                        puts "Payment Fetch : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #ORDER_STATUS
        proc ostat { ostat_st w_id RAISEERROR } {
            #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
            set d_id [ RandomNumber 1 10 ]
            set nrnd [ NURand 255 0 999 123 ]
            set name [ randname $nrnd ]
            set c_id [ RandomNumber 1 3000 ]
            set y [ RandomNumber 1 100 ]
            if { $y <= 60 } {
                set byname 1
            } else {
                set byname 0
                set name {}
            }
            if  {[catch {set resultset [ $ostat_st execute [ list os_w_id $w_id os_d_id $d_id os_c_id  $c_id byname  $byname os_c_last $name ]]} message ]} {
                if { $RAISEERROR } {
                    error "Order Status Bind/Exec : $message"
                } else {
                    puts "Order Status Bind/Exec : $message"
                }
            } else {
                if {[catch {set osrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Order Status Fetch : $message"
                    } else {
                        puts "Order Status Fetch : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #DELIVERY
        proc delivery { delivery_st w_id RAISEERROR } {
            set carrier_id [ RandomNumber 1 10 ]
            set date [ gettimestamp ]
            if  {[catch {set resultset [ $delivery_st execute [ list d_w_id $w_id d_o_carrier_id $carrier_id timestamp $date ]]} message ]} {
                if { $RAISEERROR } {
                    error "Delivery Bind/Exec : $message"
                } else {
                    puts "Delivery Bind/Exec : $message"
                }
            } else {
                if {[catch {set dlrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Delivery Fetch : $message"
                    } else {
                        puts "Delivery Fetch : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #STOCK LEVEL
        proc slev { slev_st w_id stock_level_d_id RAISEERROR } {
            set threshold [ RandomNumber 10 20 ]
            if  {[catch {set resultset [ $slev_st execute [ list st_w_id $w_id st_d_id $stock_level_d_id threshold $threshold ]]} message ]} {
                if { $RAISEERROR } {
                    error "Stock Level : $message"
                } else {
                    puts "Stock Level : $message"
                }
            } else {
                if {[catch {set slrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Stock Level Fetch : $message"
                    } else {
                        puts "Stock Level Fetch : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        proc prep_statement { odbc statement_st } {
            switch $statement_st {
                slev_st {
                    set slev_st [ $odbc prepare "EXEC slev @st_w_id = :st_w_id, @st_d_id = :st_d_id, @threshold =  :threshold" ]
                    $slev_st paramtype st_w_id in integer 10 0
                    $slev_st paramtype st_d_id in integer 10 0
                    $slev_st paramtype threshold in integer 10 0
                    return $slev_st
                }

                delivery_st {
                    set delivery_st [ $odbc prepare "EXEC delivery @d_w_id = :d_w_id, @d_o_carrier_id = :d_o_carrier_id, @timestamp = :timestamp" ]
                    $delivery_st paramtype d_w_id in integer 10 0
                    $delivery_st paramtype d_o_carrier_id in integer 10 0
                    $delivery_st paramtype timestamp in timestamp 19 0
                    return $delivery_st
                }
                ostat_st {
                    set ostat_st [ $odbc prepare "EXEC ostat @os_w_id = :os_w_id, @os_d_id = :os_d_id, @os_c_id = :os_c_id, @byname = :byname, @os_c_last = :os_c_last" ]
                    $ostat_st paramtype os_w_id in integer 10 0
                    $ostat_st paramtype os_d_id in integer 10 0
                    $ostat_st paramtype os_c_id in integer 10 0 
                    $ostat_st paramtype byname in integer 10 0 
                    $ostat_st paramtype os_c_last in char 20 0
                    return $ostat_st
                }
                payment_st {
                    set payment_st [ $odbc prepare "EXEC payment @p_w_id = :p_w_id, @p_d_id = :p_d_id, @p_c_w_id = :p_c_w_id, @p_c_d_id = :p_c_d_id, @p_c_id = :p_c_id, @byname = :byname, @p_h_amount = :p_h_amount, @p_c_last = :name, @TIMESTAMP =:h_date" ] 
                    $payment_st paramtype p_w_id in integer 10 0
                    $payment_st paramtype p_d_id in integer 10 0
                    $payment_st paramtype p_c_w_id in integer 10 0
                    $payment_st paramtype p_c_d_id in integer 10 0
                    $payment_st paramtype p_c_id in integer 10 0
                    $payment_st paramtype byname in integer 10 0
                    $payment_st paramtype p_h_amount in numeric 6 2
                    $payment_st paramtype name in char 16 0
                    $payment_st paramtype h_date in timestamp 19 0
                    return $payment_st
                }
                neword_st {
                    set neword_st [ $odbc prepare "EXEC neword @no_w_id = :no_w_id, @no_max_w_id = :w_id_input, @no_d_id = :no_d_id, @no_c_id = :no_c_id, @no_o_ol_cnt = :ol_cnt, @TIMESTAMP = :date" ]
                    $neword_st paramtype no_w_id in integer 10 0 
                    $neword_st paramtype w_id_input in integer 10 0 
                    $neword_st paramtype no_d_id in integer 10 0 
                    $neword_st paramtype no_c_id in integer 10 0 
                    $neword_st paramtype ol_cnt integer 10 0 
                    $neword_st paramtype date in timestamp 19 0
                    return $neword_st
                }
            }
        }

        #RUN TPC-C
    	set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
        if [catch {tdbc::odbc::connection create odbc $connection} message ] {
            error "Connection to $connection could not be established : $message"
        } else {
            if {!$azure} { odbc evaldirect "use $database" }
            odbc evaldirect "set implicit_transactions OFF"
        }
        foreach st {neword_st payment_st ostat_st delivery_st slev_st} { set $st [ prep_statement odbc $st ] }
        set rows [ odbc allrows "select max(w_id) from warehouse" ]
        set w_id_input [ lindex {*}$rows 1 ]
        #2.4.1.1 set warehouse_id stays constant for a given terminal
        set w_id  [ RandomNumber 1 $w_id_input ]  
        set rows [ odbc allrows "select max(d_id) from district" ]
        set d_id_input [ lindex {*}$rows 1 ]
        set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
        puts "Processing $total_iterations transactions with output suppressed..."
        set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
        for {set it 0} {$it < $total_iterations} {incr it} {
            if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
            set choice [ RandomNumber 1 23 ]
            if {$choice <= 10} {
                if { $KEYANDTHINK } { keytime 18 }
                neword $neword_st $w_id $w_id_input $RAISEERROR
                if { $KEYANDTHINK } { thinktime 12 }
            } elseif {$choice <= 20} {
                if { $KEYANDTHINK } { keytime 3 }
                payment $payment_st $w_id $w_id_input $RAISEERROR
                if { $KEYANDTHINK } { thinktime 12 }
            } elseif {$choice <= 21} {
                if { $KEYANDTHINK } { keytime 2 }
                delivery $delivery_st $w_id $RAISEERROR
                if { $KEYANDTHINK } { thinktime 10 }
            } elseif {$choice <= 22} {
                if { $KEYANDTHINK } { keytime 2 }
                slev $slev_st $w_id $stock_level_d_id $RAISEERROR
                if { $KEYANDTHINK } { thinktime 5 }
            } elseif {$choice <= 23} {
                if { $KEYANDTHINK } { keytime 2 }
                ostat $ostat_st $w_id $RAISEERROR
                if { $KEYANDTHINK } { thinktime 5 }
            }
        }
$neword_st close 
$payment_st close
$delivery_st close
$slev_st close
$ostat_st close
odbc close
    }
}}
        if { $mssqls_connect_pool } { 
            insert_mssqlsconnectpool_drivescript timed sync 
        }
    } else {
        #ASYNCHRONOUS TIMED SCRIPT
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#OPTIONS
set library $library ;# SQL Server Library
set version $version ;# SQL Server Library Version
set total_iterations $mssqls_total_iterations;# Number of transactions before logging off
set RAISEERROR \"$mssqls_raiseerror\" ;# Exit script on SQL Server error (true or false)
set KEYANDTHINK \"$mssqls_keyandthink\" ;# Time for user thinking and keying (true or false)
set CHECKPOINT \"$mssqls_checkpoint\" ;# Perform SQL Server checkpoint when complete (true or false)
set rampup $mssqls_rampup;  # Rampup time in minutes before first Transaction Count is taken
set duration $mssqls_duration;  # Duration in minutes before second Transaction Count is taken
set mode \"$opmode\" ;# HammerDB operational mode
set authentication \"$mssqls_authentication\";# Authentication Mode (WINDOWS or SQL)
set server \{$mssqls_server\};# Microsoft SQL Server Database Server
set port \"$mssqls_port\";# Microsoft SQL Server Port 
set odbc_driver \{$mssqls_odbc_driver\};# ODBC Driver
set uid \"$mssqls_uid\";#User ID for SQL Server Authentication
set pwd \"[ quotemeta $mssqls_pass ]\";#Password for SQL Server Authentication
set tcp \"$mssqls_tcp\";#Specify TCP Protocol
set azure \"$mssqls_azure\";#Azure Type Connection
set database \"$mssqls_dbase\";# Database containing the TPC Schema
set encrypt \"$mssqls_encrypt_connection\";# Encrypt Connection
set trust_cert \"$mssqls_trust_server_cert\";# Trust Server Certificate
set msi_object_id \"$mssqls_msi_object_id\";# MSI Object ID for Entra authentication
set async_client $mssqls_async_client;# Number of asynchronous clients per Vuser
set async_verbose $mssqls_async_verbose;# Report activity of asynchronous clients
set async_delay $mssqls_async_delay;# Delay in ms between logins of asynchronous clients
#OPTIONS
"
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }
if [catch {package require promise } message] { error "Failed to load promise package for asynchronous clients" }

if { [ chk_thread ] eq "FALSE" } {
    error "SQL Server Timed Script must be run in Thread Enabled Interpreter"
}

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

proc CheckDBVersion { odbc } {
	   if {[catch {set rows [ odbc allrows "SELECT SERVERPROPERTY('productversion')" ]} message ]} {
		set dbversion "DBVersion:NULL"
	   } else {
	        set dbversion "DBVersion:[ lindex {*}$rows 1 ]"
	   }
	   return "$dbversion"
	}

set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
switch $myposition {
    1 { 
        if { $mode eq "Local" || $mode eq "Primary" } {
    	    set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
            if [catch {tdbc::odbc::connection create odbc $connection} message ] {
                error "Connection to $connection could not be established : $message"
            } else {
                if {!$azure} { odbc evaldirect "use $database" }
            }
            set ramptime 0
	    puts [ CheckDBVersion odbc ]
            puts "Beginning rampup time of $rampup minutes"
            set rampup [ expr $rampup*60000 ]
            while {$ramptime != $rampup} {
                if { [ tsv::get application abort ] } { break } else { after 6000 }
                set ramptime [ expr $ramptime+6000 ]
                if { ![ expr {$ramptime % 60000} ] } {
                    puts "Rampup [ expr $ramptime / 60000 ] minutes complete ..."
                }
            }
            if { [ tsv::get application abort ] } { break }
            puts "Rampup complete, Taking start Transaction Count."
            if {[catch {set rows [ odbc allrows "select sum(cast(d_next_o_id as bigint)) from district" ]} message ]} {
                error "Failed to query district table : $message"
            } else {
                set start_nopm [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            }
            if {[catch {set rows [ odbc allrows "select cntr_value from sys.dm_os_performance_counters where counter_name = 'Batch Requests/sec'" ]} message ]} {
                error "Failed to query transaction statistics : $message"
            } else {
                set start_trans [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            } 
            puts "Timing test period of $duration in minutes"
            set testtime 0
            set durmin $duration
            set duration [ expr $duration*60000 ]
            while {$testtime != $duration} {
                if { [ tsv::get application abort ] } { break } else { after 6000 }
                set testtime [ expr $testtime+6000 ]
                if { ![ expr {$testtime % 60000} ] } {
                    puts -nonewline  "[ expr $testtime / 60000 ]  ...,"
                }
            }
            if { [ tsv::get application abort ] } { break }
            puts "Test complete, Taking end Transaction Count."
            if {[catch {set rows [ odbc allrows "select sum(cast(d_next_o_id as bigint)) from district" ]} message ]} {
                error "Failed to query district table : $message"
            } else {
                set end_nopm [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            }
            if {[catch {set rows [ odbc allrows "select cntr_value from sys.dm_os_performance_counters where counter_name = 'Batch Requests/sec'" ]} message ]} {
                error "Failed to query transaction statistics : $message"
            } else {
                set end_trans [ lindex {*}$rows 1 ]
                unset -nocomplain rows
            } 
            if { [ string is entier -strict $end_trans ] && [ string is entier -strict $start_trans ] } {
                if { $start_trans < $end_trans }  {
                    set tpm [ expr {($end_trans - $start_trans)/$durmin} ]
                } else {
                    puts "Warning: SQL Server returned end transaction count data greater than start data"
                    set tpm 0
                } 
            } else {
                puts "Warning: SQL Server returned non-numeric transaction count data"
                set tpm 0
            }
            set nopm [ expr {($end_nopm - $start_nopm)/$durmin} ]
            puts "[ expr $totalvirtualusers - 1 ] VU \* $async_client AC \= [ expr ($totalvirtualusers - 1) * $async_client ] Active Sessions configured"
            puts [ testresult $nopm $tpm "SQL Server" ]
            tsv::set application abort 1
            if { $mode eq "Primary" } { eval [subst {thread::send -async $MASTER { remote_command ed_kill_vusers }}] }
            if { $CHECKPOINT } {
                puts "Checkpoint"
                if  [catch {odbc evaldirect "checkpoint"} message ]  {
                    error "Failed to execute checkpoint : $message"
                } else {
                    puts "Checkpoint Complete"
                }
            }
            odbc close
        } else {
            puts "Operating in Replica Mode, No Snapshots taken..."
        }
    }
    default {
        #TIMESTAMP
        proc gettimestamp { } {
            set tstamp [ clock format [ clock seconds ] -format "%Y-%m-%d %H:%M:%S" ]
            return $tstamp
        }
        #NEW ORDER
        proc neword { neword_st no_w_id w_id_input RAISEERROR clientname } {
            #2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
            set no_d_id [ RandomNumber 1 10 ]
            #2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
            set no_c_id [ RandomNumber 1 3000 ]
            #2.4.1.3 Items in the order randomly selected from 5 to 15
            set ol_cnt [ RandomNumber 5 15 ]
            #2.4.1.6 order entry date O_ENTRY_D generated by SUT
            set date [ gettimestamp ]
            if  {[catch {set resultset [ $neword_st execute [ list no_w_id $no_w_id w_id_input $w_id_input no_d_id $no_d_id no_c_id $no_c_id ol_cnt $ol_cnt date $date ]]} message ]} {
                if { $RAISEERROR } {
                    error "New Order Bind/Exec in $clientname : $message"
                } else {
                    puts "New Order Bind/Exec in $clientname : $message"
                }
            } else {
                if {[catch {set norows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "New Order Fetch in $clientname : $message"
                    } else {
                        puts "New Order Fetch in $clientname : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #PAYMENT
        proc payment { payment_st p_w_id w_id_input RAISEERROR clientname } {
            #2.5.1.1 The home warehouse id remains the same for each terminal
            #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
            set p_d_id [ RandomNumber 1 10 ]
            #2.5.1.2 customer selected 60% of time by name and 40% of time by number
            set x [ RandomNumber 1 100 ]
            set y [ RandomNumber 1 100 ]
            if { $x <= 85 } {
                set p_c_d_id $p_d_id
                set p_c_w_id $p_w_id
            } else {
                #use a remote warehouse
                set p_c_d_id [ RandomNumber 1 10 ]
                set p_c_w_id [ RandomNumber 1 $w_id_input ]
                while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
                    set p_c_w_id [ RandomNumber 1  $w_id_input ]
                }
            }
            set nrnd [ NURand 255 0 999 123 ]
            set name [ randname $nrnd ]
            set p_c_id [ RandomNumber 1 3000 ]
            if { $y <= 60 } {
                #use customer name
                #C_LAST is generated
                set byname 1
            } else {
                #use customer number
                set byname 0
                set name {}
            }
            #2.5.1.3 random amount from 1 to 5000
            set p_h_amount [ RandomNumber 1 5000 ]
            #2.5.1.4 date selected from SUT
            set h_date [ gettimestamp ]
            #2.5.2.1 Payment Transaction
            if  {[catch {set resultset [ $payment_st execute [ list p_w_id $p_w_id p_d_id $p_d_id p_c_w_id $p_c_w_id p_c_d_id $p_c_d_id p_c_id $p_c_id byname $byname p_h_amount $p_h_amount name $name h_date $h_date ] ]} message ]} {
                if { $RAISEERROR } {
                    error "Payment Bind/Exec in $clientname : $message"
                } else {
                    puts "Payment Bind/Exec in $clientname : $message"
                }
            } else {
                if {[catch {set pyrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Payment Fetch in $clientname : $message"
                    } else {
                        puts "Payment Fetch in $clientname : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #ORDER_STATUS
        proc ostat { ostat_st w_id RAISEERROR clientname } {
            #2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
            set d_id [ RandomNumber 1 10 ]
            set nrnd [ NURand 255 0 999 123 ]
            set name [ randname $nrnd ]
            set c_id [ RandomNumber 1 3000 ]
            set y [ RandomNumber 1 100 ]
            if { $y <= 60 } {
                set byname 1
            } else {
                set byname 0
                set name {}
            }
            if  {[catch {set resultset [ $ostat_st execute [ list os_w_id $w_id os_d_id $d_id os_c_id  $c_id byname  $byname os_c_last $name ]]} message ]} {
                if { $RAISEERROR } {
                    error "Order Status Bind/Exec in $clientname : $message"
                } else {
                    puts "Order Status Bind/Exec in $clientname : $message"
                }
            } else {
                if {[catch {set osrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Order Status Fetch in $clientname : $message"
                    } else {
                        puts "Order Status Fetch in $clientname : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #DELIVERY
        proc delivery { delivery_st w_id RAISEERROR clientname } {
            set carrier_id [ RandomNumber 1 10 ]
            set date [ gettimestamp ]
            if  {[catch {set resultset [ $delivery_st execute [ list d_w_id $w_id d_o_carrier_id $carrier_id timestamp $date ]]} message ]} {
                if { $RAISEERROR } {
                    error "Delivery Bind/Exec in $clientname : $message"
                } else {
                    puts "Delivery Bind/Exec in $clientname : $message"
                }
            } else {
                if {[catch {set dlrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Delivery Fetch in $clientname : $message"
                    } else {
                        puts "Delivery Fetch in $clientname : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        #STOCK LEVEL
        proc slev { slev_st w_id stock_level_d_id RAISEERROR clientname } {
            set threshold [ RandomNumber 10 20 ]
            if  {[catch {set resultset [ $slev_st execute [ list st_w_id $w_id st_d_id $stock_level_d_id threshold $threshold ]]} message ]} {
                if { $RAISEERROR } {
                    error "Stock Level in $clientname : $message"
                } else {
                    puts "Stock Level in $clientname : $message"
                }
            } else {
                if {[catch {set slrows [ $resultset allrows ]} message ]} {
                    catch {$resultset close}
                    if { $RAISEERROR } {
                        error "Stock Level Fetch in $clientname : $message"
                    } else {
                        puts "Stock Level Fetch in $clientname : $message"
                    }} else {
                    catch {$resultset close}
                }
            }
        }

        proc prep_statement { odbc statement_st } {
            switch $statement_st {
                slev_st {
                    set slev_st [ $odbc prepare "EXEC slev @st_w_id = :st_w_id, @st_d_id = :st_d_id, @threshold =  :threshold" ]
                    $slev_st paramtype st_w_id in integer 10 0
                    $slev_st paramtype st_d_id in integer 10 0
                    $slev_st paramtype threshold in integer 10 0
                    return $slev_st
                }

                delivery_st {
                    set delivery_st [ $odbc prepare "EXEC delivery @d_w_id = :d_w_id, @d_o_carrier_id = :d_o_carrier_id, @timestamp = :timestamp" ]
                    $delivery_st paramtype d_w_id in integer 10 0
                    $delivery_st paramtype d_o_carrier_id in integer 10 0
                    $delivery_st paramtype timestamp in timestamp 19 0
                    return $delivery_st
                }
                ostat_st {
                    set ostat_st [ $odbc prepare "EXEC ostat @os_w_id = :os_w_id, @os_d_id = :os_d_id, @os_c_id = :os_c_id, @byname = :byname, @os_c_last = :os_c_last" ]
                    $ostat_st paramtype os_w_id in integer 10 0
                    $ostat_st paramtype os_d_id in integer 10 0
                    $ostat_st paramtype os_c_id in integer 10 0 
                    $ostat_st paramtype byname in integer 10 0 
                    $ostat_st paramtype os_c_last in char 20 0
                    return $ostat_st
                }
                payment_st {
                    set payment_st [ $odbc prepare "EXEC payment @p_w_id = :p_w_id, @p_d_id = :p_d_id, @p_c_w_id = :p_c_w_id, @p_c_d_id = :p_c_d_id, @p_c_id = :p_c_id, @byname = :byname, @p_h_amount = :p_h_amount, @p_c_last = :name, @TIMESTAMP =:h_date" ] 
                    $payment_st paramtype p_w_id in integer 10 0
                    $payment_st paramtype p_d_id in integer 10 0
                    $payment_st paramtype p_c_w_id in integer 10 0
                    $payment_st paramtype p_c_d_id in integer 10 0
                    $payment_st paramtype p_c_id in integer 10 0
                    $payment_st paramtype byname in integer 10 0
                    $payment_st paramtype p_h_amount in numeric 6 2
                    $payment_st paramtype name in char 16 0
                    $payment_st paramtype h_date in timestamp 19 0
                    return $payment_st
                }
                neword_st {
                    set neword_st [ $odbc prepare "EXEC neword @no_w_id = :no_w_id, @no_max_w_id = :w_id_input, @no_d_id = :no_d_id, @no_c_id = :no_c_id, @no_o_ol_cnt = :ol_cnt, @TIMESTAMP = :date" ]
                    $neword_st paramtype no_w_id in integer 10 0 
                    $neword_st paramtype w_id_input in integer 10 0 
                    $neword_st paramtype no_d_id in integer 10 0 
                    $neword_st paramtype no_c_id in integer 10 0 
                    $neword_st paramtype ol_cnt integer 10 0 
                    $neword_st paramtype date in timestamp 19 0
                    return $neword_st
                }
            }
        }

        #CONNECT ASYNC
        promise::async simulate_client { clientname total_iterations connection RAISEERROR KEYANDTHINK database azure async_verbose async_delay } {
            set acno [ expr [ string trimleft [ lindex [ split $clientname ":" ] 1 ] ac ] * $async_delay ]
            if { $async_verbose } { puts "Delaying login of $clientname for $acno ms" } 
            async_time $acno
            if {  [ tsv::get application abort ]  } { return "$clientname:abort before login" }
            if { $async_verbose } { puts "Logging in $clientname" }
            if [catch {tdbc::odbc::connection create odbc-$clientname $connection} message ] {
                if { $RAISEERROR } {
                    puts "$clientname:login failed:$message"
                    return "$clientname:login failed:$message"
                } 
            } else {
                if { $async_verbose } { puts "Connected $clientname:$connection" }
                if {!$azure} { odbc-$clientname evaldirect "use $database" }
                odbc-$clientname evaldirect "set implicit_transactions OFF"
            }
            #RUN TPC-C
            foreach st {neword_st payment_st ostat_st delivery_st slev_st} { set $st [ prep_statement odbc-$clientname $st ] }
            set rows [ odbc-$clientname allrows "select max(w_id) from warehouse" ]
            set w_id_input [ lindex {*}$rows 1 ]
            #2.4.1.1 set warehouse_id stays constant for a given terminal
            set w_id  [ RandomNumber 1 $w_id_input ]  
            set rows [ odbc-$clientname allrows "select max(d_id) from district" ]
            set d_id_input [ lindex {*}$rows 1 ]
            set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
            if { $async_verbose } { puts "Processing $total_iterations transactions with output suppressed..." }
            set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
            for {set it 0} {$it < $total_iterations} {incr it} {
                if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
                set choice [ RandomNumber 1 23 ]
                if {$choice <= 10} {
                    if { $async_verbose } { puts "$clientname:w_id:$w_id:neword" }
                    if { $KEYANDTHINK } { async_keytime 18  $clientname neword $async_verbose }
                    neword $neword_st $w_id $w_id_input $RAISEERROR $clientname
                    if { $KEYANDTHINK } { async_thinktime 12 $clientname neword $async_verbose }
                } elseif {$choice <= 20} {
                    if { $async_verbose } { puts "$clientname:w_id:$w_id:payment" }
                    if { $KEYANDTHINK } { async_keytime 3 $clientname payment $async_verbose }
                    payment $payment_st $w_id $w_id_input $RAISEERROR $clientname
                    if { $KEYANDTHINK } { async_thinktime 12 $clientname payment $async_verbose }
                } elseif {$choice <= 21} {
                    if { $async_verbose } { puts "$clientname:w_id:$w_id:delivery" }
                    if { $KEYANDTHINK } { async_keytime 2 $clientname delivery $async_verbose }
                    delivery $delivery_st $w_id $RAISEERROR $clientname
                    if { $KEYANDTHINK } { async_thinktime 10 $clientname delivery $async_verbose }
                } elseif {$choice <= 22} {
                    if { $async_verbose } { puts "$clientname:w_id:$w_id:slev" }
                    if { $KEYANDTHINK } { async_keytime 2 $clientname slev $async_verbose }
                    slev $slev_st $w_id $stock_level_d_id $RAISEERROR $clientname
                    if { $KEYANDTHINK } { async_thinktime 5 $clientname slev $async_verbose }
                } elseif {$choice <= 23} {
                    if { $async_verbose } { puts "$clientname:w_id:$w_id:ostat" }
                    if { $KEYANDTHINK } { async_keytime 2 $clientname ostat $async_verbose }
                    ostat $ostat_st $w_id $RAISEERROR $clientname
                    if { $KEYANDTHINK } { async_thinktime 5 $clientname ostat $async_verbose }
                }
            }
            $neword_st close 
            $payment_st close
            $delivery_st close
            $slev_st close
            $ostat_st close
            odbc-$clientname close
            if { $async_verbose } { puts "$clientname:complete" }
            return $clientname:complete
        }
    	set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure $database $encrypt $trust_cert $msi_object_id ]
        for {set ac 1} {$ac <= $async_client} {incr ac} { 
            set clientdesc "vuser$myposition:ac$ac"
            lappend clientlist $clientdesc
            lappend clients [simulate_client $clientdesc $total_iterations $connection $RAISEERROR $KEYANDTHINK $database $azure $async_verbose $async_delay]
        }
        puts "Started asynchronous clients:$clientlist"
        set acprom [ promise::eventloop [ promise::all $clients ] ] 
        puts "All asynchronous clients complete" 
        if { $async_verbose } {
            foreach client $acprom { puts $client }
        }
    }
}}
        if { $mssqls_connect_pool } { 
            insert_mssqlsconnectpool_drivescript timed async 
        }
    }
}

proc delete_mssqlstpcc {} {
    global maxvuser suppo ntimes threadscreated _ED
    upvar #0 dbdict dbdict
    if {[dict exists $dbdict mssqlserver library ]} {
        set library [ dict get $dbdict mssqlserver library ]
    } else { set library "tdbc::odbc 1.0.6" }
    if { [ llength $library ] > 1 } { 
        set version [ lindex $library 1 ]
        set library [ lindex $library 0 ]
    }
    upvar #0 configmssqlserver configmssqlserver
    #set variables to values in dict
    setlocaltpccvars $configmssqlserver
    if {![string match windows $::tcl_platform(platform)]} {
        set mssqls_server $mssqls_linux_server 
        set mssqls_odbc_driver $mssqls_linux_odbc
        set mssqls_authentication $mssqls_linux_authent 
    }
    if {[ tk_messageBox -title "Delete Schema" -icon question -message "Do you want to delete the [ string toupper $mssqls_dbase ] TPROC-C schema\nin host [string toupper $mssqls_server ]?" -type yesno ] == yes} { 
        set maxvuser 1
        set suppo 1
        set ntimes 1
        ed_edit_clear
        set _ED(packagekeyname) "TPROC-C deletion"
        if { [catch {load_virtual} message]} {
            puts "Failed to created thread for schema deletion: $message"
            return
        }
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#LOAD LIBRARIES AND MODULES
set library $library
set version $version
"
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

proc drop_tpcc { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id } {
    set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure tempdb $encrypt $trust_cert $msi_object_id ]
    
    if [catch {tdbc::odbc::connection create odbc $connection} message ] {
        error "Connection to $connection could not be established : $message"
    } else {
	    if {!$azure} {odbc evaldirect "use tempdb"}
    set rows [ odbc allrows "IF DB_ID('$db') is not null SELECT 1 AS res ELSE SELECT 0 AS res" ]
    set db_exists [ lindex {*}$rows 1 ]
 if { $db_exists } {
        if {!$azure} {
set sql(1) [ subst -nocommands {USE [$db];
ALTER DATABASE $db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
USE [tempdb];
DROP DATABASE $db;}]
        } else {
set sql(1) "DROP DATABASE $db"
}
odbc evaldirect $sql(1)
set rows [ odbc allrows "IF DB_ID('$db') is not null SELECT 1 AS res ELSE SELECT 0 AS res" ]
    set db_exists [ lindex {*}$rows 1 ]
 if { !$db_exists } {
puts "$db TPROC-C schema has been deleted successfully."
} else {
error "Failed to delete $db TPROC-C schema."
}
} else {
error "$db TPROC-C schema does not exist to delete."
}
odbc close
return
}
}
}
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "drop_tpcc {$mssqls_server} $mssqls_port {$mssqls_odbc_driver} $mssqls_authentication $mssqls_uid [ quotemeta $mssqls_pass ] $mssqls_tcp $mssqls_azure $mssqls_dbase $mssqls_encrypt_connection $mssqls_trust_server_cert $mssqls_msi_object_id"
    } else { return }
}

proc check_mssqlstpcc {} {
    global maxvuser suppo ntimes threadscreated _ED
    upvar #0 dbdict dbdict
    if {[dict exists $dbdict mssqlserver library ]} {
        set library [ dict get $dbdict mssqlserver library ]
    } else { set library "tdbc::odbc 1.0.6" }
    if { [ llength $library ] > 1 } { 
        set version [ lindex $library 1 ]
        set library [ lindex $library 0 ]
    }
    upvar #0 configmssqlserver configmssqlserver
    #set variables to values in dict
    setlocaltpccvars $configmssqlserver
    if {![string match windows $::tcl_platform(platform)]} {
        set mssqls_server $mssqls_linux_server 
        set mssqls_odbc_driver $mssqls_linux_odbc
        set mssqls_authentication $mssqls_linux_authent 
    }
    if {[ tk_messageBox -title "Check Schema" -icon question -message "Do you want to check the [ string toupper $mssqls_dbase ] TPROC-C schema\nin host [string toupper $mssqls_server ]?" -type yesno ] == yes} { 
        set maxvuser 1
        set suppo 1
        set ntimes 1
        ed_edit_clear
        set _ED(packagekeyname) "TPROC-C check"
        if { [catch {load_virtual} message]} {
            puts "Failed to created thread for schema check: $message"
            return
        }
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh9.0
#LOAD LIBRARIES AND MODULES
set library $library
set version $version
"
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end {if [catch {package require $library $version} message] { error "Failed to load $library - $message" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }

proc connect_string { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id} {
    if { $tcp eq "true" } { set server tcp:$server,$port }
    if {[ string toupper $authentication ] eq "WINDOWS" } {
        set connection "DRIVER=$odbc_driver;SERVER=$server;TRUSTED_CONNECTION=YES"
    } else {
        if {[ string toupper $authentication ] eq "SQL" } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;UID=$uid;PWD=$pwd"
     } else {
        if {[ string toupper $authentication ] eq "ENTRA" } {
        if {[ regexp {[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}} $msi_object_id ] } {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryMsi;UID=$msi_object_id"
	} else {
            set connection "DRIVER=$odbc_driver;SERVER=$server;AUTHENTICATION=ActiveDirectoryInteractive"
	}
        } else {
            puts stderr "Error: neither WINDOWS, ENTRA or SQL Authentication has been specified"
            set connection "DRIVER=$odbc_driver;SERVER=$server"
        }
    }
}
    if { $azure eq "true" } { append connection ";" "DATABASE=$db" }
    if { $encrypt eq "true" } { append connection ";" "ENCRYPT=yes" } else { append connection ";" "ENCRYPT=no" }
    if { $trust_cert eq "true" } { append connection ";" "TRUSTSERVERCERTIFICATE=yes" }
    return $connection
}

proc check_tpcc { server port odbc_driver authentication uid pwd tcp azure db encrypt trust_cert msi_object_id count_ware } {
	puts "Checking $db TPROC-C schema"
    set tables [ dict create warehouse $count_ware customer [ expr {$count_ware * 30000} ] district [ expr {$count_ware * 10} ] history [ expr {$count_ware * 30000} ] item 100000 new_order [ expr {$count_ware * 9000 * 0.90} ] order_line [ expr {$count_ware * 300000 * 0.99} ] orders [ expr {$count_ware * 30000} ] stock [ expr {$count_ware * 100000} ] ]
    set sps [ list delivery neword ostat payment slev ]
    set connection [ connect_string $server $port $odbc_driver $authentication $uid $pwd $tcp $azure tempdb $encrypt $trust_cert $msi_object_id ]
    if [catch {tdbc::odbc::connection create odbc $connection} message ] {
        error "Connection to $connection could not be established : $message"
    } else {
	    if {!$azure} {odbc evaldirect "use tempdb"}
	    #Check 1 Database Exists
	puts "Check database"
    set rows [ odbc allrows "IF DB_ID('$db') is not null SELECT 1 AS res ELSE SELECT 0 AS res" ]
    set db_exists [ lindex {*}$rows 1 ]
    if { $db_exists } {
        if {!$azure} {odbc evaldirect "use $db"}
        set rows [ odbc allrows "select COUNT(*) from sys.tables" ]
        set table_count [ lindex {*}$rows 1 ]
        if { $table_count == 0 } {
	error "TPROC-C Schema check failed $db schema is empty"
	} else {
	    #Check 2 Tables Exist
	puts "Check tables and indices"
	foreach table [dict keys $tables] {
    	set rows [ odbc allrows "IF OBJECT_ID (N'$table', N'U') IS NOT NULL SELECT 1 AS res ELSE SELECT 0 AS res" ]
        set table_exists [ lindex {*}$rows 1 ]
        if { $table_exists == 0 } {
	error "TPROC-C Schema check failed $db schema is missing table $table"
	} else {
	if { $table eq "warehouse" } {
	    #Check 3 Warehouse count in schema is the same as dict setting
        set rows [ odbc allrows "select max(w_id) from warehouse" ]
        set w_id_input [ lindex {*}$rows 1 ]
	if { $count_ware != $w_id_input } {
	error "TPROC-C Schema check failed $db schema warehouse count $w_id_input does not equal dict warehouse count of $count_ware"
	}
	}
	    #Check 4 Tables are indexed
    	set rows [ odbc allrows "SP_HELPINDEX '$table'" ]
        if { [ llength $rows ] eq 0 } {
	error "TPROC-C Schema check failed $db schema on table $table no indices"
	}
	    #Check 5 Tables are populated
	set expected_rows [ dict get $tables $table ]
        set rows [ odbc allrows "select count(*) from $table" ]
        set row_count [ lindex {*}$rows 1 ]
        if { $row_count < $expected_rows } {
	error "TPROC-C Schema check failed $db schema on table $table row count of $row_count is less than expected count of $expected_rows"
	} 
	}
	}
	}
	    #Check 6 Stored Procedures Exist
	puts "Check procedures"
	foreach sp $sps {
    	set rows [ odbc allrows "IF OBJECT_ID ('$sp', 'P') IS NOT NULL SELECT 1 AS res ELSE SELECT 0 AS res" ]
        set sp_exists [ lindex {*}$rows 1 ]
        if { $sp_exists == 0 } {
	error "TPROC-C Schema check failed $db schema is missing stored procedure $sp"
	}
	}
	    #Create temporary sample table
        set sql(1) [ subst -nocommands {CREATE TABLE [dbo].[#temp_w]([t_w_id] [smallint] NULL) ON [PRIMARY]}]
        odbc evaldirect $sql(1)
	if { $w_id_input <= 10 } {
	for  {set i 1} {$i <= $w_id_input} { incr i} {
 	odbc evaldirect "insert into #temp_w values ($i)"
	}
	} else {
	foreach statement {{insert into #temp_w values (1)} {insert into #temp_w values ([expr {0.1 * $w_id_input}])} {insert into #temp_w values ([expr {0.2 * $w_id_input}])} {insert into #temp_w values ([expr {0.3 * $w_id_input}])} {insert into #temp_w values ([expr {0.4 * $w_id_input}])} {insert into #temp_w values ([expr {0.5 * $w_id_input}])} {insert into #temp_w values ([expr {0.6 * $w_id_input}])} {insert into #temp_w values ([expr {0.7 * $w_id_input}])} {insert into #temp_w values ([expr {0.8 * $w_id_input}])} {insert into #temp_w values ([expr {0.9 * $w_id_input}])} {insert into #temp_w values ($w_id_input)}} {
	odbc evaldirect [ subst $statement ]
	}
	}
	   #Consistency check 1
	puts "Check consistency 1"
	set rows [ odbc allrows "select d_w_id, (w_ytd - sum(d_ytd)) diff from warehouse, district where d_w_id=w_id group by d_w_id, w_ytd having (w_ytd - sum(d_ytd)) != 0" ]
	if {[ llength $rows ] > 0} {
	error "TPROC-C Schema check failed $db schema consistency check 1 failed"
	} 
	   #Consistency check 2
	puts "Check consistency 2"
	set rows [ odbc allrows "select * from (select d_w_id, d_id, max(o_id) AS ORDER_MAX, (d_next_o_id - 1) AS ORDER_NEXT from district, orders where d_w_id = o_w_id and d_id = o_d_id and d_w_id in (select t_w_id from #temp_w) group by d_w_id, d_id, (d_next_o_id - 1)) dt where dt.ORDER_NEXT != dt.ORDER_MAX" ]
	if {[ llength $rows ] > 0} {
	error "TPROC-C Schema check failed $db schema consistency check 2 failed"
	} 
	   #Consistency check 3
	puts "Check consistency 3"
	set rows [ odbc allrows "select * from (select count(*) as nocount, (max(no_o_id) - min(no_o_id) + 1) as total from new_order group by no_w_id, no_d_id) dt where nocount != total" ]
	if {[ llength $rows ] > 0} {
	error "TPROC-C Schema check failed $db schema consistency check 3 failed"
	} 
	   #Consistency check 4
	puts "Check consistency 4"
	set rows [ odbc allrows "select * from (select o_w_id, o_d_id, sum(o_ol_cnt) as ol_sum from orders, #temp_w where o_w_id = t_w_id group by o_w_id, o_d_id) consist1, (select ol_w_id, ol_d_id, count(*) as ol_count from order_line, #temp_w where ol_w_id = t_w_id group by ol_w_id, ol_d_id) consist2 where o_w_id = ol_w_id and o_d_id = ol_d_id and ol_sum != ol_count" ]
	if {[ llength $rows ] > 0} {
	error "TPROC-C Schema check failed $db schema consistency check 4 failed"
	} 
	    #Drop temporary sample table
        set sql(1) [ subst -nocommands {DROP TABLE [dbo].[#temp_w]}]
        odbc evaldirect $sql(1)
	#All consistency checks have completed
	puts "$db TPROC-C schema has been checked successfully"
	} else {
	error "Schema check failed $db TPROC-C schema does not exist"
	}
	odbc close
	return
	}
	}
	}
        .ed_mainFrame.mainwin.textFrame.left.text fastinsert end "check_tpcc {$mssqls_server} $mssqls_port {$mssqls_odbc_driver} $mssqls_authentication $mssqls_uid [ quotemeta $mssqls_pass ] $mssqls_tcp $mssqls_azure $mssqls_dbase $mssqls_encrypt_connection $mssqls_trust_server_cert $mssqls_msi_object_id $mssqls_count_ware"
    } else { return }
}
