create or replace NONEDITIONABLE PACKAGE PKG_ORDER_LIST AS 

  --주문목록 등록 프로시저
  PROCEDURE PROC_INS_ORDER_LIST
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_POINT_USE        IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );

  --주문목록 조회 프로시저
  PROCEDURE PROC_SEL_ORDER_LIST
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_DELIVERY_FEE     IN VARCHAR2,
    IN_POINT_USE        IN VARCHAR2,
    IN_ORDER_STATUS     IN VARCHAR2,
    O_CUR               OUT SYS_REFCURSOR,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --주문목록 수정 프로시저
  PROCEDURE PROC_UP_ORDER_LIST
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_POINT_USE        IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  

END PKG_ORDER_LIST;