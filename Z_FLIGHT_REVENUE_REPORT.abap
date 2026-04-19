*&---------------------------------------------------------------------*
*& Report  : Z_FLIGHT_REVENUE_REPORT
*& Author  : [Your Name]
*& Created : 2025
*& Desc    : ALV Report - Flight Revenue Analysis
*&           Joins SFLIGHT + SCARR to display flight and airline data
*&           with selection screen filtering by airline and date range.
*&---------------------------------------------------------------------*

REPORT z_flight_revenue_report.

TABLES: sflight, scarr.

TYPE-POOLS: slis.

*----------------------------------------------------------------------*
* Structure Definition
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_flight,
         carrid   TYPE sflight-carrid,
         carrname TYPE scarr-carrname,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
         currency TYPE sflight-currency,
         seatsmax TYPE sflight-seatsmax,
         seatsocc TYPE sflight-seatsocc,
       END OF ty_flight.

*----------------------------------------------------------------------*
* Internal Table and Work Area
*----------------------------------------------------------------------*
DATA: it_flight   TYPE TABLE OF ty_flight,
      wa_flight   TYPE ty_flight.

*----------------------------------------------------------------------*
* Field Catalog
*----------------------------------------------------------------------*
DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECT-OPTIONS: s_carrid FOR sflight-carrid,
                s_fldate FOR sflight-fldate.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.

* Step 1: Fetch data with INNER JOIN
  SELECT a~carrid
         b~carrname
         a~connid
         a~fldate
         a~price
         a~currency
         a~seatsmax
         a~seatsocc
    INTO TABLE it_flight
    FROM sflight AS a
    INNER JOIN scarr AS b
      ON a~carrid = b~carrid
    WHERE a~carrid IN s_carrid
      AND a~fldate IN s_fldate.

  SORT it_flight BY carrid fldate.

* Step 2: Build field catalog
  PERFORM build_fieldcat.

* Step 3: Display ALV Grid
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = it_fieldcat
    TABLES
      t_outtab           = it_flight.

*----------------------------------------------------------------------*
* Build Field Catalog
*----------------------------------------------------------------------*
FORM build_fieldcat.
  PERFORM add_field USING 'CARRID'   'Airline Code'.
  PERFORM add_field USING 'CARRNAME' 'Airline Name'.
  PERFORM add_field USING 'CONNID'   'Flight No'.
  PERFORM add_field USING 'FLDATE'   'Date'.
  PERFORM add_field USING 'PRICE'    'Ticket Price'.
  PERFORM add_field USING 'CURRENCY' 'Currency'.
  PERFORM add_field USING 'SEATSMAX' 'Total Seats'.
  PERFORM add_field USING 'SEATSOCC' 'Occupied Seats'.
ENDFORM.

*----------------------------------------------------------------------*
* Helper: Add One Column to Field Catalog
*----------------------------------------------------------------------*
FORM add_field USING field_name field_text.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = field_name.
  wa_fieldcat-seltext_m = field_text.
  APPEND wa_fieldcat TO it_fieldcat.
ENDFORM.
