create or replace NONEDITIONABLE PACKAGE PKG_PAYMENT_HISTORY AS 

  --결제내역 등록 프로시저
  PROCEDURE PROC_INS_PAYMENT_LIST
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_PAY_PRICE        IN VARCHAR2,
    IN_PAYMENT_COM_ID   IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );

  --결제내역 조회 프로시저
  PROCEDURE PROC_SEL_PAYMENT_LIST
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_PAYMENT_COM_ID   IN VARCHAR2,
    O_CUR               OUT SYS_REFCURSOR,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --결제내역 수정 프로시저
  PROCEDURE PROC_UP_PAYMENT_LIST
  (
    IN_PAY_IDX          IN VARCHAR2,
    IN_PAY_PRICE        IN VARCHAR2,
    IN_PAYMENT_COM_ID   IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --결제내역 삭제 프로시저
  PROCEDURE PROC_DEL_PAYMENT_LIST
  (
    IN_PAY_IDX          IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );

END PKG_PAYMENT_HISTORY;